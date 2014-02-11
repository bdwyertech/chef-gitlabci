#
# Cookbook Name:: gitlabci
# Recipe:: ci_nginx
#

gitlabci = node['gitlabci']

# merge environmental variables
gitlabci = Chef::Mixin::DeepMerge.merge(gitlabci,gitlabci[gitlabci['env']])

# 7. Nginx
## Installation
package 'nginx' do
  action :install
end

## Site Configuration
path = platform_family?('rhel') ? '/etc/nginx/conf.d/gitlabci.conf' : '/etc/nginx/sites-available/gitlabci'
template path do
  source 'nginx.erb'
  mode 0644
  variables({
    :path => gitlabci['path'],
    :host => gitlabci['host'],
    :port => gitlabci['port'],
    :url => gitlabci['url'],
    :ssl_enabled => gitlabci['ssl_enabled'],
    :ssl_certificate_path => gitlabci['ssl_certificate_path'],
    :ssl_certificate_key_path => gitlabci['ssl_certificate_key_path']
  })
end

if platform_family?('rhel')
  directory gitlabci['home'] do
    mode 0755
  end

  %w( default.conf ssl.conf virtual.conf ).each do |conf|
    file "/etc/nginx/conf.d/#{conf}" do
      action :delete
    end
  end
else
  link '/etc/nginx/sites-enabled/gitlabci' do
    to '/etc/nginx/sites-available/gitlabci'
  end

  file '/etc/nginx/sites-enabled/default' do
    action :delete
  end
end

if gitlabci['ssl_enabled'] == true
  directory "#{gitlabci['ssl_certificate_path']}" do
    recursive true
    mode 0755
  end

  directory "#{gitlabci['ssl_certificate_key_path']}" do
    recursive true
    mode 0755
  end

  file "#{gitlabci['ssl_certificate_path']}/#{gitlabci['host']}.crt" do
    content gitlabci['ssl_certificate']
    mode 0600
  end

  file "#{gitlabci['ssl_certificate_key_path']}/#{gitlabci['host']}.key" do
    content gitlabci['ssl_certificate_key']
    mode 0600
  end
end

# => Restart NginX
service 'nginx' do
  action [:start, :enable]
end
