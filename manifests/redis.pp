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
  $password = hiera('profiles::redis::password', 'ResetMe!')

  class { '::redis':
    conf_bind        => "${::ipaddress}",
    conf_maxmemory   => "${maxmem}",
    conf_requirepass => "${password}",
  }
}
