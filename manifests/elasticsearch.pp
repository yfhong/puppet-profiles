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
#     init_defaults:
#       ES_USER: 'elasticsearch'
#       ES_GROUP: 'elasticsearch'
#       ES_HEAP_SIZE: '4g'
#     datadir: '/srv/elasticsearch'
#
class profiles::elasticsearch {

  class { '::java':
    package => 'java-1.8.0-openjdk-devel',
  }

  include '::elasticsearch'
}
