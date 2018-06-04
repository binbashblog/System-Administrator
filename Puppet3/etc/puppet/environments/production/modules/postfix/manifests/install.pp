
class postfix::install {
  case $::osfamily {
                redhat: {
                        $sendmail = ["sendmail", "sendmail-cf"]
                        service { sendmail:
                                enable => false,
                                ensure => stopped,
                        } ->
                        package { $sendmail:
                                ensure => absent,
                        } ~>
                        package { postfix:
                                ensure => present,
      }
          }
                debian: {
#                        $sendmail = ["sendmail", "sendmail-cf"]
#                        service { sendmail:
#                                enable => false,
#                                ensure => stopped,
#                        } ->
#                        package { $sendmail:
#                                ensure => absent,
#                        } ~>

                        package { postfix:
                                ensure => installed,
                        }
               }
       }
 }

