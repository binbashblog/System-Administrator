##########################################################
#      Post-deploy powercli script - Version 2.0         #
#		    Created 05-10-2016                   #
#		  Made better 07-09-2017                 #
#                 Script is written by 			 #
#                © Harpinder Sanghera :) �		 #
##########################################################

#######################################################################################
# WARNING:                                                                            #
# Do not fudge this script up, it connects to vCenter infrastructure with a privileged #
# account so messing with this script too much could cause damage                     #
#                                                                                     #
# Summary:                                                                            # 
# Using Invoke-VMScript to do all the heavy lifting                                   #
# - using VMware tools as the delivery mechanism for post deployment configuration    #
# Invoke-VMScript requires the VM to be switched on, but not networked! As long as    #
# the VM is booted into the OS, regardless of whether it is online or offline,        #
# it will just work.                                                                  #
# So this script can also be used where SSH is not possible.                          #
# Uses a CSV file to get the values. A funky web frontend can be written in PHP to    #
# parse the values in a CSV script and then execute the powershell script             #
# something to do for the next version                                                #
# Just run it like this: ./postdeploy.ps1                                             #
#                                                                                     #
# CSV Example:                                                                        #
#                                                                                     #
#                                                                                     #
#                                                                                     #
# For Example::                                                                       #
#                                                                                     #
#######################################################################################

#############################################################################################################
# Changelog:                                                                                                #
#   v0.1 - Initial write up of the script to sent whatever commands to the VM we want via "Invoke-VMScript" #
#   v0.5 - Cleaned up syntax and typo's in the code which had prevented the execution from running cleanly, #
#          the script now waits until the vmware tools report a running status                              #
#   v1.0 - The first stable happy version of the code, with comments about how it works and what it does;   #
#          Deemed "production ready"; Added the elevator=noop line to grub.conf                             #
#   v1.1 - Changed the ordering of Puppet, RHN and YUM registration                                         #
#	v1.2 - Added the ability for the script to add additional disks (up to 5).                              #
#          Csv file would need headings such as disk[1-5], lvname[1-5], vgname[1-5], sizegb[1-5], etc       #
#	v1.3 - Added create vm from template at the top of the script to test having just 1 powershell script   #
#          to do the whole deployment                                                                       #
#   v1.4 - Increased start-sleep to 10 seconds for toolsStatus as sometimes it takes longer for the VM to   #
#          finish coming up                                                                                 #
#   v1.5 - Increased the start-sleep time after the toolsStatus to 20 seconds to ensure the vm has enough   # 
#          time to come up properly after the tools give an OK status (allow the networking                 #
#          service to come up completely)                                                                   #
#   v1.6 - Added a prompt to ask for the CSV name, default location is the requests subfolder in whichever  #
#          directory the script lives in (In future versions this could be changed to                       #
#          just process all CSV's in the directory and could be batch run and scheduled overnight)          # 
#   v1.7 - Added disk 6. Need to change to just work with however many disks are in the csv in future.      #
#          Made the script in line with the GUI that I have been developing (Changed csv headers)           #
#   v2.0 - This version is for deploying vm's with the First Boot Template but without customizing and      #
#          just simply deploying the vm to use the First Boot script built into the template to customize it#
#          Added some vCenter connection improvements (connects to vcenters specified in csv now)           #
#          Now deploys directly to folder location(Remember to put in folder name)                          #
#          Now outputs a list of CSV files in the request directory to choose from
#############################################################################################################

# Import VMWare plugin to Powershell and connect to vCenter, ignore stupid SSL errors
Add-PSSnapin VMware*
#Set-PowerCLIConfiguration -InvalidCertificateAction ignore -Confirm:$false

# Get the creds for the guest vm and the CSV file path
#Write-Host "Guest Credentials (genpw kickstart)" -foregroundcolor "yellow"
#$creds = (get-credential)
#
# This needs more work
#
Write-Host "Place the CSV file in the following path"
write-host " "
write-host -ForegroundColor Yellow ".\requests\"

### Prompt user to specify filename
# List CSV's files under the request folder to be selected
#
# Needs more work, perhaps pass in args to pass this through
#
$Dir = get-childitem .\requests -recurse
# $Dir |get-member
$List = $Dir | where {$_.extension -eq ".csv"}
$List | format-table name
$Answer = Read-Host -Prompt 'Enter the name of the CSV file to be processed'
$csv = import-csv -Path .\requests\$Answer

# Add all vcenters in each row in the CSV into a string and seperate with a line
foreach ($vm in $csv){
$vcenter = $vcenter + $vm.vcenter -split '\s+'
}

# Remove duplicate vcenters from the vcenter string
$vcenter = $vcenter | Sort-Object -Unique

# Connect to the vCenters
foreach ($vcenters in $vcenter){

Write-Host "Connecting to vCenter $vm.vcenter" -foregroundcolor "magenta" 
$credentials=Get-Credential -Username "@" -Message "Enter your vCenter credentials" 
Connect-VIServer -Server $vcenter -Credential $credentials
}


$party = @"
#######################
###!< Let's party >!###
#######################
"@

Write-Host "$($party)" -ForegroundColor Red

Write-Host "Welcome to the Poor Man's Automation Center!" -ForegroundColor Green

$text1 = @"
………………(\_/) 
………………( ‘_’) Ready...
……………/”"”"”\
…./”"”"”"”"”"”"\========░D
/”"”"”"”"”"”"”"”"”"”\ 
\_@_@_@_@_@_@_@_@_@_/ 
"@

Write-Host "$($text1)" -ForegroundColor Red

Start-Sleep 1


$text2 = @"
………………………………………………………………(\_/) 
………………………………………………………………( ‘_’) Set...
……………………………………………………………/”"”"”\
…………………………………………………./”"”"”"”"”"”"\========░D
………………………………………………/”"”"”"”"”"”"”"”"”"”\ 
__________________\_@_@_@_@_@_@_@_@_@_/ 
"@

Write-Host "$($text2)" -ForegroundColor Yellow

Start-Sleep 1

$text3 = @"
………………………………………………………………………………………………………………………………(\_/) 
………………………………………………………………………………………………………………………………( ‘_’) Let's Roll!!!
……………………………………………………………………………………………………………………………/”"”"”\
…………………………………………………………………………………………………………………./”"”"”"”"”"”"\========░D
………………………………………………………………………………………………………………/”"”"”"”"”"”"”"”"”"”\ 
__________________________________________\_@_@_@_@_@_@_@_@_@_/ 
"@

Write-Host "$($text3)" -ForegroundColor Green

Start-Sleep 1

foreach ($vm in $csv){

}

#deploy VMs 
foreach ($vm in $csv){
    Write-Host "Deploying $($vm.name) to vCenter $($vm.vcenter) and Datastore $($vm.datastore) in location $($vm.location) with $($vm.numcpu) CPUs with $($vm.memMB) GBs of RAM and OS $($vm.guestID) using Template $($vm.template)" -ForegroundColor Green
    get-cluster -name $vm.cluster -server $vm.vcenter | new-vm -Name $vm.name -Datastore $vm.datastore -template $vm.template -Location $vm.location -RunAsync
    
} 

#waiting for all the VM's to be provisioned 	
foreach ($vm in $csv){
do {     
    $toolsStatus = (Get-VM -name $vm.name).extensiondata.Guest.ToolsStatus     
    Start-Sleep -Seconds 10
    Write-Host "Ensuring $($vm.name) is not powered on...yet" -foregroundcolor "cyan"     
    } 
    until  ($toolsStatus -match ‘toolsNotRunning’) 
}
    
#set memory and cpu 
foreach($vm in $csv){
    Write-Host "Giving... $($vm.name)...$($vm.numcpu) CPUs" -ForegroundColor Green     
    get-vm -name $vm.name | set-vm -numcpu $vm.numcpu -confirm:$false     
    start-sleep -Seconds 3
    Write-Host "Giving... $($vm.name)...$($vm.memGB) GBs of RAM" -ForegroundColor Green     
    get-vm -name $vm.name | set-vm -MemoryGB $vm.memGB -confirm:$false     
    } 
    
#connect network and boot 
foreach($vm in $csv){
    Write-Host "Putting $($vm.name) on network $($vm.network)" -ForegroundColor Green     
    get-vm $vm.name | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $vm.network -Confirm:$false -StartConnected:$true  -Type Vmxnet3     
    Start-Sleep -Seconds 3     
    get-vm $vm.name | Start-VM     
    } 
    
#wait for vm to boot 
foreach($vm in $csv){
do {     
    $toolsStatus = (Get-VM -name $vm.name).extensiondata.Guest.ToolsStatus     
    Start-Sleep -Seconds 10 
    Write-Host "Waiting for $($vm.name) to come back up" -foregroundcolor "cyan"    
    } until  ($toolsStatus -match ‘toolsOK’) 
    }
    
Start-Sleep -Seconds 30

$networking = @"
##############
# Networking #
##############
## This can be configured within the First Boot script inside the Template (See VM Console)
"@
Write-Host "$($networking)" -ForegroundColor Yellow

$io = @"
################
# IO Scheduler #
################
## This can be configured within the First Boot script inside the Template (See VM Console)
"@
Write-Host "$($io)" -ForegroundColor Yellow

$disk = @"
##############################
# Disk and LVM Configuration #
##############################

Applying Disk configuration...please wait
"@
Write-Host "$($disk)" -ForegroundColor Yellow

# Adds a disk to the vm, then sets up LVM according to the CSV file, gives the LV 100% of the free space
#This will be done in TGW's script but this is just for testing stuff out for now
foreach ($vm in $csv){

Write-Host "Adding the $($vm.disk1) disk on $($vm.Name)" -foregroundcolor "Yellow"
get-vm  $vm.name | New-HardDisk -CapacityGB $vm.sizegb1 -StorageFormat Thick
Start-Sleep -Seconds 30
Write-Host "Creating volume group $($vm.vgname) on disk /dev/$($vm.disk1) on $($vm.name)" -ForegroundColor Green
Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "vgcreate $($vm.vgname) /dev/$($vm.disk1)"
Write-Host "Creating logical volume $($vm.lvname1) on volume group $($vm.vgname) on $($vm.name)" -ForegroundColor Green
Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "lvcreate -l+100%FREE -n $($vm.lvname1) $($vm.vgname)"
Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkfs.$($vm.fs) /dev/mapper/$($vm.vgname)-$($vm.lvname1)"
Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkdir $($vm.mount1)"
#Took out noatime, might need to clarify with ISG whether to use it
Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "sed '$ a\/dev/mapper/$($vm.vgname)-$($vm.lvname1)      $($vm.mount1)       $($vm.fs)    defaults        1 2' -i /etc/fstab"
#Commented the below out as further discussion needed before adding this setting (tells the FS not to do a fsck after 30 mounts of the fs (it will still check the fs after 180 days anyway)
#Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "tune2fs -m 0 /dev/mapper/$($vm.vgname)-$($vm.lvname1)"
Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mount $($vm.mount1)"

If ($vm.disk2 -gt 1) {

        Write-Host "Adding the $($vm.disk2) disk on $($vm.Name)" -foregroundcolor "Yellow" 
        get-vm  $vm.name | New-HardDisk -CapacityGB $vm.sizegb2 -StorageFormat Thick | Out-Null
		start-sleep -Seconds 30
		Write-Host "Creating volume group $($vm.vgname) on disk /dev/$($vm.disk2) on $($vm.name)" -ForegroundColor Green
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "vgextend $($vm.vgname) /dev/$($vm.disk2)"
		Write-Host "Creating logical volume $($vm.lvname2) on volume group $($vm.vgname) on $($vm.name)" -ForegroundColor Green
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "lvcreate -l+100%FREE -n $($vm.lvname2) $($vm.vgname)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkfs.$($vm.fs) /dev/mapper/$($vm.vgname)-$($vm.lvname2)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkdir $($vm.mount2)"
        #Took out noatime, might need to clarify with ISG whether to use it
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "sed '$ a\/dev/mapper/$($vm.vgname)-$($vm.lvname2)      $($vm.mount2)       $($vm.fs)    defaults        1 2' -i /etc/fstab"
        #Commented the below out as further discussion needed before adding this setting (tells the FS not to do a fsck after 30 mounts of the fs (it will still check the fs after 180 days anyway)
        #Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "tune2fs -m 0 /dev/mapper/$($vm.vgname)-$($vm.lvname1)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mount $($vm.mount2)"

      }

      If ($vm.disk3 -gt 1) {

        Write-Host "Adding the $($vm.disk3) disk on $($vm.Name)" -foregroundcolor "Yellow"

        get-vm  $vm.name | New-HardDisk -CapacityGB $vm.sizegb3 -StorageFormat Thick | Out-Null
		start-sleep -Seconds 30
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "vgextend $($vm.vgname) /dev/$($vm.disk3)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "lvcreate -l+100%FREE -n $($vm.lvname3) $($vm.vgname)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkfs.$($vm.fs) /dev/mapper/$($vm.vgname)-$($vm.lvname3)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkdir $($vm.mount3)"
        #Took out noatime, might need to clarify with ISG whether to use it
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "sed '$ a\/dev/mapper/$($vm.vgname)-$($vm.lvname3)      $($vm.mount3)       $($vm.fs)    defaults        1 2' -i /etc/fstab"

        #Commented the below out as further discussion needed before adding this setting (tells the FS not to do a fsck after 30 mounts of the fs (it will still check the fs after 180 days anyway)
        #Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "tune2fs -m 0 /dev/mapper/$($vm.vgname)-$($vm.lvname1)"

        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mount $($vm.mount3)"
      }

      If ($vm.disk4 -gt 1) {

        Write-Host "Adding the $($vm.disk4) disk on $($vm.Name)" -foregroundcolor "Yellow" 

        get-vm  $vm.name | New-HardDisk -CapacityGB $vm.sizegb4 -StorageFormat Thick | Out-Null
		start-sleep -Seconds 30
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "vgextend $($vm.vgname) /dev/$($vm.disk4)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "lvcreate -l+100%FREE -n $($vm.lvname4) $($vm.vgname)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkfs.$($vm.fs) /dev/mapper/$($vm.vgname)-$($vm.lvname4)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkdir $($vm.mount4)"
        #Took out noatime, might need to clarify with ISG whether to use it
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "sed '$ a\/dev/mapper/$($vm.vgname)-$($vm.lvname4)      $($vm.mount4)       $($vm.fs)    defaults        1 2' -i /etc/fstab"

        #Commented the below out as further discussion needed before adding this setting (tells the FS not to do a fsck after 30 mounts of the fs (it will still check the fs after 180 days anyway)
        #Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "tune2fs -m 0 /dev/mapper/$($vm.vgname)-$($vm.lvname1)"

        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mount $($vm.mount4)"
      }
	  
      If ($vm.disk5 -gt 1) {

        Write-Host "Adding the $($vm.disk5) disk on $($vm.Name)" -foregroundcolor "Yellow" 

        get-vm  $vm.name | New-HardDisk -CapacityGB $vm.sizegb5 -StorageFormat Thick | Out-Null
		start-sleep -Seconds 30
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "vgextend $($vm.vgname) /dev/$($vm.disk5)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "lvcreate -l+100%FREE -n $($vm.lvname5) $($vm.vgname)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkfs.$($vm.fs) /dev/mapper/$($vm.vgname)-$($vm.lvname5)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkdir $($vm.mount5)"
        #Took out noatime, might need to clarify with ISG whether to use it
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "sed '$ a\/dev/mapper/$($vm.vgname)-$($vm.lvname5)      $($vm.mount5)       $($vm.fs)    defaults        1 2' -i /etc/fstab"

        #Commented the below out as further discussion needed before adding this setting (tells the FS not to do a fsck after 30 mounts of the fs (it will still check the fs after 180 days anyway)
        #Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "tune2fs -m 0 /dev/mapper/$($vm.vgname)-$($vm.lvname1)"

        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mount $($vm.mount5)"
      }
	  
	  If ($vm.disk6 -gt 1) {

        Write-Host "Adding the $($vm.disk6) disk on $($vm.Name)" -foregroundcolor "Yellow" 

        get-vm  $vm.name | New-HardDisk -CapacityGB $vm.sizegb5 -StorageFormat Thick | Out-Null
		start-sleep -Seconds 30
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "vgextend $($vm.vgname) /dev/$($vm.disk6)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "lvcreate -l+100%FREE -n $($vm.lvname6) $($vm.vgname)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkfs.$($vm.fs) /dev/mapper/$($vm.vgname)-$($vm.lvname6)"
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mkdir $($vm.mount6)"
        #Took out noatime, might need to clarify with ISG whether to use it
        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "sed '$ a\/dev/mapper/$($vm.vgname)-$($vm.lvname6)      $($vm.mount6)       $($vm.fs)    defaults        1 2' -i /etc/fstab"

        #Commented the below out as further discussion needed before adding this setting (tells the FS not to do a fsck after 30 mounts of the fs (it will still check the fs after 180 days anyway)
        #Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "tune2fs -m 0 /dev/mapper/$($vm.vgname)-$($vm.lvname1)"

        Invoke-VMScript -VM $vm.name -GuestCredential $creds -ScriptText "mount $($vm.mount6)"
      }

}

$rhelsat = @"
##################################################
# Register with RHEL Satellite & import GPG keys #
##################################################
## This can be configured within the First Boot script inside the Template (See VM Console)
"@
Write-Host "$($rhelsat)" -ForegroundColor Yellow

$puppet = @"
##########
# Puppet #
##########
## This can be configured within the First Boot script inside the Template (See VM Console)
"@
Write-Host "$($puppet)" -ForegroundColor Yellow

$yum = @"
#######
# Yum #
#######
## This can be configured within the First Boot script inside the Template (See VM Console)
"@
Write-Host "$($yum)" -ForegroundColor Yellow


$fun = @"
###########################
###!< Fun time's over >!###
###########################
"@
Write-Host "$($fun)" -ForegroundColor Yellow

$up =@"

▒▒▒▒▒▒▒▒▒▄▄▄▄▒▄▄▄▒▒▒
▒▒▒▒▒▒▄▀▀▓▓▓▀█░░░█▒▒
▒▒▒▒▄▀▓▓▄██████▄░█▒▒
▒▒▒▄█▄█▀░░▄░▄░█▀▀▄▒▒
▒▒▄▀░██▄░░▀░▀░▀▄▓█▒▒
▒▒▀▄░░▀░▄█▄▄░░▄█▄▀▒▒
▒▒▒▒▀█▄▄░░▀▀▀█▀▓█▒▒▒
▒▒▒▄▀▓▓▓▀██▀▀█▄▀▒▒▒▒
▒▒█▓▓▄▀▀▀▄█▄▓▓▀█▒▒▒▒
▒▒▀▄█░░░░░█▀▀▄▄▀█▒▒▒
▒▒▒▄▀▀▄▄▄██▄▄█▀▓▓█▒▒
▒▒█▀▓█████████▓▓▓█▒▒
▒▒█▓▓██▀▀▀▒▒▒▀▄▄█▀▒▒
▒▒▒▀▀▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

"@
Write-Host "$($up)" -ForegroundColor DarkRed -BackgroundColor White

foreach ($vcenters in $vcenter){
Write-Host "Disconnecting from vCenter $vm.vcenter" -foregroundcolor "magenta" 
Disconnect-viserver -Server $vcenter -Confirm:$false
}

foreach ($vm in $csv){
Write-Host "End of deployment of $($vm.name)" -foregroundcolor "Yellow"
}


$peace1 = @"
                                                                      (\_/)………………
                                                       Ok, that's it (’_‘ )………………
                                                                     /”"”"”\……………
                                                      D░========\"”"”"”"”"”"”\.……
                                                            /”"”"”"”"”"”"”"”"”"”\
                                                            \_@_@_@_@_@_@_@_@_@_/_
 
"@


Write-Host "$($peace1)" -ForegroundColor Cyan

Start-Sleep 1

$peace2 = @"
                                        (\_/)………………………………………………………………
                        I'm outta here (’_‘ )………………………………………………………………
                                       /”"”"”\……………………………………………………………
                        D░========/"”"”"”"”"”"”\.…………………………………………………
                             /”"”"”"”"”"”"”"”"”"”\………………………………………………
                             \_@_@_@_@_@_@_@_@_@_/__________________
 
"@


Write-Host "$($peace2)" -ForegroundColor Yellow
Start-Sleep 1

$peace3 = @"
                (\_/)………………………………………………………………………………………………………………………………
     Peace out (’_‘ )………………………………………………………………………………………………………………………………
               /”"”"”\……………………………………………………………………………………………………………………………
D░========\"”"”"”"”"”"”\.…………………………………………………………………………………………………………
     /”"”"”"”"”"”"”"”"”"”\
     \_@_@_@_@_@_@_@_@_@_/_______________________________________
 
"@


Write-Host "$($peace3)" -ForegroundColor Red
Start-Sleep 1

