GitLab CI Cookbook
===============

Chef to install GitLab CI on CentOS 6.5

* GitLab CI: 4-2-stable 
* GitLab CI Runner: IN PROGRESS

This cookbook is a fork of Christoph Hartmann's original, intended for Ubuntu.  I have adapted it for use in an RHEL environment.
Warning: This cookbook is under development.  It is being developed with Vagrant, VMware and CentOS.  It will *probably* work in other RHEL 6.* based environments. 

* NOTES

## Requirements

* [Berkshelf](http://berkshelf.com/)
* [Vagrant](http://www.vagrantup.com/)

### Vagrant Plugin

* [vagrant-berkshelf](https://github.com/RiotGames/vagrant-berkshelf)
* [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus)

### Platform:

#### Gitlab CI
* CentOS (6.5)

#### Gitlab CI Runner
* IN PROGRESS

## Usage

Example of node config.

```json
{
  "mysql": {
    "server_root_password": "rootpass",
    "server_repl_password": "replpass",
    "server_debian_password": "debianpass"
  },
  "gitlabci": {
    "database_adapter": "mysql",
    "database_password": "datapass",
    "env" : "production"
  },
  "run_list":[
    "gitlabci::server"
  ]
}
```

## Links

* [GitLab CI Installation](https://github.com/gitlabhq/gitlab-ci/blob/master/doc/installation.md)
* [Gitlab Cookbook](https://github.com/ogom/cookbook-gitlab)

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

Authors: Christoph Hartmann
         Brian Dwyer - Updated & Adapted for RHEL

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
