#
# Cookbook Name:: gitlabci
# Recipe:: ci_base
#

gitlabci = node['gitlabci']

# => Merge Environmental Variables
gitlabci = Chef::Mixin::DeepMerge.merge(gitlabci, gitlabci[gitlabci['env']])

# => Install Repositories
include_recipe 'yum-epel' if platform_family?('rhel')
include_recipe 'nginx::repo'

# => Update System
include_recipe 'apt' if platform?('ubuntu', 'debian')
include_recipe 'yum' if platform_family?('rhel')

# => Create Gitlab CI System User
user gitlabci['user'] do
  comment 'GitLab CI'
  home gitlabci['home']
  shell '/bin/bash'
  supports :manage_home => true
  action [:create, :lock]
end

# => No groupinstall function in yum cookbook, AFAIK. Have to do it this way.
execute 'Install RHEL Package Group - Development Tools' do
  command <<-EOS
    yum groupinstall -y "Development Tools"
  EOS
  only_if { platform_family?('rhel') }
end

# => Install Gitlab CI Dependencies
gitlabci['packages'].each do |pkg|
  package pkg
end

# => Install latest git and redis
include_recipe 'git'
include_recipe 'redisio::install'
include_recipe 'redisio::enable'

# => Upgrade OpenSSL to prevent bundler issues
package 'openssl' do
  action :upgrade
end

# => Install Ruby
include_recipe 'ruby_build'

# => Download and Compile Ruby
ruby_build_ruby gitlabci['ruby'] do
  prefix_path '/usr/local/'
end

# => Update Ruby Gems
execute 'Update rubygems' do
  command 'gem update --system'
end

# => Install Bundler Gem
gem_package 'bundler' do
  gem_binary '/usr/local/bin/gem'
  options '--no-ri --no-rdoc'
end
