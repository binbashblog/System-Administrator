Package {  allow_virtual => true, }
include postfix
#realize Accounts::Virtual['hs']
include accounts
include ntp
include sshd
