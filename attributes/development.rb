# user
default['gitlabci']['development']['user'] = 'vagrant'
default['gitlabci']['development']['group'] = 'vagrant'
default['gitlabci']['development']['home'] = '/home/vagrant'

# git
default['gitlabci']['development']['revision'] = 'master'
default['gitlabci']['development']['path'] = '/vagrant/gitlab'

# setup environments
default['gitlabci']['development']['environments'] = %w{development test}

# => Link to the actual Gitlab Server
default['gitlabci']['development']['gitlab']['server'] = %w{http://localhost/}
# => Set to true if your using HTTPS on your Gitlab Server
default['gitlabci']['development']['gitlab']['ssl'] = 'false'
