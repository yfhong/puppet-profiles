# == Class: profiles::keepalived
#
# Keepalived node specification.
#
# === Parameters
#
# [*root_password*]
#   defaults: ResetMe!
#   You should setup a strong enough password for user 'root'
#
# keepalived::global_defs::ensure: 'present'
# keepalived::global_defs::notification_email: 'admin@lvs0.example.net'
# keepalived::global_defs::notification_email_from: 'admin@proxy0.example.net'
# keepalived::global_defs::smtp_server: 'localhost'
# keepalived::global_defs::smtp_connect_timeout: '60'
# keepalived::global_defs::router_id: 'router_0'
# profiles::keepalived::vrrp_instances:
#   'VI_1':
#     interface: 'eth0'
#     state: 'MASTER'
#     virtual_router_id: 1
#     priority: 101
#     auth_type: 'PASS'
#     auth_pass: 'secret'
#     virtual_ipaddress:
#       - '192.168.100.1/24'
#     track_interface:
#       - 'eth0'
#   'VI_2':
#     interface: 'eth0'
#     state: 'BACKUP'
#     virtual_router_id: 2
#     priority: 50
#     auth_type: 'PASS'
#     auth_pass: 'secret'
#     virtual_ipaddress:
#       - '192.168.100.2/24'
#     track_interface:
#       - 'eth0'
#
class profiles::keepalived {

  $vrrp_instances = hiera_hash('profiles::keepalived::vrrp_instances', undef)

  include '::keepalived'
  include '::keepalived::global_defs'

  if ($vrrp_instances) {
    create_resources('::keepalived::vrrp::instance', $vrrp_instances)
  }
}
