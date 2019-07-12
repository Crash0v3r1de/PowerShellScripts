# --Script Summary--
# This scipt is basically what i run on each indivudual Bursar computer when they have printing issues(not as through though)
# This basically automates the removal and re adding of printer and driver on the user level - and wipes old printer share if present
# Something with the Bursar setup makes GPO half install the driver (unsure if print server or network issue)
# I can always tweak this or make another so you can assign printer name via script arguments for other uses
#                      !THIS HAS TO BE RAN UNDER THE LOGGED IN USER!
#              -Author: Nate Faulds <nathan.faulds@colorado.edu> | 7-12-2019


# Script Parameters
param([bool]$debug=0) # assign 1 for true to enable debug or leave blank for 0 to disable debug

# Variables
$oldPrinterShare = "FULL PRINTER NAME HERE"
$newPrinterShare = "FULL PRINTER NAME HERE"

# Functions
Function RemoveOld{

try {

$printerToDelete = Get-Printer -ErrorAction Stop -Name $oldPrinterShare

if($printerToDelete){ # Extra validation
if($debug){echo "Old printer present.....removing..."}
Remove-Printer -Name $oldPrinterShare
Sleep 2 # Sleeping just cause
if($debug){echo "Removed old printer!"}

}
}
catch {

if($debug){echo "Babe not found"}

}
}
Function PrinterPresent{
try{
Get-Printer -ErrorAction Stop -Name $newPrinterShare
return 1
}catch{
return 0
}
}
Function RemoveNew{
try{
Remove-Printer -Name $newPrinterShare
Sleep 2 # Sleeping just cause
}catch{


}
}
Function AddPrinter{

try{
Add-Printer -ConnectionName $newPrinterShare
Sleep 3 # Sleeping for driver install (yes it's veryyyy slow for some)
return 1
}catch{
return 0
}
}
Function ReturnFailure{
if($debug){echo "Failed adding printer!"}
# This includes the script exit handling and system exit handling
#[System.Environment]::Exit(1) # Return code for failure
Exit 0 # Script return code for failure
}
Function ReturnSuccess{
if($debug){echo "Printer added!"}
# This includes the script exit handling and system exit handling
#[System.Environment]::Exit(0) # Return code for success - GG
Exit 1 # Script return code for success - GG
}

# Script Invokes
RemoveOld # Just in case
if(PrinterPresent){
if($debug){echo "Removing printer found..."}
RemoveNew
if($debug){echo "Adding printer back..."}
if(AddPrinter){
ReturnSuccess
}else{
ReturnFailure
}
}else{
if(AddPrinter){
ReturnSuccess
}else{
ReturnFailure
}
}
