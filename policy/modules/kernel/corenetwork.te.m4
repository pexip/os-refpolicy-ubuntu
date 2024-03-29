#
# shiftn(num,list...)
#
# shift the list num times
#
define(`shiftn',`ifelse($1,0,`shift($*)',`shiftn(decr($1),shift(shift($*)))')')

#
# build_option(option_name,true,[false])
#
# makes an ifdef.  hacky quoting changes because with
# regular quoting, the macros in $2 and $3 will not be expanded
#
define(`build_option',`dnl
changequote([,])dnl
[ifdef(`$1',`]
changequote(`,')dnl
$2
changequote([,])dnl
[',`]
changequote(`,')dnl
$3
changequote([,])dnl
[')]
changequote(`,')dnl
')

define(`declare_netifs',`dnl
netifcon $2 gen_context(system_u:object_r:$1,$3) gen_context(system_u:object_r:unlabeled_t,$3)
ifelse(`$4',`',`',`declare_netifs($1,shiftn(3,$*))')dnl
')

#
# network_interface(if_name,linux_interface,mls_sensitivity)
#
define(`network_interface',`
gen_require(``type unlabeled_t;'')
type $1_netif_t alias netif_$1_t, netif_type;
declare_netifs($1_netif_t,shift($*))
')

define(`network_interface_controlled',`
ifdef(`__network_enabled_declared__',`',`
## <desc>
## <p>
## Enable network traffic on all controlled interfaces.
## </p>
## </desc>
gen_bool(network_enabled, true)
define(`__network_enabled_declared__')
')
gen_require(``type unlabeled_t;'')
type $1_netif_t alias netif_$1_t, netif_type;
declare_netifs($1_netif_t,shift($*))
')

define(`declare_nodes',`dnl
nodecon $3 $4 gen_context(system_u:object_r:$1,$2)
ifelse(`$5',`',`',`declare_nodes($1,shiftn(4,$*))')dnl
')

#
# network_node(node_name,mls_sensitivity,address,netmask[, mls_sensitivity,address,netmask, [...]])
#
define(`network_node',`
type $1_node_t alias node_$1_t, node_type;
declare_nodes($1_node_t,shift($*))
')

define(`declare_ports',`dnl
ifelse(eval($3 < 1024),1,`
typeattribute $1 reserved_port_type;
#bindresvport in glibc starts searching for reserved ports at 600
ifelse(eval($3 >= 600),1,`typeattribute $1 rpc_port_type;',`dnl')
',`dnl')
portcon $2 $3 gen_context(system_u:object_r:$1,$4)
ifelse(`$5',`',`',`declare_ports($1,shiftn(4,$*))')dnl
')

#
# network_port(port_name,protocol portnum mls_sensitivity [,protocol portnum mls_sensitivity[,...]])
#
define(`network_port',`
type $1_port_t, port_type;
type $1_client_packet_t, packet_type, client_packet_type;
type $1_server_packet_t, packet_type, server_packet_type;
declare_ports($1_port_t,shift($*))
')

#
# network_packet(packet_name)
#
define(`network_packet',`
type $1_client_packet_t, packet_type, client_packet_type;
type $1_server_packet_t, packet_type, server_packet_type;
')
