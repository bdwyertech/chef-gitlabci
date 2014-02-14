#
# Cookbook Name:: gitlabci
# Recipe:: server
#

gitlabci = node['gitlabci']

# merge environmental variables
gitlabci = Chef::Mixin::DeepMerge.merge(gitlabci,gitlabci[gitlabci['env']])

# Make sure we have all common paths included in our environment
magic_shell_environment 'PATH' do
	value '/usr/local/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin'
end

include_recipe 'gitlabci::ci_base'
include_recipe "gitlabci::db_#{gitlabci['database_adapter']}"
include_recipe 'gitlabci::ci_server'
include_recipe 'gitlabci::ci_nginx' if gitlabci['env'] == 'production'
