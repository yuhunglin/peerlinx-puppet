include git

group { 'puppet':
  ensure => present,
}

include apt::backports

apt::source { 'squeeze-pgdg':
  location          => 'http://apt.postgresql.org/pub/repos/apt/',
  release           => 'squeeze-pgdg',
  repos             => 'main',
  required_packages => 'debian-keyring debian-archive-keyring',
  key               => 'ACCC4CF8',
  # key_server        => 'subkeys.pgp.net',
  # pin               => '-10',
  include_src       => false,
}
exec { 'apt-get update':
  command => '/usr/bin/apt-get update',
}

# Ruby/rbenv
rbenv::install { "vagrant": }
rbenv::compile { "2.0.0-p195":
  user => "vagrant",
  global => true,
}
rbenv::gem { "rake":
  user => "vagrant",
  ruby => "2.0.0-p195",
}
rbenv::gem { "unicorn":
  user => "vagrant",
  ruby => "2.0.0-p195",
}
# rbenv::plugin::rbenvvars { "vagrant":
#   source => "git://path-to-your/custom/rbenv-vars.git"
# }


#Postgres
class { 'postgresql':
  version => '9.2',
  require => Exec['apt-get update'],
}
class { 'postgresql::server':
  config_hash => {
    'ip_mask_deny_postgres_user' => '0.0.0.0/32',
    'ip_mask_allow_all_users'    => '0.0.0.0/0',
    'listen_addresses'           => '*',
    'manage_pg_hba_conf'         => true,
    'postgres_password'          => 'foo',
  },
}
postgresql::db { 'peerlinx_development':
  user => 'peerlinx_development',
  password => 'secret',
}


package { 'nginx':
  ensure => present,
  require => Exec['apt-get update'],
}

file { 'default-nginx-disable':
  path => '/etc/nginx/sites-enabled/default',
  ensure => absent,
  require => Package['nginx'],
}

service { 'nginx':
  ensure => running,
  require => Package['nginx'],
}

# class { "puppet-rbenv":
#   user         => "vagrant",
#   compile      => true,
#   version => "2.0.0-p195"
# }

# file { 'vagrant-nginx':
#   path => '/etc/nginx/sites-available/vagrant',
#   ensure => file,
#     replace => true,
#   require => Package['nginx'],
#   source => 'puppet:///etc/nginx/vagrant',
#     notify => Service['nginx'],
# }