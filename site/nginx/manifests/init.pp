class nginx (
	Optional[String] $root = undef
)
{
	$nginxUser = $facts['osfamily'] ? {
		'Debian' => 'www-data',
		'windows' => 'nobody',
		default => 'nginx',
	}
	$docRoot = pick($root, $deafultDocRoot)
	File {
		owner => 'root',
		group => 'root',
		mode => '0644',
	}

	package { 'nginx':
		ensure => present,
	}
	
	file { $docRoot:
		ensure => directory,
	}
	
	file { "${docRoot}/index.html":
		ensure => file,
		source => 'puppet:///modules/nginx/index.html',
	}
	
	file { 'nginx.conf':
		ensure => file,
		path => '/etc/nginx/nginx.conf',
		content => epp('nginx/nginx.conf.epp', {
			nginxUser => $nginxUser,
			logDir => $logDir,
			configDir => $configDir,
			serverBlock => $serverBlock,
		}),
		require => Package['nginx'],
	}
	
	file { 'default.conf':
		ensure => file,
		path => '/etc/nginx/conf.d/default.conf',
		content => epp('nginx/default.conf.epp', {
			port => $port,
			docRoot => $docRoot,			
		}),
		require => Package['nginx'],
	}
	
	file { 'puppet.png':
		ensure => file,
		require => Package['nginx'],
		path => "${docRoot}/puppet.png",
		source => 'puppet:///modules/nginx/puppet.png',
	}
	
	service { 'nginx':
		ensure => running,
		enable => true,
		subscribe => File['nginx.conf', 'default.conf'],
	}
}
