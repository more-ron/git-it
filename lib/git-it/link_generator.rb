module GitIt
  # Link generator compatible with GitHub like site UI
  class LinkGenerator

    # git@github.com:more-ron/git-it.git
    attr_reader :repository_url

    # all you need is the repository url
    def initialize(repository_url)
      @repository_url = repository_url

      @repo = /^git@(.*):(.*)\/(.*).git$/.match(@repository_url)

      @site = @repo[1]
      @user = @repo[2]
      @proj = @repo[3]
    end

    # https://github.com/more-ron/git-it/tree/gh-pages
    def branch_link(branch_name)
      "https://#{@site}/#{@user}/#{@proj}/tree/#{branch_name}"
    end

    # https://github.com/more-ron/git-it/compare/master...gh-pages
    def compare_branches_link(to, from = "master")
      "https://#{@site}/#{@user}/#{@proj}/compare/#{from}...#{to}"
    end

    # https://github.com/more-ron/git-it/pull/new/more-ron:master...gh-pages
    def pull_request_link(source, destination = "master")
      "https://#{@site}/#{@user}/#{@proj}/pull/new/#{@user}:#{destination}...#{source}"
    end

  end
end
