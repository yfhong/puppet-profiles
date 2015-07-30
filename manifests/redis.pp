# == Class: profiles::redis
#
# Redis node specification.
#
# === Parameters
#
# [*maxmem*]
#   defaults: 4gb
#   maximum memory could be used by redis.
# [*password*]
#   defaults: ResetMe!
#   You should setup a strong enough password.
#
class profiles::redis {
  $maxmem = hiera('profiles::redis::maxmem', '4gb')
  $password = hiera('profiles::redis::password', undef)
  $port = hiera('profiles::redis::port', '6379')

  if ($password) {
    class { '::redis':
      conf_bind        => '0.0.0.0',
      conf_maxmemory   => "${maxmem}",
      conf_requirepass => "${password}",
      conf_port        => "${port}",
    }
  }
  else {
    class { '::redis':
      conf_bind        => '0.0.0.0',
      conf_maxmemory   => "${maxmem}",
      conf_port        => "${port}",
    }
  }

  class { '::collectd::plugin::redis':
    nodes => {
      nodelocal => {
        host => 'localhost',
        port => "${port}",
      },
    }
  }
}
