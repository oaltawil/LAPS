<H2>Deploying the Local Administrator Password Solution (LAPS)</H2>
<p>
Membership in the "Schema Admins" and "Domain Admins" security groups is required to configure the Active Directory domain for LAPS.  To avoid pash-the-hash attacks, members of priviliged Active Directory groups should only logon to domain controllers and not to down-level member servers.  Therefore, all the instructions below should be carried out on a writeable Domain Controller, not an RODC (Read-Only Domain Controller), with the Remote Server Administration Tools for Active Directory Domain Services Installed (the Active Directory PowerShell module is required by the "Configure-ADDomain.ps1" PowerShell script).
</p>
<p>
  Download the "LAPS.x64.msi" Windows Installer package from https://www.microsoft.com/en-us/download/details.aspx?id=46899.  
  The LAPS installer consists of the following 4 components or features:
  <ol>
    <li> AdmPwd GPO Extension</li>
    <li> Fat Client UI</li>
    <li> PowerShell module</li>
    <li> GPO Editor templates</li>
  </ol>
  Please note that by default only the "AdmPwd GPO extension" is installed.
</p>
<p>
  <ol>
    <li>
      <H3>Install LAPS on an Active Directory Domain Controller</H3>
      <ol>
        <li>Install all product features of LAPS, including the FAT client, AdmPwd.PS PowerShell module, and Group Policy Administrative Template</li>
        <li>On Windows Server with Desktop Experience, double-click the "LAPS.x64.msi" installer package and in the "Custom Setup" page, click on the drop-down arrow beside "Management Tools", and select "Entire feature will be installed on local hard drive
          <p><img alt="Image" title="LAPS Product Features" src="LAPSInstallAllProductFeatures.png" /></p>
          <p><img alt="Image" title="LAPS Product Features" src="LAPSProductFeatures.png" /></p>
        </li>
        <li>On Windows Server Core, using the following installation command:
          <p>"msiexec.exe /i LAPS.x64.msi /q ADDLOCAL=CSE,Management.UI,Management.PS,Management.ADMX"</p>
        </li>
      </ol>
    </li>
    <li>
      <H3>Prepare the Active Directory domain for LAPS</H3>
      <ol>
        <li>Schedule a Maintenance Window</li>
        <li>Take a System State Backup of the Domain Controller</li>
        <li>Run the PowerShell script "Configure-ADDomain.ps1" to perform the following:
        <ol>
          <li>Extend the Active Directory schema</li>
          <li>Grant Computers the ability to store the local Administrator password in Active Directory</li>
          <li>Grant Users and Groups the ability to view and reset the local Administrator passwords stored in Active Directory</li>
          <li>Copy the LAPS Administrative Template files to the Group Policy Central store (if configured for the domain)</li>
        </ol>
        <p>Type the following command to obtain more information about running the script: <H4>Get-Help .\Configure-ADDomain.ps1 -Full</H4></p>
        </li>
      </ol>
    </li>
    <li><H3>Configure the LAPS Group Policy settings</H3>
    <ol>
      <li>If the Group Policy Central Store is configured for the domain, use any domain-joined server or workstation with the "Remote Server Administration Tools" "Group Policy Management Tools" feature enabled</li>
      <li>If the Group Policy Central Store is not configured for the domain, use the same Domain Controller where LAPS is installed</li>
      <li>Using the "Group Policy Management Console", create and edit a new Group Policy Object or edit an existing one</li>
      <li>In the "Group Policy Management Editor", enable the following Group Policy setting: 
        <p>"Computer Configuration" -> "Policies" -> "Administrative Templates" -> "LAPS" -> "Enable local admin password management"</p>
      </li>
      <li>Link the Group Policy Object to the Organizational Units specified when running the Configure-ADDomain.ps1 PowerShell script</li>
    </ol>
    </li>
    <li><H3>Install the LAPS Client-Side Extension on all managed computers</H3>
    Use Group Policy Software Installation or an Endpoint Configuration/Management Product, such as Microsoft Endpoint Manager, to silently install the LAPS Windows Installer package to all computers: msiexec.exe /i LAPS.x64.msi /q
    </li>
  </ol>
</p>
<p>
  <H2>Retrieving the local Administrator password for a given Computer</H2>
  <p> 
    Your user account or a group that you are a member of must have been specified as one of the "AllowedPrincipals" when running the "Configure-ADDomain.ps1" PowerShell script. Otherwise, you won't have the security permissions required to view and reset local Administrator passwords.  There are three methods that you can use to retrieve the local Admistrator Password:
  </p>
  <ol>
    <li><H3>LAPS Fat Client UI</H3>
      The "LAPS UI" application can be used to read and reset local Administrator passwords:
      <p><img alt="Image" title="LAPS FAT Client" src="LAPSFatClient.png" /></p>
    </li>
    <li><H3>LAPS PowerShell Module</H3>
      The following cmdlets in the LAPS PowerShell module can be used to read and reset local Administrator passwords:
      <p>Get-AdmPwdPassword -ComputerName "ComputerName"</p>
      <p>Reset-AdmPwdPassword -ComputerName "ComputerName"</p>
      <p><img alt="Image" title="LAPS PowerShell Cmdlets" src="LAPSPowerShellCmdlets.png" /></p>
    </li>
    <li><H3>Active Directory Users and Computers Snap-In Console</H3>
      <ol>
        <li>Install the "Active Directory Users and Computers" snap-in console by enabling the "Remote Server Administration Tools" for "Active Directory Domain Services" feature on any domain-joined server or workstation</li>
        <li>Launch the "Active Directory Users and Computers" snap-in console</li>
        <li>Click on the "View" menu and select "Advanced Features"</li>
        <li>Right-click the Computer object and select "Properties"</li>
        <li>Click on the "Attributes Editor" tab and read the value for the "ms-Mcs-AdmPwd" attribute</li>
      </ol>
      <p><img alt="Image" title="Active Directory Users and Computers Attribute Editor" src="ADUsersComputersAttributeEditor.png" /></p>
    </li>
  </ol>
</p>
