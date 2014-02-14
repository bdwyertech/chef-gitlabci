# => Junk Code


#if platform_family?('rhel')
#  include_recipe 'rvm::user'
#  node.default['rvm']['user_installs'] = [
#    { 'user'          => gitlabci['user'],
#      'default_ruby'  => gitlabci['ruby']
#  }
#]
#  execute "Install Ruby" do
#    command <<-EOS
#    curl -sSL https://get.rvm.io | bash -s stable --ruby=#{gitlabci['ruby']}
#    source /etc/profile
#    gem install chef
#    EOS
#  end

#else



command %Q{
    if ! [[ $(pgrep -u #{gitlabci['user']} | wc -l) > 1 ]]
  	  then
  	  /etc/init.d/gitlab_ci stop >> /dev/null 2>&1
  	  /etc/init.d/gitlab_ci start >> /dev/null 2>&1
    fi
  }