// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic"
const secureExampleDir = "examples/secure"

var ignoreUpdates = []string{
	"module.scc_wp_agent.helm_release.scc_wp_agent",
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
		ImplicitDestroy: []string{
			// workaround for the issue https://github.ibm.com/GoldenEye/issues/issues/10743
			// when the issue is fixed on IKS, so the destruction of default workers pool is correctly managed on provider/clusters service the next two entries should be removed
			"'module.ocp_base.ibm_container_vpc_worker_pool.autoscaling_pool[\"default\"]'",
			"'module.ocp_base.ibm_container_vpc_worker_pool.pool[\"default\"]'",
		},
	})
	return options
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "scc-wp-a-basic", basicExampleDir)

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
