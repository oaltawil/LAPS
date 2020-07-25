# LAPS
<H1> Deploying the Local Administrator Password Solution (LAPS) </H1>

<H2> Steps to be carried out on a writeable Domain Controller (not an RODC): </H2>

1.	Download LAPS and install all its product features including the FAT client, AdmPwd.PS PowerShell module, and Group Policy Administrative Template

2.	Prepare the Active Directory domain for LAPS.

2.1 Schedule a maintenance window
2.2 Take a system state back of the Domain Controller or a backup of the Active Directory NTDS database 
2.3 Run the PowerShell script "PrepareADforLAPs.ps1" to acheive the following actions: 
    a. Extend the Active Directory Schema
    b. Grant Computers the ability to store the local Administrator password in Active Directory
    c. Grant Users and Groups the ability to view and reset the local Administrator passwords stored in Active Directory
    
    Get-Help .\PrepareADforLAPS.ps1 -Full

3.	Configure the LAPS Group Policy settings either on the same Domain Controller or on any member server after copying the LAPS Administrative Template files to the Group Policy Central Store

4.	Install the LAPS Client-Side Extension on all managed computers using Group Policy Software Installation or an Endpoint Configuration Software and the following silent installation command: msiexec.exe /i LAPS.x64.msi /q
