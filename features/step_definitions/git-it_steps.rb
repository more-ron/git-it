When /^I get help for "([^"]*)"$/ do |app_name|
  @app_name = app_name
  run_simple(unescape("#{@app_name} help"), false)
end

# Add more step definitions here

Given /^a github repository$/ do
  @git_project_type = "github-project"
  @git_project_name = "some-project"
  @git_user_name    = "some-user"

  if File.directory?("tmp/github-project")
    run_simple "cp -r ../#{@git_project_type} #{@git_project_name}", false
    cd(@git_project_name)
  else
    run_simple "git init #{@git_project_name}", false
    cd(@git_project_name)

    %{
      touch me
      git add me
      git commit -m me

      git remote add origin "git@github.com:#{@git_user_name}/#{@git_project_name}.git"

      git checkout -b your_branch
      git branch --track origin/your_branch

      touch yourself
      git add yourself
      git commit -m yourself
    }.each_line do |command|
      run_simple command, false
    end

    cd("..")
    run_simple "cp -a #{@git_project_name} ../#{@git_project_type}", false
    cd(@git_project_name)
  end
end

When /^I get it `(.*?)`$/ do |git_it_command|
  run_simple "git it --test #{git_it_command}", false
end

Then /^it should fail with "(.*?)"$/ do |error_message|
  stderr_from( @commands.last ).should match error_message
end

Then /^it should launch "(.*?)"$/ do |something_to_launch|
  stdout_from( @commands.last ).should match /Launchy.open\( #{something_to_launch.inspect} \)/
end
