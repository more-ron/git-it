require 'spec_helper'

module GitIt
  describe UrlGenerator do

    subject { UrlGenerator.new( repository_url ) }

    let( :repository_url ){ "git@github.com:more-ron/git-it.git" }

    let( :current_branch ){ "current_branch" }

    let( :other_branch ){ "other_branch" }

    describe "#branch_url" do
      it "should return the url" do
        subject.branch_url( current_branch ).should == "https://github.com/more-ron/git-it/tree/current_branch"
      end
    end

    describe "#compare_branches_url" do
      it "should return the url to compare page" do
        subject.compare_branches_url( current_branch ).should == "https://github.com/more-ron/git-it/compare/master...current_branch"
      end

      context "when comparing to other branch" do
        it "should return the url to compare page" do
          subject.compare_branches_url( current_branch, other_branch ).should == "https://github.com/more-ron/git-it/compare/other_branch...current_branch"
        end
      end
    end

    describe "#pull_request_url" do
      it "should return the url to pull request page" do
        subject.pull_request_url( current_branch ).should == "https://github.com/more-ron/git-it/pull/new/more-ron:master...current_branch"
      end


      context "when comparing into other branch" do
        it "should return the url to pull request page" do
          subject.pull_request_url( current_branch, other_branch ).should == "https://github.com/more-ron/git-it/pull/new/more-ron:other_branch...current_branch"
        end
      end
    end

    describe "#test_url" do
      it "should return the url" do
        subject.test_url( current_branch ).should == "https://circleci.com/gh/more-ron/git-it/tree/current_branch"
      end
    end

  end
end

