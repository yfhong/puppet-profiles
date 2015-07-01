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
#     example:
#       war_name: 'example.war'
#       war_source: '/tmp/example.war'
#
class profiles::tomcat {

  $catalina_home = hiera('profiles::tomcat::catalina_home', '/usr/share/tomcat')
  $applications = hiera_hash('profiles::tomcat::applications', false)

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
    server_config         => "/etc/tomcat/server.xml",
    connector_ensure      => 'present',
    purge_connectors      => true,
    port                  => '8080',
    protocol              => 'org.apache.coyote.http11.Http11NioProtocol',
    additional_attributes => {
      'redirectPort'      => '8443',
      'connectionTimeout' => '20000',
      'URIEncoding'       => 'UTF-8',
    },
    notify                => Tomcat::Service['default'],
  }

  file { '/etc/tomcat/context.xml':
    owner  => 'tomcat',
    group  => 'tomcat',
    backup => true,
    source => 'puppet:///modules/profiles/tomcat-libs/session-jedis.context.xml',
  }

  $session_jedis_libs = [
                         'commons-logging-1.1.3.jar',
                         'commons-pool2-2.2.jar',
                         'jedis-2.6.0.jar',
                         'tomcat-juli.jar',
                         'tomcat-redis-session-manage-tomcat7.jar',
                         ]
  $session_jedis_libs.each |$lib| {
    file { "/usr/share/tomcat/lib/${lib}":
      owner  => 'tomcat',
      group  => 'tomcat',
      backup => true,
      source => "puppet:///modules/profiles/tomcat-libs/${lib}",
    }
  }
  # deploy applications
  if ($applications) {
    create_resources('::tomcat::war', $applications)
  }
}
