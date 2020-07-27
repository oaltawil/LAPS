# Guide to implementing and using the Local Administrator Password Solution (LAPS)

## Deploying LAPS

Membership in the "Schema Admins" and "Domain Admins" security groups is required to configure the Active Directory domain for LAPS.  To avoid pash-the-hash attacks, members of priviliged Active Directory groups should only logon to domain controllers and not to down-level member servers.  Therefore, the first two steps in this guide should be carried out on a writeable Domain Controller, not an RODC (Read-Only Domain Controller).

Download the "LAPS.x64.msi" Windows Installer package from [LAPS Download Page](https://www.microsoft.com/en-us/download/details.aspx?id=46899). The LAPS installer consists of the following 4 components or features:

1. AdmPwd GPO Extension
2. Management Tools\Fat Client UI
3. Management Tools\PowerShell module
4. Management Tools\GPO Editor templates

![LAPS Product Features](/images/LAPSProductFeatures.png)
  
Please note that by default only the "AdmPwd GPO extension" (or LAPS Group Policy Client-Side Extension CSE) is installed.

### 1. Install LAPS on an Active Directory Domain Controller

1.1. Install all product features of LAPS, including the FAT client, AdmPwd.PS PowerShell module, and Group Policy Administrative Template

1.2. On Windows Server with Desktop Experience, double-click the "LAPS.x64.msi" installer package and in the "Custom Setup" page, click on the drop-down arrow beside "Management Tools", and select "Entire feature will be installed on local hard drive

![LAPS Install All Product Features](/images/LAPSInstallAllProductFeatures.png)

1.3. On Windows Server Core, using the following installation command:

    msiexec.exe /i LAPS.x64.msi /q ADDLOCAL=CSE,Management.UI,Management.PS,Management.ADMX

1.4 In addition to the domain controller, desktop managers and password administrators should also install all product features of LAPS on their administrative workstations as they'll need the LAPS Management Tools to manage local Administrator passwords.

### 2. Prepare the Active Directory domain for LAPS

2.1 Discover all user accounts and group accounts with the "All extended rights" permission on all the OUs containing computer objects that will be managed by LAPS

    Find-AdmPwdExtendedrights -Identity "Name or Distinguished Name of OU to search for permissions"

If any user accounts or group accounts should not have access to local Administrator passwords, the "All extended rights" permission for these accounts should be removed from the OUs.

![Remove All extended rights permission](/images/AllExtendedRightsPermission.png)

2.2. Schedule a Maintenance Window

2.3. Take a System State Backup of the Domain Controller

2.4. Run the PowerShell script "Configure-ADDomain.ps1" to perform the following:

2.4.1. Extend the Active Directory schema by running the following cmdlet:

    Update-AdmPwdADSchema

2.4.2. Grant Computers the ability to store the local Administrator password and password expiration time in Active Directory by running the following cmdlet:

    Set-AdmPwdComputerSelfPermission -Identity "Name or Distinguished Name of OU (in case of duplicate names) to delegate permissions"

The above cmdlet assigns the Computer (SELF) account the "Write ms-Mcs-AdmPwd" permission on the computer objects under the specified OU

2.4.3. Grant Users and Groups the ability to view and reset the local Administrator passwords stored in Active Directory by running the following two cmdlets, respectively:

    Set-AdmPwdReadPasswordPermission -Identity "Name or Distinguished Name of the OU to delegate permissions" -AllowedPrincipals "Users and/or Groups"

The above cmdlet assigns the "Read ms-Mcs-AdmPwd" permission on the computer objects under the specified OU to the allowed users and groups

    Set-AdmPwdResetPasswordPermission -Identity "Name or Distinguished Name of the OU to delegate permissions" -AllowedPrincipals "Users and/or Groups"

The previous cmdlet assigns the "Read ms-Mcs-AdmPwdExpirationTime" and "Write ms-McsAdmPwdExpirationTime" permissions on the computer objects under the specified OU to the allowed users and groups

2.4.4. Copy the LAPS Administrative Template files to the Group Policy Central store (if configured for the domain).

Type the following command for help with running the script:

#### Get-Help .\Configure-ADDomain.ps1 -Full</p>

### 3. Configure the LAPS Group Policy settings

3.1. Use any domain-joined server or workstation and enable the Remote Server Administration Tools Group Policy Management Console feature: [Remote Server Administration Tools for Windows Operating Systems](https://support.microsoft.com/en-us/help/2693643/remote-server-administration-tools-rsat-for-windows-operating-systems)

3.2. If the Group Policy Central Store is not configured for the domain, install the LAPS "GPO Editor templates" product feature to install the LAPS Administrative Template files locally

3.3. Using the "Group Policy Management Console", create and edit a new Group Policy Object or edit an existing one

3.4. In the "Group Policy Management Editor", enable the following Group Policy setting:
  
    Computer Configuration\Policies\Administrative Templates\LAPS\Enable local admin password management

3.5. Link the Group Policy Object to the Organizational Units specified when running the Configure-ADDomain.ps1 PowerShell script

### 4. Install the LAPS Client-Side Extension on all managed computers

Use any Electronic Software Distribution method, such as Group Policy Software Installation or Microsoft Endpoint Manager, to silently install the LAPS Windows Installer package on all computers: "msiexec.exe /i LAPS.x64.msi /q"

## Retrieving the local Administrator password for a given Computer

Your user account or a group that you are a member of must have been specified as one of the "AllowedPrincipals" when running the "Configure-ADDomain.ps1" PowerShell script. Otherwise, you won't have the security permissions required to view and reset local Administrator passwords.  There are three methods that you can use to retrieve the local Admistrator Password:

### 1. LAPS Fat Client UI

The "LAPS UI" application can be used to read and reset local Administrator passwords:

![LAPS FAT Client](/images/LAPSFatClient.png)

### 2. LAPS PowerShell Module

The following cmdlets in the LAPS PowerShell module (AdmPwd.PS) can be used to read and reset local Administrator passwords, respectively:

    Get-AdmPwdPassword "ComputerName"

    Reset-AdmPwdPassword "ComputerName"

![LAPS PowerShell Cmdlets](/images/LAPSPowerShellCmdlets.png)

Type the following command to obtain all the cmdlets available in the LAPS PowerShell module:

Get-Command -Module AdmPwd.PS

### 3. Active Directory Users and Computers Snap-In Console

3.1. Use any domain-joined server or workstation and install the "Active Directory Users and Computers" snap-in console by enabling the Remote Server Administration Tools for Active Directory Domain Services feature: [Remote Server Administration Tools for Windows Operating Systems](https://support.microsoft.com/en-us/help/2693643/remote-server-administration-tools-rsat-for-windows-operating-systems)

3.2. Launch the "Active Directory Users and Computers" snap-in console

3.3. Click on the "View" menu and select "Advanced Features"

3.4. Right-click the Computer object and select "Properties"

3.5. Click on the "Attributes Editor" tab and read the value for the "ms-Mcs-AdmPwd" attribute

![Active Directory Users and Computers Attribute Editor](/images/ADUsersComputersAttributeEditor.png)
