# Package
if platform_family?('ubuntu')
  packages = %w{
   wget curl gcc checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libreadline6-dev libc6-dev libssl-dev libmysql++-dev make build-essential zlib1g-dev openssh-server git-core libyaml-dev postfix libpq-dev libicu-dev redis-server
  }
elsif platform_family?('rhel')
  # => If your using Percona MySQL, you need to drop mysql-devel and substitute the Percona equivalent... Percona-Server-devel
  packages = %w{
  	wget curl libicu-devel libxslt-devel libyaml-devel libxml2-devel gdbm-devel libffi-devel zlib-devel openssl-devel
    libyaml-devel readline-devel curl-devel openssl-devel pcre-devel mysql-devel git gcc-c++
    ImageMagick-devel ImageMagick
  }
else
  # not yet implemented
  packages = %w{
  }
end

default['gitlabci']['packages'] = packages

# => GitLab CI Repo
default['gitlabci']['repository'] = 'https://github.com/gitlabhq/gitlab-ci.git'

# => Ruby Version
default['gitlabci']['ruby'] = '2.0.0-p247' if platform_family?('ubuntu')
default['gitlabci']['ruby'] = '2.0.0-p353' if platform_family?('rhel')

# => Gems
default['gitlabci']['bundle_install'] = "bundle install --path=.bundle --deployment"

# => Default environment stuff... Can set this in enironment recipes as well.
default['gitlabci']['env'] = 'production'
default['gitlabci']['host'] = 'localhost'
default['gitlabci']['port'] = '80'

# => Use NginX Repo rather than EPEL for latest NginX RPM
default['nginx']['repo_source'] = 'nginx'

# => SSL Stuff
# => If you enable SSL, you have to configure a certificate and key...
default['gitlabci']['ssl_enabled'] = false

# => NginX SSL Certificate Stuff
default['gitlabci']['ssl_certificate_path'] = '/etc/ssl' # Path to .crt file. If it directory doesn't exist it will be created
default['gitlabci']['ssl_certificate_key_path'] = '/etc/ssl' # Path to .key file. If directory doesn't exist it will be created
default['gitlabci']['ssl_certificate'] = "" # SSL certificate
default['gitlabci']['ssl_certificate_key'] = "" # SSL certificate key