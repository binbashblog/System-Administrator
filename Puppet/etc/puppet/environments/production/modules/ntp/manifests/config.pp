class ntp::config {
        $servers = $ntp::params::servers
        $restrict = $ntp::params::restrict
        file { $ntp::params::config_file:
                ensure  => present,
                owner   => 'root',
                group   => 'root',
                mode    => '0600',
                content => template('ntp/ntp.conf.erb'),
                require => Class['ntp::install'],
                notify  => Class['ntp::service'],
        }

}
