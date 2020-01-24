#######################################################################################
# Author - Nate Faulds <nb.faulds@gmail.com>                                          #
# Purpose - I have customers who use PGP and their documents will always fail to      #
#    autosave to Office365/Sharepoint since the files are not a readable format.      #
#  This script automaticaly disables autosave for current user to O365 and SharePoint #
#             This DOES NOT effect AutoRecovery and local AutoSave                    #
#######################################################################################

# Check if we're debugging 
param([bool]$debug=0) # assign 1 for true to enable debug or leave blank for 0 to disable debug

# Global Declerations
$path = "HKCU:\SOFTWARE\Microsoft\Office\16.0"
# End Global Declerations

# Check for registry item
# I REALLLYYYYYY hate the fact that try catch has no effect with this type of checking
function WordRegEntry{
$wordPresent = Get-ItemProperty -Path $path\Word -Name AutoSaveByDefaultUserChoice
if($wordPresent){return 1}  # Returns that word is set for no autosave - true
else{return 0}   # Returns that word is NOT set to disable autosave (it's null) - false
}
function ExcelRegEntry{
$excelPresent = Get-ItemProperty -Path $path\Excel -Name AutoSaveByDefaultUserChoice
if($excelPresent){return 1}
else{return 0}
}
function PowerpointRegEntry{
$powerpointPresent = Get-ItemProperty -Path $path\Powerpoint -Name AutoSaveByDefaultUserChoice
if($powerpointPresent){return 1}
else{return 0}
}

# Set the registry settings
function SetWord{
Set-ItemProperty -Path $path\Word -Name AutoSaveByDefaultUserChoice -Value 2
$wordSet = Get-ItemProperty -Path $path\Word -Name AutoSaveByDefaultUserChoice
if($wordSet){return 1}
else{ 
Write-Host 'Error occured setting Word autosave entry'
return 0}
}
function SetExcel{
Set-ItemProperty -Path $path\Excel -Name AutoSaveByDefaultUserChoice -Value 2
$excelSet = Get-ItemProperty -Path $path\Excel -Name AutoSaveByDefaultUserChoice
if($excelSet){return 1}
else{ 
Write-Host 'Error occured setting Excel autosave entry'
return 0}
}
function SetPowerpoint{
Set-ItemProperty -Path $path\Powerpoint -Name AutoSaveByDefaultUserChoice -Value 2
$powerpointSet = Get-ItemProperty -Path $path\Powerpoint -Name AutoSaveByDefaultUserChoice
if($powerpointSet){return 1}
else{ 
Write-Host 'Error occured setting Powerpoint autosave entry'
return 0}
}

# Closest thing to C# i can get i guess ¯\_(ツ)_/¯
function Main{
if($debug){ForceReset}

$wordFound = WordRegEntry
$excelFound = ExcelRegEntry
$powerpointFound = PowerpointRegEntry

if(!$wordFound){ SetWord } # False for setting being present
if(!$excelFound){ SetExcel }
if(!$powerpointFound){ SetPowerpoint }
}
function ForceReset{
Remove-ItemProperty -Path $path\Word -Name AutoSaveByDefaultUserChoice
Remove-ItemProperty -Path $path\Excel -Name AutoSaveByDefaultUserChoice
Remove-ItemProperty -Path $path\Powerpoint -Name AutoSaveByDefaultUserChoice
}

Write-Host $PSCommandPath

Main