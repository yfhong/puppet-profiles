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
#   'exampleuser':
#     password: 'resetme!'
# profiles::mysql::databases:
#   'exampledb':
#     charset: 'utf8'
#     collate: 'utf8_general_ci'
#     owner: 'exampleuser'


class profiles::mysql {

  $root_password = hiera('profiles::mysql::root_password', 'ResetMe!')
  $options = hiera_hash('profiles::mysql::options', {})
  $mysql_users = hiera_hash('profiles::mysql::users', undef)
  $mysql_databases = hiera_hash('profiles::mysql::databases', undef)

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
      ensure_resource('mysql_user', "${key}@%", $mysql_user_resource)
    }
  }

  if ($mysql_databases) {
    $mysql_databases.each |$key, $value| {
      $db_charset = $value['charset'] or 'utf8'
      $db_collate = $value['collate'] or 'utf8_general_ci'
      $mysql_database_resource = {
        ensure  => present,
        charset => $db_charset,
        collate => $db_collate,
        provider => 'mysql',
        require => Mysql_user["${value['owner']}"],
      }
      ensure_resource('mysql_database', $key, $mysql_database_resource)

      $mysql_grant_resource = {
        ensure     => present,
        options    => ['GRANT'],
        privileges => 'ALL',
        table      => "${key}.*",
        user       => "${value['owner']}",
        require    => Mysql_user["${value['owner']}"]
      }
      ensure_resource('mysql_grant', "${value['owner']}@%/${key}.*", $mysql_grant_resource)
    }
  }
}
