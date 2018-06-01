# Powershell script to write VM, host and Power Status into html file
# Run in Windows as a scheduled task, every half hour, hour, day, week, however you want
# html file will be outputted which can be hosted on a web server, such as IIS as in the example below
# Can have multiple vcenters connected with a get-vm line for each, however each additional get-vm line in this script needs an -append line as commented below to work

#Set-PowerCLIConfiguration -DefaultServerMode single
add-pssnapin VMware.VimAutomation.Core

#####################################################################################################################
New-PSDrive -Name "P" -Root C:\inetpub\wwwroot\vmlist -PSProvider FileSystem

# Get list of VMs for DC1

connect-viserver -server vi-dc1-vc01.vmware.local -Protocol https -user vi-dc1-vc01.vmware.local\VMreadonly -password "Password123"

# This line writes out the CSS formatting for the whole document
$css = "<h1>VM Status " + (Get-Date) + "</h1><style> body { font-family: Verdana, sans-serif; font-size: 14px; color: #666; background: #FFF; } table{ width:100%; border-collapse:collapse; } table td, table th { border:1px solid #333; padding: 4px; } table th { text-align:left; padding: 4px; background-color:#BBB; color:#FFF;} </style>"

# For each vcenter you have, you can add one of these lines for each one. Each additional line should have an -append for the out-file so that the html file isn't overwritten, it isn't the most cleanest way of doing it, but it works.
get-vm | select name,@{N="IP";E={$_.Extensiondata.guest.IPaddress}},NumCPU, MemoryMB,@{N="Cluster";E={$_.vmhost.parent}},vmhost,PowerState | sort name | ConvertTo-HTML -PreContent $css| Out-File P:\index.html

disconnect-viserver -server vi-dc1-vc01.vmware.local -Confirm:$false -Force:$true


# Get list of VMs for Slough environment

connect-viserver -server vi-dc2-vc02.vmware.local -Protocol https -user vi-dc2-vc02.vmware.local\VMreadonly -password "Password123"

# Notice this line has an append to the end, this will add the resulting output to the existing output written out by the first get-vm line
get-vm | select name,@{N="IP";E={$_.Extensiondata.guest.IPaddress}},NumCPU, MemoryMB,@{N="Cluster";E={$_.vmhost.parent}},vmhost,PowerState | sort name | ConvertTo-HTML| Out-File P:\index.html -Append

disconnect-viserver -server vi-dc2-vc02.vmware.local -Confirm:$false -Force:$true


# This line stores the html file with all the appended lines from each vcenter
(Get-Content "C:\inetpub\wwwroot\vmlist\index.html").Replace("<title>HTML TABLE</title>","<title>VM List</title>") | Set-Content "C:\inetpub\wwwroot\vmlist\index.html" 
