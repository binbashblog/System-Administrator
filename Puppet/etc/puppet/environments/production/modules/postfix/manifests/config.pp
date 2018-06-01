
class postfix::config {
        $postfix_function = $postfix::params::postfix_function
        $smtp_relay = $postfix::params::smtp_relay
        $fallback_smtp_relay = $postfix::params::fallback_smtp_relay
        $mail_alias = $postfix::params::mail_alias

            file { aliases:
                    ensure => present,
                    path  =>  "/etc/aliases",
                    owner =>  "root",
                    group =>  "root",
                    mode  => '0644',
                    content => template('postfix/aliases.erb'),
                    notify => Exec['rebuild-aliases'],
            }

            file { master-conf:
                    ensure => present,
                    path  =>  "/etc/postfix/master.cf",
                    owner =>  "root",
                    group =>  "root",
                    mode  => '0644',
                    source  => ['puppet:///modules/postfix/master.cf'],
                    notify => Exec['reload-postfix'],
            }

            if $postfix_function == 'master' {

                file { master-main-conf:
                       ensure => present,
                       path   => "/etc/postfix/main.cf",
                       owner  => "root",
                       group  => "root",
                       mode   => '0644',
                       require => Package[postfix],
                       content => template('postfix/master-main.cf.erb'),
                       notify => Exec['rebuild-main-config'],
                }
                file { transport:
                       ensure => present,
                       path   => "/etc/postfix/transport",
                       owner  => "root",
                       group  => "root",
                       mode   => '0644',
                       require => Package[postfix],
                       source  => ['puppet:///modules/postfix/transport'],
                       notify => Exec['rebuild-transport'],
                }
            }

            elsif $postfix_function == 'client' {
                file { main-conf:
                       ensure => present,
                       path   => "/etc/postfix/main.cf",
                       owner  => "root",
                       group  => "root",
                       mode   => '0644',
                       require => Package[postfix],
                       content => template('postfix/client-main.cf.erb'),
                       notify => Exec['rebuild-main-config'],
                }
            }
}

