// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic"

var ignoreUpdates = []string{
	"module.scc_wp_agent.helm_release.scc_wp_agent.set[0]",
	"module.scc_wp_agent.helm_release.scc_wp_agent.set",
	"module.scc_wp_agent.helm_release.scc_wp_agent.metadata",
	"module.scc_wp_agent.helm_release.scc_wp_agent.metadata[0]",
	"module.scc_wp_agent.helm_release.scc_wp_agent.version",
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

	options := setupOptions(t, "scc-wp-a", basicExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunBasicUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "scc-wp-a-upg", basicExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
