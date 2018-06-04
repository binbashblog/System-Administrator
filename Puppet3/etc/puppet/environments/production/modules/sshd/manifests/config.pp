
class sshd::config {
        $allowusers = $sshd::params::allowusers
        file { $sshd::params::config_file:
                ensure  => present,
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                content => template('sshd/sshd_config.erb'),
                require => Class['sshd::install'],
                notify  => Class['sshd::service'],
        }

}
