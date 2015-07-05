# == Class: profiles::collectd
#
# Redis node specification.
#
# === Parameters
#
class profiles::collectd {

  ::collectd::plugin { 'cpu-aggregation':
    include collectd::params
    $conf_dir = $collectd::params::plugin_conf_dir
    $root_group = $collectd::params::root_group
    $order = '10'
    $content = template('profiles/collectd/aggregation-cpu.conf.erb')

    file { "aggregation-cpu.load":
      ensure  => $ensure,
      path    => "${conf_dir}/${order}-aggregation-cpu.conf",
      owner   => root,
      group   => $root_group,
      mode    => '0640',
      content => template('collectd/loadplugin.conf.erb'),
      notify  => Service['collectd'],
    }

    # Older versions of this module didn't use the "00-" prefix.
    # Delete those potentially left over files just to be sure.
    file { "older_${plugin}.load":
      ensure => absent,
      path   => "${conf_dir}/aggregation-cpu.conf",
      notify => Service['collectd'],
    }

    # Older versions of this module use the "00-" prefix by default.
    # Delete those potentially left over files just to be sure.
    if $order != '00' {
      file { "old_${plugin}.load":
        ensure => absent,
        path   => "${conf_dir}/00-aggregation-cpu.conf",
        notify => Service['collectd'],
      }
    }
  }
}
