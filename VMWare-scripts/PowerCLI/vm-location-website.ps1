# Powershell script to write VM, host and Power Status into html file

# Punch in the VMware Hosts and Credentials here, don't touch anything below.
# A more complicated version of the original vmlist.ps1
# Includes more than just the location of a vm in a large infrastructure, reports on snapshots, disks, network, thin provisioning etc too, if you can get it working that is.
# Use at your own risk

#Set-PowerCLIConfiguration -DefaultServerMode single
add-pssnapin VMware.VimAutomation.Core

#####################################################################################################################
# Temporarily mount location of scripts/website as P drive
Get-PSDrive -Name P | Remove-PSDrive
New-PSDrive -Name "P" -Root C:\scripts -PSProvider FileSystem
# check that no viserver is connected yet
disconnect-viserver -server * -Confirm:$false -Force:$true

$user = "VMreadonly"
$password = "Password123"

$connecttpc = "vi-dc1-vc01.vmware.local"
$usertpc = "vmware.local\VMreadonly"


$connectsdc = "vi-dc2-vc02.vmware.local"
$usersdc = "vmware.local\VMreadonly"


$vm = "get-vm | Where {(`$_.Name -notlike `"Z-VRA*`")} | select name,@{N=`"IP`";E={`$_.Extensiondata.guest.IPaddress}}, NumCPU, MemoryMB,@{N=`"Total-HDD(GB)`";E={`$_.ProvisionedSpaceGB -as [int]}},@{N=`"Datastore`";E={(Get-Datastore -vm `$_) -split `", `" -join `", `"}},@{N=`"OS`";E={`$_ExtensionData.summary.config.guestfullname}},folder,@{Name=`"VCenter`";Expression={`$_.Name.Uid.Substring(`$_.Name.Uid.IndexOf('@')+1).Split(`":`")[0]}},@{N=`"Cluster`";E={`$_.vmhost.parent}},vmhost,PowerState"

#Version,,@{N="Tools Installed";E={$_.Guest.ToolsVersion -ne ""}},@{N="Tools Status";E={$_.ExtensionData.Guest.ToolsStatus}}

$snapshot = "get-vm | get-snapshot | where {`$_.SizeGB -gt 0.99} | select vm,name,@{ Name=`"size(GB)`";Expression={`"{0:N1}`" -f ( `$_.sizeGB ) }},created,@{Name=`"VCenter Server`";Expression={`$_.Name.Uid.Substring(`$_.Name.Uid.IndexOf('@')+1).Split(`":`")[0]}}"

#$thin = {get-vm | select name,@{N="IP";E={$_.Extensiondata.guest.IPaddress}}, NumCPU, MemoryMB,@{N="Total-HDD(GB)";E={$_.ProvisionedSpaceGB -as [int]}},@{N="Datastore";E={(Get-Datastore -vm $_) -split ", " -join ", "}},Version,@{N="OS";E={$_ExtensionData.summary.config.guestfullname}},@{N="Tools Installed";E={$_.Guest.ToolsVersion -ne ""}},@{N="Tools Status";E={$_.ExtensionData.Guest.ToolsStatus}},folder,Name="VCenter";Expression={$_.Name.Uid.Substring($_.Name.Uid.IndexOf('@')+1).Split(":")[0]},@{N="Cluster";E={$_.vmhost.parent}},vmhost,PowerState}

#$version = {get-vm | select name,Version,@{N="OS";E={$_ExtensionData.summary.config.guestfullname}},@{N="Tools Installed";E={$_.Guest.ToolsVersion -ne ""}},@{N="Tools Status";E={$_.ExtensionData.Guest.ToolsStatus}},@{N="Tools version";E={if($_.Guest.ToolsVersion -ne ""){$_.Guest.ToolsVersion}}},@{N="Tools Version Status";E={$_.ExtensionData.Guest.ToolsVersionStatus}},@{N="Tools Running";E={$_.ExtensionData.Guest.ToolsRunningStatus}}}

###############################################################################
###############################################################################
###############################################################################

$head = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/dt/jqc-1.12.4/dt-1.10.15/datatables.min.css"/>
<link rel="stylesheet" type="text/css" href="style.css"/>
<link rel="stylesheet" type="text/css" href="search.css"/>
<script type="text/javascript" src="https://cdn.datatables.net/v/dt/jqc-1.12.4/dt-1.10.15/datatables.min.js"></script>
<script type="text/javascript">  
    `$(document).ready(function(){
        `$('table').each(function(){
            // Grab the contents of the first TR element and save them to a variable
            var tHead = `$(this).find('tr:first').html();
			// Remove the first COLGROUP element 
			`$(this).find('colgroup').remove(); 
			// Remove the first TR element 
			`$(this).find('tr:first').remove();
			// Add a new THEAD element before the TBODY element, with the contents of the first TR element which we saved earlier. 
			`$(this).find('tbody').before('<thead>' + tHead + '</thead>'); });
            
            // Add the display class to the table element
            document.getElementsByTagName("table")[0].setAttribute("class", "compact");
            
			// Apply the DataTables jScript to all tables on the page 
			`$('table').dataTable( {
			// Put your datatable options here 
			"bPaginate": false,
			"bFilter": false,
			"bInfo": false
					} ); 
	} ); 
</script>
</head>
"@

$vmtitle = @"
<title>
VM Status Report " + `$((Get-Date)) + "
</title>
<meta http-equiv="refresh" content="3600" />
"@

$snapshottitle = @"
<title>
Snapshot Report " + `$((Get-Date)) + "
</title>
<meta http-equiv="refresh" content="3600" />
"@

$searchjs = @"
<body class="body"> <script>
window.onload = function() {
      document.getElementById("myInput").value = "";
      document.getElementById("myInput").focus();
    };
</script>


<script type="text/javascript">
    function myFunction() {
      // Declare variables
      var input, filter, table, tr, td, i;
      input = document.getElementById("myInput");
      filter = input.value.toUpperCase();
      table = document.getElementsByTagName("table")[0];
      tr = table.getElementsByTagName("tr");

      // Loop through all table rows, and hide those who don't match the search query
      for (i = 0; i < tr.length; i++) {
        td = tr[i].getElementsByTagName("td")[0];

        if (td) {
          if (td.innerHTML.toUpperCase().indexOf(filter) > -1) {
            tr[i].style.display = "";
                if (tr[i].getElementsByTagName("td")[5] == 'PoweredOff') {
            tr[i].style.backgroundColor = "#FF2080";
        }
          } else {
            tr[i].style.display = "none";
          }
        }
      }
    }
</script>
"@

$search = @"
<input type="text" id="myInput" onkeyup="myFunction()" placeholder="Search for VM...">
"@

$nav = @"
<ul class="tabs  primary-nav">
    <li class="tabs__item">
        <a href="vm.html" class="tabs__link">VM Status Report</a>
    </li>
    <li class="tabs__item">
        <a href="snapshot.html" class="tabs__link">Snapshots Report</a>
    </li>
    <li class="tabs__item">
        <a href="thin.html" class="tabs__link">Thin Provision Report</a>
    </li>
    <li class="tabs__item">
        <a href="version.html" class="tabs__link">VM Version Report</a>
    </li>
 </ul>
"@

$vmhead = "<h1>VM Status Report - " + (Get-Date) + "</h1>"
$snapshothead = "<h1>Snapshot Report - " + (Get-Date) + "</h1>"
#$thinhead = "<h1>Thin Provisioning Report - " + (Get-Date) + "</h1>"
$versionhead = "<h1>VM Version Report - " + (Get-Date) + "</h1>"

$vmcontent = $head + $vmtitle + $searchjs + $search + $nav + $vmhead
$snapshotcontent = $head + $snapshottitle + $searchjs + $search + $nav + $snapshothead
#$thincontent = $head + $vmtitle + $searchjs + $search + $nav + $thinhead
$versioncontent = $head + $snapshottitle + $searchjs + $search + $nav + $versionhead

##############################################################################################
##############################################################################################
##############################################################################################
##############################################################################################

connect-viserver -server $connecttpc -Protocol https -user $usertpc -password $password
$TPC = invoke-expression $vm
$TPCS = invoke-expression $snapshot
#$TPCT = $thin
#$TPCV = & $version
#get-vm | Get-View -Property @("Name", "Config.GuestFullName", "Guest.GuestFullName") | Select -Property Name
disconnect-viserver -server $connecttpc -Confirm:$false -Force:$true


connect-viserver -server $connectsdc -Protocol https -user $usersdc -password $password
$SDC = invoke-expression $vm
$SDCS = invoke-expression $snapshot
#$SDCT = $thin
#$SDCV = & $version
#get-vm | Get-View -Property @("Name", "Config.GuestFullName", "Guest.GuestFullName") | Select -Property Name
disconnect-viserver -server $connectsdc -Confirm:$false -Force:$true


$join = $TPC + $SDC
$joins = $TPCS + $SDCS
#$joint = $TPCT + $SDCT
#$joinv = $TPCV + $SDCV
$join | ConvertTo-HTML -PreContent $vmcontent| Out-File P:\html.pub\vm.html
$joins | ConvertTo-HTML -PreContent $snapshotcontent| Out-File P:\html.pub\snapshot.html
#$joint | ConvertTo-HTML -PreContent $thincontent| Out-File P:\html.pub\thin.html
#$joinv | ConvertTo-HTML -PreContent $versioncontent| Out-File P:\html.pub\version.html
