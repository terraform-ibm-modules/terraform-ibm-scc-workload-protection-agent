// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
	"golang.org/x/exp/rand"
)

const resourceGroup = "geretain-test-resources"

// const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic"
const secureExampleDir = "examples/secure"
const standardFlavorDir = "solutions/standard"
const standardKubeconfigDir = "solutions/standard/kubeconfig"

// Current supported SCC region
var validRegions = []string{
	"us-south",
	"eu-de",
	"ca-tor",
	"eu-es",
}

var ignoreUpdates = []string{
	"module.scc_wp_agent.helm_release.scc_wp_agent",
}

var ImplicitDestroyOCP = []string{
	// workaround for the issue https://github.ibm.com/GoldenEye/issues/issues/10743
	// when the issue is fixed on IKS, so the destruction of default workers pool is correctly managed on provider/clusters service the next two entries should be removed
	"'module.ocp_base[0].ibm_container_vpc_worker_pool.pool[\"default\"]'",
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
		// only one `lite` wp instance can be provisioned for each RG. Always create a new RG.
		// ResourceGroup: resourceGroup,
		IgnoreUpdates: testhelper.Exemptions{
			List: ignoreUpdates,
		},
	})
	return options
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "scc-wp-a-basic", basicExampleDir)
	options.ImplicitDestroy = ImplicitDestroyOCP

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunBasicUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "scc-wp-a-basic-upg", basicExampleDir)
	options.ImplicitDestroy = ImplicitDestroyOCP

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestSecureExampleInSchematic(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "scc-wp-a-secure",
		TarIncludePatterns: []string{
			"*.tf",
			"scripts/*.sh",
			"examples/secure/*.tf",
			"modules/*/*.tf",
			"kubeconfig/README.md",
		},
		// only one `lite` wp instance can be provisioned for each RG. Always create a new RG.
		// ResourceGroup: resourceGroup,
		TemplateFolder:         secureExampleDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 90,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

// TestRunBasicAgentsVPCKubernetes validates this module against an IKS VPC cluster
func TestRunBasicAgentsVPCKubernetes(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "scc-wp-a-vpc-k8s", basicExampleDir)
	options.TerraformVars["is_openshift"] = false

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

// TestRunBasicAgentsClassicKubernetes validates this module against an IKS Classic cluster
func TestRunBasicAgentsClassicKubernetes(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "scc-wp-a-cla-k8s", basicExampleDir)
	options.TerraformVars["is_openshift"] = false
	options.TerraformVars["is_vpc_cluster"] = false

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

// TestRunBasicAgentsClassicOpenShift validates this module against a ROKS Classic cluster
func TestRunBasicAgentsClassicOpenShift(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "scc-wp-a-cla-ocp", basicExampleDir)
	options.TerraformVars["is_openshift"] = true
	options.TerraformVars["is_vpc_cluster"] = false

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestStandardDAInSchematics(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]

	// ------------------------------------------------------------------------------------------------------
	// Deploy SLZ ROKS Cluster and SCC Workload Protection instance since it is needed to deploy SCC Workload Protection Agents
	// ------------------------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("slz-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := "./resources/existing-resources/standard"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix": prefix,
			"region": region,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)

	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp resources (SLZ-ROKS and Workload SCC Protection Instances) failed")
	} else {

		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Prefix:  "scc-wp-agents",
			TarIncludePatterns: []string{
				standardFlavorDir + "/*.*",
				standardKubeconfigDir + "/*.*",
			},
			ResourceGroup:          resourceGroup,
			TemplateFolder:         standardFlavorDir,
			Tags:                   []string{"test-schematic"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
			Region:                 region,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "access_key", Value: terraform.Output(t, existingTerraformOptions, "access_key"), DataType: "string"},
			{Name: "cluster_id", Value: terraform.Output(t, existingTerraformOptions, "workload_cluster_id"), DataType: "string"},
			{Name: "cluster_resource_group_id", Value: terraform.Output(t, existingTerraformOptions, "cluster_resource_group_id"), DataType: "string"},
			{Name: "region", Value: region, DataType: "string"},
			{Name: "endpoint_type", Value: "private", DataType: "string"},
			{Name: "name", Value: options.Prefix, DataType: "string"},
		}

		err := options.RunSchematicTest()
		assert.Nil(t, err, "This should not have errored")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}
