# == Class: profiles::collectd
#
# Redis node specification.
#
# === Parameters
#
class profiles::collectd {

  ::collectd::plugin { 'aggregation':
    content => template('profiles/collectd/aggregation-cpu.conf.erb')
  }
}
