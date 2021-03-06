Feature: Scaffold a README.md file for an existing package

  Scenario: Scaffold a README.md based on the defaults
    Given an empty directory

    When I run `wp package path`
    Then save STDOUT as {PACKAGE_PATH}

    When I run `wp scaffold package wp-cli/default-readme`
    Then STDOUT should contain:
      """
      Success: Created package readme.
      """
    And the {PACKAGE_PATH}/local/wp-cli/default-readme/README.md file should exist
    And the {PACKAGE_PATH}/local/wp-cli/default-readme/README.md file should contain:
      """
      Installing this package requires WP-CLI v0.23.0 or greater. Update to the latest stable release with `wp cli update`.
      """
    And the {PACKAGE_PATH}/local/wp-cli/default-readme/README.md file should contain:
      """
      [![Build Status](https://travis-ci.org/wp-cli/default-readme.svg?branch=master)
      """
    And the {PACKAGE_PATH}/local/wp-cli/default-readme/README.md file should contain:
      """
      *This README.md is generated dynamically from the project's codebase
      """
    When I run `wp package uninstall wp-cli/default-readme`
    Then STDOUT should contain:
      """
      Success: Uninstalled package.
      """

  Scenario: Scaffold a README.md requiring a nightly build
    Given an empty directory

    When I run `wp scaffold package wp-cli/foo --dir=foo --require_wp_cli='>=0.24.0-alpha'`
    Then STDOUT should contain:
      """
      Success: Created package readme.
      """
    And the foo/composer.json file should contain:
      """
          "require": {
              "wp-cli/wp-cli": ">=0.24.0-alpha"
          },
      """
    And the foo/README.md file should exist
    And the foo/README.md file should contain:
      """
      Installing this package requires WP-CLI v0.24.0-alpha or greater. Update to the latest nightly release with `wp cli update --nightly`.
      """
    When I run `wp package uninstall wp-cli/foo`
    Then STDOUT should contain:
      """
      Success: Uninstalled package.
      """

  Scenario: Scaffold a readme with custom shields
    Given an empty directory
    And a foo/composer.json file:
      """
      {
          "name": "runcommand/profile",
          "description": "Quickly identify what's slow with WordPress.",
          "homepage": "https://runcommand.io/wp/profile/",
          "license": "GPL-2.0",
          "authors": [],
          "minimum-stability": "dev",
          "autoload": {
              "files": [ "command.php" ]
          },
          "require": {
              "wp-cli/wp-cli": "~0.23.0"
          },
          "require-dev": {
              "behat/behat": "~2.5"
          },
          "extra": {
              "readme": {
                  "shields": [
                    "shield 1",
                    "shield 2",
                    "shield 3"
                  ]
              }
          }
      }
      """

    When I run `wp scaffold package-readme foo`
    Then the foo/README.md file should exist
    And the foo/README.md file should contain:
      """
      shield 1 shield 2 shield 3
      """

  Scenario: Scaffold a readme with a remote support body
    Given an empty directory
    And a foo/composer.json file:
      """
      {
          "name": "runcommand/profile",
          "description": "Quickly identify what's slow with WordPress.",
          "homepage": "https://runcommand.io/wp/profile/",
          "extra": {
              "readme": {
                  "contributing": {
                    "body": "https://gist.githubusercontent.com/danielbachhuber/bb652b1b744cea541705ee9c13605dad/raw/195c17ebb8cf25e947a9df6e02de1e96a084c287/support.md"
                  }
              }
          }
      }
      """

    When I run `wp scaffold package-readme foo`
    Then the foo/README.md file should exist
    And the foo/README.md file should contain:
      """
      ## Contributing

      Support isn't free!
      """

  Scenario: Scaffold a readme with custom sections
    Given an empty directory
    And a foo/composer.json file:
      """
      {
          "name": "runcommand/profile",
          "description": "Quickly identify what's slow with WordPress.",
          "homepage": "https://runcommand.io/wp/profile/",
          "extra": {
              "readme": {
                  "sections": [
                    "Installing",
                    "Donating"
                  ],
                  "donating": {
                    "body": "Give me money!"
                  }
              }
          }
      }
      """

    When I run `wp scaffold package-readme foo`
    Then the foo/README.md file should exist
    And the foo/README.md file should contain:
      """
      Quick links: [Installing](#installing) | [Donating](#donating)
      """
    And the foo/README.md file should contain:
      """
      ## Donating

      Give me money!
      """

  Scenario: Scaffold a readme without the powered by
    Given an empty directory
    And a foo/composer.json file:
      """
      {
          "name": "runcommand/profile",
          "description": "Quickly identify what's slow with WordPress.",
          "homepage": "https://runcommand.io/wp/profile/",
          "extra": {
              "readme": {
                  "show_powered_by": false
              }
          }
      }
      """

    When I run `wp scaffold package-readme foo`
    Then the foo/README.md file should exist
    And the foo/README.md file should not contain:
      """
      *This README.md is generated dynamically from the project's codebase
      """

  Scenario: Error when commands are specified but not present
    Given an empty directory
    And a foo/composer.json file:
      """
      {
          "name": "runcommand/profile",
          "description": "Quickly identify what's slow with WordPress.",
          "homepage": "https://runcommand.io/wp/profile/",
          "extra": {
              "commands": [
                "profile"
              ]
          }
      }
      """

    When I try `wp scaffold package-readme foo`
    Then STDERR should be:
      """
      Error: Missing one or more commands defined in composer.json -> extras -> commands.
      """
