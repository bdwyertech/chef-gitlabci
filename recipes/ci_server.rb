#
# Cookbook Name:: gitlabci
# Recipe:: ci_server
#

gitlabci = node['gitlabci']

# merge environmental variables
gitlabci = Chef::Mixin::DeepMerge.merge(gitlabci,gitlabci[gitlabci['env']])

# clone the source
git gitlabci['path'] do
  repository gitlabci['repository']
  revision gitlabci['revision']
  user gitlabci['user']
  group gitlabci['group']
  action :sync
end

# copy the gitlab ci application config
template File.join(gitlabci['path'], 'config', 'application.yml') do
  source 'application.yml.erb'
  user gitlabci['user']
  group gitlabci['group']
  variables({
    :server => gitlabci['gitlab']['server'],
    :https => gitlabci['gitlab']['ssl']
  })
end

# gitlab puma config
template File.join(gitlabci['path'], 'config', 'puma.rb') do
  source 'puma.rb.erb'
  user gitlabci['user']
  group gitlabci['group']
  variables({
      :path => gitlabci['path'],
      :user => gitlabci['user'],
      :env => gitlabci['env']
  })
end

### make sure gitlab ci can write to the log/ and tmp/ directories
%w{log tmp}.each do |path|
  directory File.join(gitlabci['path'], path) do
    owner gitlabci['user']
    group gitlabci['group']
    mode 0755
  end
end

# create directories for sockets/pids and make sure gitlab ci can write to them
%w{tmp/pids tmp/sockets}.each do |path|
  directory File.join(gitlabci['path'], path) do
    owner gitlabci['user']
    group gitlabci['group']
    mode 0755
  end
end

## Install Gems without ri and rdoc
template File.join(gitlabci['home'], '.gemrc') do
  source 'gemrc.erb'
  user gitlabci['user']
  group gitlabci['group']
  notifies :run, 'execute[bundle install]', :immediately
end

# gem without
bundle_without = []
case gitlabci['database_adapter']
when 'mysql'
  bundle_without << 'postgres'
when 'postgresql'
  bundle_without << 'mysql'
end

case gitlabci['env']
when 'production'
  bundle_without << 'development'
  bundle_without << 'test'
else
  bundle_without << 'production'
end

# => Install Gems
execute 'bundle install' do
  command <<-EOS
  PATH="/usr/local/bin:$PATH"
  #{gitlabci['bundle_install']} --without #{bundle_without.join(" ")}
  EOS
  cwd gitlabci['path']
  user gitlabci['user']
  group gitlabci['group']
  action :nothing
end

## configure gitlab ci db settings
template File.join(gitlabci['path'], 'config', 'database.yml') do
  source "database.yml.#{gitlabci['database_adapter']}.erb"
  user gitlabci['user']
  group gitlabci['group']
  variables({
    :user => gitlabci['user'],
    :password => gitlabci['database_password']
  })
end

# per environment

### db:setup
gitlabci['environments'].each do |environment|

  log "#{environment}"

  # Setup tables
  execute 'setup tables install' do
    command <<-EOS
    PATH="/usr/local/bin:$PATH"
    bundle exec rake db:setup RAILS_ENV=#{environment}
    EOS
    cwd gitlabci['path']
    user gitlabci['user']
    group gitlabci['group']
  end

  # setup schedules
  execute 'setup schedules' do
    command <<-EOS
    PATH="/usr/local/bin:$PATH"
    bundle exec whenever -w RAILS_ENV=#{environment}
    EOS
    cwd gitlabci['path']
    user gitlabci['user']
    group gitlabci['group']
  end
end

case gitlabci['env']
when 'production'

# => Install Provided Init Script
#  ruby_block 'Configure Init Script' do
#    block do
#      resource = Chef::Resource::File.new('gitlab_init', run_context)
#      resource.path '/etc/init.d/gitlab_ci'
#      resource.content IO.read(File.join(gitlabci['path'], 'lib', 'support', 'init.d', 'gitlab_ci'))
#      resource.mode 0755
#      resource.run_action :create
#      if resource.updated? && gitlabci['env'] == 'production'
#        self.notifies :start, resources(:service => 'gitlab_ci'), :immediately
#      end
#    end
#  end

# => Install init script from template
  template File.join('etc', 'init.d', 'gitlab_ci') do
    source 'initd.erb'
    user 'root'
    group 'root'
    mode '0755'
    variables({
      :user => gitlabci['user'],
      :path => gitlabci['path']
    })
    notifies :start, 'service[gitlab_ci]', :immediately
  end

# => Declare Gitlab CI Service resource
  service 'gitlab_ci' do
    supports :start => true, :stop => true, :restart => true, :status => true
    action :enable
  end
end
