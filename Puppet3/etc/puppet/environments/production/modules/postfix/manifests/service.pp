
class postfix::service {
            service { 'postfix':
                    enable => false,
                    ensure => running,
                    require => Package[postfix],
            }
            exec { 'reload-postfix':
                 command     => '/etc/init.d/postfix reload',
                 refreshonly => true,
            }
            exec { 'rebuild-aliases':
                 command => "/usr/sbin/postalias /etc/aliases",
                 refreshonly => true;
            }
            exec { 'rebuild-main-config':
                 command => "/usr/sbin/postmap /etc/postfix/main.cf",
                 refreshonly => true;
            }
            exec { 'rebuild-transport':
                command     => '/usr/sbin/postmap /etc/postfix/transport',
                refreshonly => true,
            }


}
