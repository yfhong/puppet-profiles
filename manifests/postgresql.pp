# == Class: profiles::postgresql
#
# PostgreSQL node specification.
#
# === Parameters
#
# [*postgres_password*]
#   defaults: ResetMe!
#   You should setup a strong enough password for user 'postgres'
#
# profiles::postgresql::dbs:
#   'exampledb':
#     password: 'resetme!'
#     user: 'exampleuser'
#     owner: 'exampleuser'
#
class profiles::postgresql {

  $postgres_password = hiera('profiles::postgresql::postgres_password', 'ResetMe!')
  $options = hiera_hash('profiles::postgresql::options', {})
  $postgresql_dbs = hiera_hash('profiles::postgresql::dbs', undef)

  class { '::postgresql::globals':
    encoding => 'UTF-8',
    locale   => 'en_US.UTF-8',
    confdir  => '/etc/postgresql',
  } ->
  class { '::postgresql::server':
    listen_addresses           => '*',
    ip_mask_deny_postgres_user => '0.0.0.0/0',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    confdir                    => '/etc/postgresql',
    datadir                    => '/srv/pgsql/data',
    xlogdir                    => '/srv/pgsql/data/pg_xlog',
    logdir                     => '/srv/pgsql/data/pg_log',
    needs_initdb               => true,
  }

  include '::postgresql::server::contrib'

  if ($postgresql_dbs) {
    create_resources('::postgresql::server::db', $postgresql_dbs)
  }

}
