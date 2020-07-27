<#
.SYNOPSIS
    This script prepares an Active Directory domain for local Administrator password management using LAPS
.DESCRIPTION
    This script should be executed on a domain controller with all the product features of LAPS installed, particularly, the AdmPwd.PS PowerShell module
    
    There are two mandatory parameters:
    (*) OrgUnits: a list of Organizational Units containing the computers that will be managed by LAPS
    (*) AllowedPrincipals: a list of Users and Groups that will be granted the ability to read and reset the local Administrator password
    
    For more details about the LAPS cmdlets used in this script, please refer to the LAPS Operations Guide:
    https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS_OperationsGuide.docx
.EXAMPLE
    .\LAPS.ps1 -OrgUnits "Servers", "OU=Workstations,DC=vsrad,DC=ca" -AllowedPrincipals "VSRAD\LocalAdmPwdManagers", "VSRAD\DesktopAdmins"
.PARAMETER OrgUnits
    A list of OU's containing the computers that will be managed by LAPS. 
    You can use the OU's Common Name, e.g. "Servers", or the OU's Distinguished Name, e.g. "OU=Workstations,DC=vsrad,DC=ca"
.PARAMETER AllowedPrincipals
    A list of Users and Groups that will be granted the ability to read and reset the local Administrator password
    Use the following format for users and groups: "<DomainName>\<User or Group Name>""
#>

#Requires -Modules "AdmPwd.PS"
#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $OrgUnits,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $AllowedPrincipals
)

##########################
# On a Domain Controller #
##########################

if (-not (Get-Module -ListAvailable | Where-Object {$_.Name -match "AdmPwd.PS"})) 
{
    Write-Host "`nThe LAPS AdmPwd.PS PowerShell module could not be found."
    Write-Host "`nPlease install the LAPS PowerShell module and try again"
    Exit
}

# Load the LAPS module
Import-Module AdmPwd.PS

<# Extend the AD Schema by adding two new attributes to the computer class: 
 1. ms-Mcs-AdmPwd – Stores the password in clear text
 2. ms-Mcs-AdmPwdExpirationTime – Stores the time to reset the password
#>
Write-Host "`n`nUpdating the Active Directory schema"
Update-AdmPwdADSchema -Verbose

Write-Host "`n`nGranting the computer (SELF) account the permissions required to update the password and expiration timestamp of its own managed local Administrator password"
$OrgUnits | ForEach-Object {Set-AdmPwdComputerSelfPermission -OrgUnit $_ -Verbose}

Write-Host "`n`nGranting specific users and groups the ability to read the local Administrator passwords"
$OrgUnits | ForEach-Object {Set-AdmPwdReadPasswordPermission -OrgUnit $_ -AllowedPrincipals $AllowedPrincipals -Verbose}

Write-Host "`n`nGranting specific users and groups the ability to reset the local Administrator passwords"
$OrgUnits | ForEach-Object {Set-AdmPwdResetPasswordPermission -OrgUnit $_ -AllowedPrincipals $AllowedPrincipals -Verbose}

# Copy the LAPS Administrative Template files to the Group Policy Central store (if configured for the domain)
$ADDomain = (wmic computersystem get domain)[2].Trim()
$GroupPolicyCentralStore = "\\$ADDomain\SYSVOL\$ADDomain\Policies\PolicyDefinitions"

if (Test-Path $GroupPolicyCentralStore)
{
Write-Host "`n`nCopying the LAPS Administrative Template files to the Group Policy Central store"

    Copy-Item -Path "C:\Windows\PolicyDefinitions\AdmPwd.admx" -Destination (Join-Path -Path $GroupPolicyCentralStore -ChildPath "AdmPwd.admx") -Force -Verbose
    Copy-Item -Path "C:\Windows\PolicyDefinitions\en-US\AdmPwd.adml" -Destination (Join-Path -Path (Join-Path -Path $GroupPolicyCentralStore -ChildPath "en-US") -ChildPath "AdmPwd.adml") -Force -Verbose
}
