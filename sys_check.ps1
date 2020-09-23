$ErrorActionPreference = 'silentlycontinue'
$date = Get-Date -Format "dddd MM/dd/yyyy HH:mm K"
$dir = [Environment]::GetFolderPath("CommonDesktopDirectory")

$System = Get-ComputerInfo
$Storage = Get-Disk

$Hostname = $System.CsName
$Model = $System.CsModel
$CPU = ($System | % {"{0} ({1} Core(s), {2} Logical Processor(s))" -f $_.CsProcessors.Name, $_.CsProcessors.NumberOfCores, $_.CsProcessors.NumberOfLogicalProcessors} | Out-String).Trim()
$OperatingSystem = "{0} ({1}) {2}" -f $System.OsName, $System.OsArchitecture, $System.WindowsVersion
$RAM = "{0:N2} / {1:N2} GB ({2:N1}% Free)" -f ($System.OsFreePhysicalMemory / 1MB), ($System.OsTotalVisibleMemorySize / 1MB), (($System.OsFreePhysicalMemory / $System.OsTotalVisibleMemorySize) * 100)
$Disks = ($Storage | % { "[{0}] {1} = {2:N2} GB" -f $_.PartitionStyle, $_.FriendlyName, ($_.Size / 1GB) } | Out-String).Trim()

$defenderstatus = Get-MpComputerStatus | select AMServiceEnabled,AntispywareEnabled,AntivirusEnabled,BehaviorMonitorEnabled,IoavProtectionEnabled,IsTamperProtected,NISEnabled,OnAccessProtectionEnabled,RealTimeProtectionEnabled,AntivirusSignatureLastUpdated,AntivirusSignatureVersion | Format-List
$FWstatus = Get-Service | ?{$_.Name -eq "mpssvc"}
$FWprofiles = Get-NetFirewallProfile | select Name,Enabled | Format-Table
$BLstatus = Get-BitLockerVolume | select VolumeType,MountPoint,VolumeStatus,ProtectionStatus | Format-Table
$LastUpdates = gwmi win32_quickfixengineering | select Description,HotFixID,InstalledOn | sort installedon -desc | select -first 10
$netadapters = Get-WmiObject win32_networkadapterconfiguration | Select-Object -Property Description,@{name='IPAddress';Expression={($_.IPAddress[0])}},MacAddress | Format-Table
$resolvvpn = Resolve-DnsName -Name cisco-vpn.itransition.com
#$resolvvpn2 = Resolve-DnsName -Name cisco-vpn.itransition.com -Server 8.8.8.8
$testvpn = tracert -d cisco-vpn.itransition.com


$Report = {"Creation Date:"
$date
""
"=================================================================================================="
"System Info"
"=================================================================================================="
"Hostname   = $Hostname"
"Model      = $Model"
"Processor  = $CPU"
"OS         = $OperatingSystem"
"Memory     = $RAM"
"Disks:"
"$Disks"
""
"=================================================================================================="
"Windows Defender"
"=================================================================================================="
$defenderstatus
""
"=================================================================================================="
"Windows Firewall"
"=================================================================================================="
$FWstatus
""
$FWprofiles
""
"=================================================================================================="
"BitLocker"
"=================================================================================================="
$BLstatus
""
"=================================================================================================="
"List of last 10 updates"
"=================================================================================================="
$LastUpdates
""
"=================================================================================================="
"Network Adapter Configuration"
"=================================================================================================="
$netadapters
""
"=================================================================================================="
"Resolve cisco-vpn.itransition.com"
"=================================================================================================="
$resolvvpn
""
"=================================================================================================="
"Test connection to cisco-vpn.itransition.com"
"=================================================================================================="
$testvpn
""
"=================================================================================================="
"END"
"=================================================================================================="}

& $Report | Out-File -FilePath $dir\Report.txt