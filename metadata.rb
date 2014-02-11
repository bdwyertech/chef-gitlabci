name             'gitlabci'
maintainer       'Christoph Hartmann'
maintainer_email 'chris@lollyrock.com'
license          'Apache 2'
description      'Installs/Configures GitLab CI'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

recipe "gitlabci::install", "Installation"
recipe "gitlabci::runner", "Installation of a runner"

%w{apt database docker git magic_shell mysql nginx phantomjs postgresql redisio ruby_build rvm yum yum-epel}.each do |dep|
  depends dep
end

%w{ubuntu centos}.each do |os|
  supports os
end
