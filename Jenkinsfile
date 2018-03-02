#!/usr/bin/env groovy

library("govuk")

REPOSITORY = "govspeak"

def rubyVersions = [
  "2.1",
  "2.2",
  "2.3.1",
]

node {

  try {
    stage("Checkout") {
      checkout(scm)
      govuk.mergeMasterBranch()
    }

    for (rubyVersion in rubyVersions) {
      stage("Test with ruby $rubyVersion") {
        govuk.cleanupGit()
        govuk.setEnvar("RBENV_VERSION", rubyVersion)
        govuk.setEnvar("BUNDLE_GEMFILE", "gemfiles/Gemfile.ruby-${rubyVersion}")
        govuk.bundleGem()

        govuk.rubyLinter("bin lib test")

        govuk.runTests()

        publishHTML(target: [
          allowMissing: false,
          alwaysLinkToLastBuild: false,
          keepAll: true,
          reportDir: "coverage/rcov",
          reportFiles: "index.html",
          reportName: "RCov Report ${rubyVersion}"
        ])
      }
    }
    sh("unset RBENV_VERSION")
    sh("unset BUNDLE_GEMFILE")

    if (env.BRANCH_NAME == "master") {
      stage("Push release tag") {
        echo("Pushing tag")
        govuk.pushTag(REPOSITORY, env.BRANCH_NAME, "release_" + env.BUILD_NUMBER)
      }

      stage("Publish gem") {
        echo("Publishing gem")
        govuk.publishGem(REPOSITORY, env.BRANCH_NAME)
      }
    }

  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: "Mailer",
          notifyEveryUnstableBuild: true,
          recipients: "govuk-ci-notifications@digital.cabinet-office.gov.uk",
          sendToIndividuals: true])
    throw e
  }
}
