#######################################################################################
# Author - Nate Faulds <nb.faulds@gmail.com>                                          #
# Purpose - Simple script to report back potential print queue congestion or stoppage #
# Something i threw together in a few seconds after another jammed queue happened     #
# Can be turned into a simple reporting loop with waiting/sleep if needed             #
#######################################################################################

param (
[Parameter(Mandatory=$true)][string]$Printer
)

function GetJobs{
[int]$jobs = 0;
if($Printer = ""){
# Leave this blank, could handle later
}else{
try{
$jobs = Get-PrintJob -PrinterName $Printer;
$jobs | ForEach-Object -Process { $found++; }
return $jobs;
}catch{
return -1; # Handle reported error?
}
}
}
function SendCloggedNotice{
# Send notice so you can see it
Add-Type -AssemblyName System.Windows.Forms 
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
$balloon.BalloonTipText = 'The print queue for '+$Printer+' may be clogged.
Please check the queue manually!'
$balloon.BalloonTipTitle = "Print Queue Monitor Alert" 
$balloon.Visible = $true 
$balloon.ShowBalloonTip(7000) # Show for 7 seconds i guess
}

$temp = GetJobs;
# This is is basically
if ($temp -gt 3){Write-Output "Many print jobs waiting in queue.....please check";SendCloggedNotice;}
else{Write-Output "Print queue looks normal, going to sleep...";}