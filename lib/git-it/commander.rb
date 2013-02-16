require 'rugged'

# Grand central station for git it commands
class GitIt::Commander

  # current git repository
  attr_reader :repository

  # current git object
  attr_reader :git_object

  # [global options]
  #   --help::          Show this message
  #   -p, --path=path:: repository path (default: {{present_working_directory}})
  #   -s, --sha=sha::   SHA1 (default: {{current_head}})
  #   --version::       Show gem's version
  def initialize(options)
    @global_options = options
    @repository     = Rugged::Repository.new( get_path(options[:path]) )
    @git_object     = get_object( options[:sha] )
  end



  # ===========
  # = Actions =
  # ===========

  # [get it opened in the web]
  #
  #   Opens closest branch in the web.
  #
  # [commands]
  #
  #   Open present working directory's repository and head in the web:
  #     git it opened_in_the_web
  #
  #   Open specified repository in the path:
  #     git it --path=the/path/to/the/repo opened_in_the_web
  #
  #   Open specified sha1:
  #     git it --sha=50m35ha1 opened_in_the_web
  #
  #   Open specified repository in the path and sha1:
  #     git it --path=the/path/to/the/repo --sha=50m35ha1 opened_in_the_web
  #
  # [notes]
  #
  #   * Currently only supports GitHub.com
  #
  def open_in_the_web(args, options)
    remote_origin_url = repository.config["remote.origin.url"]
    #=> git@github.com:more-ron/git-it.git

    github_link = remote_origin_url.gsub("git@github.com:", "https://github.com/")
    #=> https://github.com/more-ron/git-it.git

    branch_name = closest_remote_branch.name.gsub("origin/", "")
    #=> origin/gh-pages => gh-pages
    branch_name = closest_remote_branch.target.gsub("refs/remotes/origin/", "") if branch_name == "HEAD"
    #=> refs/remotes/origin/master => master

    github_link = github_link.gsub(".git", "/tree/#{ branch_name }")
    #=> https://github.com/more-ron/git-it/tree/master

    `open #{ github_link }` # should use launchy in the future
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
      distance_in_object(:from => branch.tip.oid, :to => @git_object.oid)
    end
  end

  def distance_in_object(options = {})
    normal_direction_value   = _distance_in_object(options)
    opposite_direction_value = _distance_in_object(:from => options[:to], :to => options[:from])

    [normal_direction_value, opposite_direction_value].max
  end

  def _distance_in_object(options = {})
    walker = Rugged::Walker.new(repository)
    walker.push(options[:to])
    walker.hide(options[:from])
    walker.count
  end

end
