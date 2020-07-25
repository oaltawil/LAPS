# Deploying the Local Administrator Password Solution (LAPS)

<p>
  <H2> Steps to be carried out on a writeable Domain Controller (not an RODC)</H3>
  
  <ol>
    <li>
      <H4>Download and install LAPS</H4>
      Please install all product features of LAPS, including the FAT client, AdmPwd.PS PowerShell module, and Group Policy Administrative Template
    </li>
    <li>
      <H4>Prepare the Active Directory domain for LAPS</H4>
      <ol>
        <li>Schedule a maintenance window</li>
        <li>Take a system state back of the Domain Controller or a backup of the Active Directory NTDS database</li>
        <li>Run the PowerShell script "Configure-ADDomain.ps1" to perform the following:
        <ol>
          <li>Extend the Active Directory Schema</li>
          <li>Grant Computers the ability to store the local Administrator password in Active Directory</li>
          <li>Grant Users and Groups the ability to view and reset the local Administrator passwords stored in Active Directory</li>
          <li>Copy the LAPS Administrative Template files to the Group Policy Central store (if configured for the domain)</li>
        </ol>
          <H5>Get-Help .\PrepareADforLAPS.ps1 -Full</H5>
      </ol>
    </li>
    <li><H4>Configure the LAPS Group Policy settings</H4>
      On the same domain controller where LAPS is installed or (if the domain is configured with a Group Policy Central Store) on any member server with the Group Policy Management Tools installed, create a new Group Policy Object or edit an existing one. The minimum required setting to enable LAPS is "Computer Configuration" -> "Policies" -> "Administrative Templates" -> "LAPS" -> "Enable local admin password management". Link the Group Policy Object to the Organizational Units specified when running the Configure-ADDomain.ps1 PowerShell script.
    </li>
    <li>Install the LAPS Client-Side Extension on all managed computers</H4>
    Use Group Policy Software Installation or an Endpoint Configuration Software, such as Microsoft Endpoint configuration Manager, to install the LAPS Windows Installer package silently. and the following silent installation command: msiexec.exe /i LAPS.x64.msi /q</li>
  </ol>
</p>
