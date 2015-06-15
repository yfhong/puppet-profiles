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
# profiles::mysql::users:
#   'graphite@%':
#     ensure: 'present'
#     password: 'resetme!'
#     tables: '*.*'
#     grants:
#       - CREATE
#       - UPDATE
class profiles::mysql {

  $root_password = hiera('profiles::mysql::root_password', 'ResetMe!')
  $options = hiera_hash('profiles::mysql::options', {})
  $mysql_users = hiera_hash('profiles::mysql::users', undef)

  class { '::mysql::server':
    # remove all default accounts except root.
    remove_default_accounts => true,
    # set a strong password for root.
    root_password           => "${root_password}",
    # set options in my.cnf
    override_options        => $options,
  }

  if ($mysql_users) {
    $mysql_users.each |$key, $value| {

      $mysql_user_resource = {
        ensure                   => present,
        password_hash            => mysql_password($value['password']),
        provider                 => 'mysql',
        max_connections_per_hour => '0',
        max_queries_per_hour     => '0',
        max_updates_per_hour     => '0',
        max_user_connections     => '0',
        require                  => Class['mysql::server'],
      }

      ensure_resource('mysql_user', "${key}", $mysql_user_resource)

      $mysql_user_grant_resource => {
        ensure     => present,
        options    => ['GRANT'],
        privileges => $value['grants'],
        table      => "${value[tables]}",
        user       => "${key}",
      }

      ensure_resource('mysql_grant', "${key}/*.*", $mysql_user_grant_resource)
    }
  }
}
