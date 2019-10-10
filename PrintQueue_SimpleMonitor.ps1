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


# This is is basically
if (GetJobs -gt 3){Write-Output "Many print jobs waiting in queue.....please check";}
else{Write-Output "Print queue looks normal, going to sleep...";}
