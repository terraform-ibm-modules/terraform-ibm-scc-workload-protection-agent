// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"log"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
	"golang.org/x/exp/rand"
)

const resourceGroup = "geretain-test-resources"

// const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic"
const secureExampleDir = "examples/secure"
const fullyConfigurableFlavorDir = "solutions/fully-configurable"
const fullyConfigurableKubeconfigDir = "solutions/fully-configurable/kubeconfig"

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

var ignoreAdds = []string{
	"module.scc_wp.restapi_object.cspm", // workaround for https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/issues/243
}

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}
var sharedInfoSvc *cloudinfo.CloudInfoService

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
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
		IgnoreAdds: testhelper.Exemptions{
			List: ignoreAdds,
		},
	})
	return options
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "scc-wp-a-basic", basicExampleDir)
	options.TerraformVars["scc_workload_protection_trusted_profile_name"] = fmt.Sprintf("tf-%s", options.Prefix)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunBasicUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "scc-wp-a-basic-upg", basicExampleDir)

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
		WaitJobCompleteMinutes: 180,
		// workaround for https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/issues/243
		IgnoreAdds: testhelper.Exemptions{
			List: []string{"module.scc_wp.restapi_object.cspm"},
		},
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "app_config_crn", Value: permanentResources["app_config_crn"], DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

// TestRunBasicAgentsVPCKubernetes validates this module against an IKS VPC cluster
func TestRunBasicAgentsVPCKubernetes(t *testing.T) {
	t.Parallel()
	options := setupOptions(t, "scc-wp-a-vpc-k8s", basicExampleDir)
	options.TerraformVars["is_openshift"] = false
	options.TerraformVars["cluster_shield_deploy"] = true
	options.TerraformVars["kspm_deploy"] = false
	options.TerraformVars["cluster_scanner_deploy"] = false
	options.TerraformVars["scc_workload_protection_trusted_profile_name"] = fmt.Sprintf("tf-%s", options.Prefix)

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
	options.TerraformVars["scc_workload_protection_trusted_profile_name"] = fmt.Sprintf("tf-%s", options.Prefix)

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
	options.TerraformVars["scc_workload_protection_trusted_profile_name"] = fmt.Sprintf("tf-%s", options.Prefix)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestFullyConfigurableDAInSchematics(t *testing.T) {
	t.Parallel()

	var region = validRegions[rand.Intn(len(validRegions))]

	// ------------------------------------------------------------------------------------------------------
	// Deploy SLZ ROKS Cluster and SCC Workload Protection instance since it is needed to deploy SCC Workload Protection Agents
	// ------------------------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("slz-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := "./resources/existing-resources/fully-configurable"
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
			"prefix":         prefix,
			"region":         region,
			"app_config_crn": permanentResources["app_config_crn"],
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
				"*.tf",
				fullyConfigurableFlavorDir + "/*.*",
				fullyConfigurableKubeconfigDir + "/*.*",
			},
			ResourceGroup:          resourceGroup,
			TemplateFolder:         fullyConfigurableFlavorDir,
			Tags:                   []string{"test-schematic"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
			// workaround for https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection/issues/243
			IgnoreAdds: testhelper.Exemptions{
				List: []string{"module.scc_wp.restapi_object.cspm"},
			},
			Region: region,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "access_key", Value: terraform.Output(t, existingTerraformOptions, "access_key"), DataType: "string"},
			{Name: "existing_cluster_id", Value: terraform.Output(t, existingTerraformOptions, "cluster_id"), DataType: "string"},
			{Name: "existing_cluster_resource_group_id", Value: terraform.Output(t, existingTerraformOptions, "resource_group_id"), DataType: "string"},
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
