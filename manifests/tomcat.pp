# == Class: profiles::tomcat
#
# Tomcat instance node specification.
#
# === Parameters
#
# [*catalina_home*]
#   defaults: '/usr/share/tomcat'
#   lookup value in hieradata, in case the package install in different path.
# [*applications*]
#   defaults: false
#   lookup value in hieradata, it's a array, but usually should set only one application.
#   profiles::tomcat::applications:
#     - name: example
#       source: '/tmp/example.war'
#
class profiles::tomcat {

  $catalina_home = hiera('profiles::tomcat::catalina_home', '/usr/share/tomcat')
  $applications = hiera_array('profiles::tomcat::applications', false)

  # alway install tomcat from system package repositories.
  class { '::tomcat':
    install_from_source => false,
    catalina_home       => "${catalina_home}",
  }

  # config the service, should always use system initial script.
  ::tomcat::service { 'default':
    use_jsvc       => false,
    use_init       => true,
    service_name   => 'tomcat',
    service_ensure => 'running',
  }

  ::tomcat::config::server::connector { 'tomcat-main-connector':
    catalina_base         => "${catalina_home}",
    port                  => '8080',
    protocol              => 'org.apache.coyote.http11.Http11NioProtocol',
    additional_attributes => {
      'redirectPort'      => '8443',
      'connectionTimeout' => '20000',
      'URIEncoding'       => 'UTF-8',
    },
    connector_ensure => 'present',
    server_config         => "/etc/tomcat/server.conf"
    notify => Tomcat::Service['default'],
  }

  # deploy applications
  if ($applications and validate_hash($applications)) {
    $applications.each |$entry| {
      ::tomcat::war { "${entry['name']}":
        war_name   => "${entry['name']}.war",
        war_source => "${entry['source']}",
      }
    }
  }
}
