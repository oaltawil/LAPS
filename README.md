# LAPS
How to install and configure the Local Administrator Password Solution (LAPS)
On a Domain Controller: 

1.	Download LAPS and install all its product features including the FAT client, AdmPwd.PS PowerShell module, and Group Policy Administrative Template

2.	Run the script PrepareADforLAPs.ps1 to perfom the following actions: 
    a. Extend the Active Directory Schema
    b. Grant Computers the ability to store the local Administrator password in Active Directory
    c. Grant Users and Groups the ability to view and reset the local Administrator passwords stored in Active Directory

3.	Configure the LAPS Group Policy settings either on the same Domain Controller or on any member server after copying the LAPS Administrative Template files to the Group Policy Central Store

4.	Install the LAPS Client-Side Extension on all managed computers using Group Policy Software Installation or an Endpoint Configuration Software and the following silent installation command: msiexec.exe /i LAPS.x64.msi /q
