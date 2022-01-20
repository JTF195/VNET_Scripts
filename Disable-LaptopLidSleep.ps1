#Enable High performance
$powerScheme = "High performance"

#Find selected power scheme guid
$guidRegex = "(\{){0,1}[a-fA-F0-9]{8}-([a-fA-F0-9]{4}-){3}[a-fA-F0-9]{12}(\}){0,1}"
[regex]$regex = $guidRegex
$guid = ($regex.Matches((PowerCfg /LIST | where {$_ -like "*$powerScheme*"}).ToString())).Value

#Change preferred scheme
$regGuid = "{025A5937-A6BE-4686-A844-36FE4BEC8B6D}"
$currentPreferredScheme = Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\ControlPanel\NameSpace\$regGuid -Name PreferredPlan 
if ($currentPreferredScheme.PreferredPlan -ne $guid) {
    Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer\ControlPanel\NameSpace\$regGuid -Name PreferredPlan -Value $guid
    Write-Host -ForegroundColor Green "Preferred scheme successfully changed. Preferred scheme is now '$powerScheme'." 
} else {
    Write-Host -ForegroundColor Yellow "Preferred scheme does not need to be changed. Preferred scheme is '$powerScheme'." 
}

#Change active scheme
$currentActiveScheme = PowerCfg /GETACTIVESCHEME
if ($currentActiveScheme | where {$_ -notlike "*$guid*"}) {
    PowerCfg /SETACTIVE $guid
    Write-Host -ForegroundColor Green "Power scheme successfully changed. Current scheme is now '$powerScheme'." 
} else {
    Write-Host -ForegroundColor Yellow "Power scheme does not need to be changed. Current scheme is '$powerScheme'." 
}

#Do not sleep when closing lid on AC
PowerCfg /SETACVALUEINDEX $guid SUB_BUTTONS LIDACTION 000
Write-Host -ForegroundColor Green "No action when closing lid on AC."







$DesiredValue = 0
$SettingSubGroupID = '4f971e89-eebd-4455-a8de-9e59040e7347'
$SettingGUID       = '5ca83367-6e45-459f-a27b-476b1d01c936'
    
#Select Current Power Plan
$currentPlan = Get-CimInstance -namespace "root\cimv2\power" -class Win32_powerplan | where {$_.IsActive} 
$schemeID= $currentPlan.InstanceID -replace "^Microsoft:PowerPlan\\{(.*?)}$",'$1'
    
#Apply Settings to Specific Power Plan by GUID
#$specificPowerPlanID = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c' #High performance
#$currentPlan = Get-CimInstance -namespace "root\cimv2\power" -class Win32_powerplan | where {$_.InstanceID -match $specificPowerPlanID} 
#$schemeID= $currentPlan.InstanceID -replace "^Microsoft:PowerPlan\\{(.*?)}$",'$1'
#Optionally Activate this specific Power Plan
#powercfg -SetActive $specificPowerPlanID

$currentPlanLidCloseSettings = Get-CimAssociatedInstance -InputObject $currentPlan -ResultClassName 'win32_powersettingdataindex' |where {$_.InstanceID -match $SettingGUID} 
$improperSettings = $currentPlanLidCloseSettings |where {$_.settingIndexValue -ne $DesiredValue}
If ($improperSettings) {
    Write-Verbose -Verbose "Found $(@($improperSettings).Count) settings in current power plan that do not match. Fixing"
    #Aliases are taken from 'powercfg /Aliases'
    #SubGroup GUID Alias SUB_BUTTONS = 4f971e89-eebd-4455-a8de-9e59040e7347 
    #SubGroup GUID Alias LIDACTION   = 5ca83367-6e45-459f-a27b-476b1d01c936 
    
    powercfg -SETACVALUEINDEX $schemeID SUB_BUTTONS LIDACTION $DesiredValue
    #powercfg -SETDCVALUEINDEX $schemeID SUB_BUTTONS LIDACTION $DesiredValue
    
    #powercfg -SETACVALUEINDEX $schemeID $SettingSubGroupID $SettingGUID $DesiredValue
    #powercfg -SETDCVALUEINDEX $schemeID $SettingSubGroupID $SettingGUID $DesiredValue
    
    Write-Verbose -Verbose "New Values are below" 
    Get-CimAssociatedInstance -InputObject $currentPlan -ResultClassName 'win32_powersettingdataindex' |where {$_.InstanceID -match $SettingGUID} 
} 
else {
    Write-Verbose -Verbose "All settings are already correct" 
}