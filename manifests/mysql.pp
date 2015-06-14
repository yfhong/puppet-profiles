# == Class: profiles::mysql
#
# MySQL node specification.
#
# === Parameters
#
# [*root_password*]
#   defaults: ResetMe!
#   You should setup a strong enough password for user 'root'
#
class profiles::mysql {

  $root_password = hiera('profiles::mysql::root_password', 'ResetMe!')
  $options = hiera_hash('profiles::mysql::options', {})

  class { '::mysql::server':
    # remove all default accounts except root.
    remove_default_accounts => true,
    # set a strong password for root.
    root_password           => "${root_password}",
    # set options in my.cnf
    override_options        => $options,
  }
}
