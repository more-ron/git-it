Feature: GitIt gets it

  Scenario: App just runs
    When I get help for "git-it"
    Then the exit status should be 0

  Scenario: Get a none git repository opened in the web
    When I get it `opened_in_the_web`
    Then it should fail with "Could not find repository "

  Scenario: Get a github repository opened in the web
    Given a github repository
    When I get it `opened_in_the_web`
    Then it should launch "https://github.com/some-user/some-project/tree/your_branch"
