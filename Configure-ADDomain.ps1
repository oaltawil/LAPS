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

# Load the LAPS module
Import-Module AdmPwd.PS

# Import the Active Directory module
Import-Module ActiveDirectory

<# Extend the AD Schema by adding two new attributes to the computer class: 
 1. ms-Mcs-AdmPwd – Stores the password in clear text
 2. ms-Mcs-AdmPwdExpirationTime – Stores the time to reset the password
#>
Update-AdmPwdADSchema

# Grant the computer (SELF) account the write permissions required to update the password and expiration timestamp of its own managed local Administrator password
$OrgUnits | ForEach-Object {Set-AdmPwdComputerSelfPermission -OrgUnit $_}

# Grant users and groups the permission to read the passwords
$OrgUnits | ForEach-Object {Set-AdmPwdReadPasswordPermission -OrgUnit $_ -AllowedPrincipals $AllowedPrincipals}

# Grant users and groups the permision to force a password reset
$OrgUnits | ForEach-Object {Set-AdmPwdResetPasswordPermission -OrgUnit $_ -AllowedPrincipals $AllowedPrincipals}

# Copy the LAPS Administrative Template files to the Group Policy Central store (if configured for the domain)
$ADDomain = (Get-ADDomain).DNSRoot
$GroupPolicyCentralStore = "\\$ADDomain\SYSVOL\$ADDomain\Policies\PolicyDefinitions"

if (Test-Path $GroupPolicyCentralStore)
{
    Copy-Item -Path "C:\Windows\PolicyDefinitions\AdmPwd.admx" -Destination (Join-Path -Path $GroupPolicyCentralStore -ChildPath "AdmPwd.admx" -Force)
    Copy-Item -Path "C:\Windows\PolicyDefinitions\en-US\AdmPwd.adml" -Destination (Join-Path -Path $GroupPolicyCentralStore -ChildPath "en-US" -AdditionalChildPath "AdmPwd.adml" -Force)
}
