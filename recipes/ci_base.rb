#
# Cookbook Name:: gitlabci
# Recipe:: ci_base
#

gitlabci = node['gitlabci']

# => Merge Environmental Variables
gitlabci = Chef::Mixin::DeepMerge.merge(gitlabci, gitlabci[gitlabci['env']])

# => Update System
include_recipe 'apt' if platform?('ubuntu', 'debian')
include_recipe 'yum' if platform_family?('rhel')

# => Create Gitlab CI System User
user gitlabci['user'] do
  comment 'GitLab CI'
  home gitlabci['home']
  shell '/bin/bash'
  supports :manage_home => true
end

user gitlabci['user'] do
  action :lock
end

# No groupinstall function in yum cookbook, AFAIK. Have to do it this way.
if platform_family?('rhel')
  execute 'Install RHEL Package Group - Development Tools' do
    command <<-EOS
      yum groupinstall -y "Development Tools"
    EOS
  end
end

# => Packages
include_recipe 'apt' if platform?('ubuntu', 'debian')
include_recipe 'yum-epel' if platform_family?('rhel')
include_recipe 'nginx::repo'
include_recipe 'redisio::install'
include_recipe 'redisio::enable'

# => Install Gitlab CI Dependencies
gitlabci['packages'].each do |pkg|
  package pkg
end

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
