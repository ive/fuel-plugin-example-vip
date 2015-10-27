notice('MODULAR: deploy-example-vip-override.pp')

$vip_plugin    = hiera('example_vip', {})
$metadata      = pick($vip_plugin['metadata'], {})

$hiera_dir     = '/etc/hiera/override'
$plugin_yaml   = 'example_vip.yaml'
$plugin_name   = 'example_vip'
$role          = hiera('role', 'none')

if $metadata['enabled'] {
  $corosync_roles=['primary-example_vip', 'example_vip']
  $content = inline_template('
corosync_roles:
<%
@corosync_roles.each do |crole|
%>  - <%= crole %>
<% end -%>
')

  file { '/etc/hiera/override':
    ensure  => directory,
  }

  file { "${hiera_dir}/${plugin_yaml}":
    ensure  => file,
    content => $content,
    require => File['/etc/hiera/override'],
  }

  file_line {"${plugin_name}_hiera_override":
    path  => '/etc/hiera.yaml',
    line  => "  - override/${plugin_name}",
    after => '  - override/module/%{calling_module}',
  }
}
