#!/bin/bash
#
#       Puppet Code Sync Script
#       This script syncs puppet code from London master to global puppet masters every 30 mins using cron
#       v1.3 by Harpinder Sanghera CREATED: 04/12/15 UPDATED: 01/06/16
#
#
PUPPET_HOME=/var/lib/puppet/scripts
PUPPET_CONFIG=/etc/puppet/
PUPPET_LOG=/var/log/puppet/puppet-rsync.log
PUPPET_MASTERS='puppet01 puppet02 puppet03'

figlet Starting Sync >> $PUPPET_LOG

for HOST in $PUPPET_MASTERS
do
        echo >> $PUPPET_LOG
        echo ======================================================================== >> $PUPPET_LOG
        echo Syncing $HOST from London Puppet Master `uname -n` >> $PUPPET_LOG
        date >> $PUPPET_LOG
        echo >> $PUPPET_LOG
        rsync -avzhe 'ssh -o "StrictHostKeyChecking no" -p 22' $PUPPET_CONFIG --delete --exclude=puppet.conf $HOST:$PUPPET_CONFIG >> $PUPPET_LOG
#       ssh -p 1022 -o "StrictHostKeyChecking no" $HOST "service puppetmaster restart" >> $PUPPET_LOG
        echo >> $PUPPET_LOG

done

figlet Finished Sync >> $PUPPET_LOG

