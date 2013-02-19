require 'rugged'
require 'launchy'

module GitIt
  # Grand central station for git it commands
  class Commander

    # current git repository
    attr_reader :repository

    # current git object
    attr_reader :git_object

    # [global options]
    #
    #   --help::          Show this message
    #   -p, --path=path:: repository path (default: {{present_working_directory}})
    #   -s, --sha=sha::   SHA1 (default: {{current_head}})
    #
    # [sample usage]
    #
    #   Open present working directory's repository branch:
    #     git it opened
    #
    #   Open specified repository in the path:
    #     git it --path=the/path/to/the/repo opened
    #
    #   Open specified sha1:
    #     git it --sha=50m35ha1 opened
    #
    #   Open specified repository in the path and sha1:
    #     git it --path=the/path/to/the/repo --sha=50m35ha1 opened
    #
    def initialize(options)
      @global_options = options
      @repository     = Rugged::Repository.new( get_path(options[:path]) )
      @git_object     = get_object( options[:sha] )
      @test_mode      = options[:test]

      @url_generator = UrlGenerator.new( @repository.config["remote.origin.url"] )
    end



    # ===========
    # = Actions =
    # ===========

    # [get it opened]
    #
    #   Opens the current branch
    #
    # [sample usage]
    #
    #   Open the current branch:
    #     git it opened
    #
    def open(args, options)
      _closest_branch = closest_branch

      if _closest_branch
        branch_name = clean_branch_name_for( _closest_branch )
        link        = @url_generator.branch_url( branch_name )

        launch link
      else
        fail "Could not find closest remote branch for sha: #{@git_object.oid.inspect}"
      end
    end

    # [get it compared]
    #
    #   Compares the current branch to another branch (default: master)
    #
    # [sample usage]
    #
    #   Compare the current branch to master branch
    #     git it compared
    #
    #   Compare the current branch to release branch
    #     git it compared --to=release
    #
    def compare(args, options)
      _closest_branch = closest_branch

      if _closest_branch
        branch_name = clean_branch_name_for( _closest_branch )
        link        = @url_generator.compare_branches_url( branch_name, options[:to] || "master" )

        launch link
      else
        fail "Could not find closest remote branch for sha: #{@git_object.oid.inspect}"
      end
    end

    # [get it pulled]
    #
    #   Issues a pull request of the current branch into another branch (default: master)
    #
    # [sample usage]
    #
    #   Issue a pull request of the current branch into master branch
    #     git it pulled
    #
    #   Issue a pull request of the current branch into release branch
    #     git it pulled --to=release
    #
    def pull(args, options)
      _closest_branch = closest_branch

      if _closest_branch
        branch_name = clean_branch_name_for( _closest_branch )
        link        = @url_generator.pull_request_url( branch_name, options[:to] || "master" )

        launch link
      else
        fail "Could not find closest remote branch for sha: #{@git_object.oid.inspect}"
      end
    end



    # ============
    # = Privates =
    # ============

    private

    def get_path(path)
      path == "{{present_working_directory}}" ? Dir.pwd : path
    end

    def get_object(sha)
      if sha == "{{current_head}}"
        repository.lookup( repository.head.target )
      else
        repository.lookup( sha )
      end
    end

    def discover_repository(path)
      Rugged::Repository.discover( path )
    end

    def remote_branches
      @remote_branches ||= Rugged::Branch.each_name(repository, :remote).sort.collect do |branch_name|
        Rugged::Branch.lookup(@repository, branch_name, :remote)
      end
    end

    def local_branches
      @local_branches ||= Rugged::Branch.each_name(repository, :local).sort.collect do |branch_name|
        Rugged::Branch.lookup(@repository, branch_name)
      end
    end

    def closest_remote_branch
      remote_branches.min_by do |branch|
        distance_in_objects(:from => branch.tip.oid, :to => @git_object.oid)
      end
    end

    def closest_local_branch
      local_branches.min_by do |branch|
        distance_in_objects(:from => branch.tip.oid, :to => @git_object.oid)
      end
    end

    def closest_branch
      closest_local_branch || closest_remote_branch
    end

    def clean_branch_name_for( branch )
      branch_name = branch.name.gsub("origin/", "")
      #=> origin/gh-pages => gh-pages

      branch_name = branch.target.gsub("refs/remotes/origin/", "") if branch_name == "HEAD"
      #=> refs/remotes/origin/master => master

      branch_name
    end

    def distance_in_objects(options = {})
      normal_direction_value   = _distance_in_objects(options)
      opposite_direction_value = _distance_in_objects(:from => options[:to], :to => options[:from])

      [normal_direction_value, opposite_direction_value].max
    end

    def _distance_in_objects(options = {})
      walker = Rugged::Walker.new(repository)
      walker.push(options[:to])
      walker.hide(options[:from])
      walker.count
    end

    def test_mode?
      @test_mode
    end

    def launch(what)
      if test_mode?
        puts "Launchy.open( #{what.inspect} )"
      else
        Launchy.open( what )
      end
    end

  end
end
