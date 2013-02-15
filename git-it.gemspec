# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','git-it','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'git-it'
  s.version = GitIt::VERSION
  s.author = 'MoreRon'
  s.email = 'more.ron.too@gmail.com'
  s.homepage = 'http://more-ron.github.com/git-it/'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Commands to help you git it.'
# Add your other files here if you make them
  s.files = %w(
bin/git-it
lib/git-it/controller.rb
lib/git-it/global_helper.rb
lib/git-it/version.rb
lib/git-it.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','git-it.rdoc']
  s.rdoc_options << '--title' << 'git-it' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'git-it'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.5.4')
  s.add_runtime_dependency('rugged', '~>0.17.0.b7')
end
