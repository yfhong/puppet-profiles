# == Class: profiles::elasticsearch
#
# Tomcat instance node specification.
#
# === Parameters
#
# [*options*]
#   defaults: false
#   lookup value in hieradata, it's a hash
#   profiles::elasticsearch::options:
#     clutername: 'escluster_cluster'
#
class profiles::elasticsearch {

  $options = hiera_hash('profiles::elasticsearch::options', undef)

  class { '::java':
    package => 'java-1.8.0-openjdk-devel',
  }

  class { '::elasticsearch':
    init_defaults => {
      'ES_USER'      => 'elasticsearch',
      'ES_GROUP'     => 'elasticsearch',
      'ES_HEAP_SIZE' => '4g',
    },
    datadir => '/srv/elasticsearch',
    config  => {
      'cluster.name' => 'escluster_open_komect_net',
    },
  }

  ::elasticsearch::instance { "${::hostname}":
    config => {
      'node.name' => "${::hostname}",
    },
  }

  ::elasticsearch::template { 'logstash-default-template-enhanced':
    file => 'puppet:///modules/profiles/elasticsearch/logstash_enhanced.json',
  }
}
