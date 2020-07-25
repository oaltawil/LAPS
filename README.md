# LAPS
<H1> Deploying the Local Administrator Password Solution (LAPS) </H1>

<H3> Steps to be carried out on a writeable Domain Controller (not an RODC)</H3>

<ol>
  <li>Download LAPS and install all its product features including the FAT client, AdmPwd.PS PowerShell module, and Group Policy Administrative Template</li>

  <li>Prepare the Active Directory domain for LAPS
    <ol>
      <li>Schedule a maintenance window</li>
      <li>Take a system state back of the Domain Controller or a backup of the Active Directory NTDS database</li>
      <li>Run the PowerShell script "PrepareADforLAPs.ps1" to achieve the following:
      <ol>
        <li>Extend the Active Directory Schema</li>
        <li>Grant Computers the ability to store the local Administrator password in Active Directory</li>
        <li>Grant Users and Groups the ability to view and reset the local Administrator passwords stored in Active Directory</li>
      </ol>
        <H4>Get-Help .\PrepareADforLAPS.ps1 -Full</H4>
    </ol>
  </li>

  <li>Configure the LAPS Group Policy settings either on the same Domain Controller or on any member server after copying the LAPS Administrative Template files to the Group Policy Central Store</li>

  <li>Install the LAPS Client-Side Extension on all managed computers using Group Policy Software Installation or an Endpoint Configuration Software and the following silent installation command: msiexec.exe /i LAPS.x64.msi /q</li>

</ol>
