# Deploying the Local Administrator Password Solution (LAPS)

<p>
  <ol>
    <li>
      <H3>Install LAPS on a Active Directory Domain Controller</H3>
      <ol>
        <li>Login to a writeable Active Directory Domain Controller (not an RODC) using a user account that is a member of the "Schema Admins" and "Domain Admins" security groups</li>
        <li>Download LAPS from the following URL: https://www.microsoft.com/en-us/download/details.aspx?id=46899</li>
        <li>Install all product features of LAPS, including the FAT client, AdmPwd.PS PowerShell module, and Group Policy Administrative Template</li>
      </ol>
    </li>
    <li>
      <H3>Prepare the Active Directory domain for LAPS</H3>
      <ol>
        <li>Schedule a Maintenance Window</li>
        <li>Take a System State Backup or a BareMetal Backup of the Domain Controller. Alternatively you could backup the Active Directory NTDS database using ntdsutil.exe</li>
        <li>Run the PowerShell script "Configure-ADDomain.ps1" to perform the following:
        <ol>
          <li>Extend the Active Directory Schema</li>
          <li>Grant Computers the ability to store the local Administrator password in Active Directory</li>
          <li>Grant Users and Groups the ability to view and reset the local Administrator passwords stored in Active Directory</li>
          <li>Copy the LAPS Administrative Template files to the Group Policy Central store (if configured for the domain)</li>
        </ol>
          <H4>Get-Help .\PrepareADforLAPS.ps1 -Full</H4>
      </ol>
    </li>
    <li><H3>Configure the LAPS Group Policy settings</H3>
      On the same domain controller where LAPS is installed or (if the domain is configured with a Group Policy Central Store) on any member server with the Group Policy Management Tools installed, create a new Group Policy Object or edit an existing one. The minimum required setting to enable LAPS is "Computer Configuration" -> "Policies" -> "Administrative Templates" -> "LAPS" -> "Enable local admin password management". Link the Group Policy Object to the Organizational Units specified when running the Configure-ADDomain.ps1 PowerShell script.
    </li>
    <li><H3>Install the LAPS Client-Side Extension on all managed computers</H3>
    Use Group Policy Software Installation or an Endpoint Configuration/Management Product, such as Microsoft Endpoint Manager, to silently install the LAPS Windows Installer package to all computers: msiexec.exe /i LAPS.x64.msi /q</li>
  </ol>
</p>
