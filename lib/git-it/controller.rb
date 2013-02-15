require 'rugged'
# require 'debugger'

class GitIt::Controller

  attr_reader :repository
  attr_reader :git_object

  def initialize(options)
    @repository = Rugged::Repository.new( discover_repository )
    @git_object = get_object(options[:sha])
  end

  # ===========
  # = Actions =
  # ===========

  # git it opened_in_browser

  def open_in_browser(args, options)
    remote_origin_url = repository.config["remote.origin.url"]
    # => git@github.com:more-ron/git-it.git

    github_link = remote_origin_url.gsub("git@github.com:", "https://github.com/")
    # => https://github.com/more-ron/git-it.git

    branch_name = closest_remote_branch.target.gsub("refs/remotes/origin/", "")
    # refs/remotes/origin/master => master

    github_link = github_link.gsub(".git", "/tree/#{ branch_name }")
    # => https://github.com/more-ron/git-it/tree/master

    `open #{ github_link }`
  end

  # ============
  # = Privates =
  # ============

  private

  def get_object(sha)
    if sha == "{{current_head}}"
      repository.lookup( repository.head.target )
    else
      repository.lookup( sha )
    end
  end

  def discover_repository
    Rugged::Repository.discover( Dir.pwd )
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
