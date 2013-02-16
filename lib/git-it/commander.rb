require 'rugged'
# require 'debugger'

# Grand central station for git it commands
class GitIt::Commander

  attr_reader :repository
  attr_reader :git_object

  # Global Options::
  # * --help          - Show this message
  # * -p, --path=path - repository path (default: {{present_working_directory}})
  # * -s, --sha=sha   - SHA1 (default: {{current_head}})
  # * --version       - Show gem's version
  def initialize(options)
    @global_options = options
    @repository     = Rugged::Repository.new( get_path(options[:path]) )
    @git_object     = get_object( options[:sha] )
  end


  # ===========
  # = Actions =
  # ===========

  # Command:: git it opened_in_the_web
  def open_in_the_web(args, options)
    remote_origin_url = repository.config["remote.origin.url"]
    # => git@github.com:more-ron/git-it.git

    github_link = remote_origin_url.gsub("git@github.com:", "https://github.com/")
    # => https://github.com/more-ron/git-it.git

    branch_name = closest_remote_branch.name.gsub("origin/", "")
    # origin/gh-pages => gh-pages
    branch_name = closest_remote_branch.target.gsub("refs/remotes/origin/", "") if branch_name == "HEAD"
    # refs/remotes/origin/master => master

    github_link = github_link.gsub(".git", "/tree/#{ branch_name }")
    # => https://github.com/more-ron/git-it/tree/master

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
