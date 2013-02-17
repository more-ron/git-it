Feature: GitIt gets it

  Scenario: App just runs
    When I get help for "git-it"
    Then the exit status should be 0

  Scenario: Get a none git repository opened in the web
    When I get it `opened`
    Then it should fail with "Could not find repository "

  Scenario: Get a github branch opened
    Given a github repository
    When I get it `opened`
    Then it should launch "https://github.com/some-user/some-project/tree/your_branch"

  Scenario: Get a github branch compared to another branch
    Given a github repository
    When I get it `compared`
    Then it should launch "https://github.com/some-user/some-project/compare/master...your_branch"

  Scenario: Get a github branch compared to another branch
    Given a github repository
    When I get it `compared --to=release`
    Then it should launch "https://github.com/some-user/some-project/compare/release...your_branch"

  Scenario: Get a github branch pulled into another branch
    Given a github repository
    When I get it `pulled`
    Then it should launch "https://github.com/some-user/some-project/pull/new/some-user:master...your_branch"

  Scenario: Get a github branch pulled into another branch
    Given a github repository
    When I get it `pulled --to=release`
    Then it should launch "https://github.com/some-user/some-project/pull/new/some-user:release...your_branch"
