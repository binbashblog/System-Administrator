
class sshd::install {
        package { "openssh-server":
                ensure => present,
        }
}
