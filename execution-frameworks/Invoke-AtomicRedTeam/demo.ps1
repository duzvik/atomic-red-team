<#
(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1
choco install GoogleChrome -y --ignore-checksums
choco install git -y
choco install 7zip.install
cmd.exe /c "C:\Program Files\Git\bin\git.exe" clone https://github.com/duzvik/atomic-red-team.git C:\AtomicRedTeam
write-verbose "Installing NuGet PackageProvider"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

write-verbose "Installing powershell-yaml"
Install-Module -Name powershell-yaml -Force
#>



$techniques = @("T1055")#, "T1057", "T1088","T1050", "T1053", "T1059", "T1060")
Import-Module C:\atomic-red-team\execution-frameworks\Invoke-AtomicRedTeam\Invoke-AtomicRedTeam\Invoke-AtomicRedTeam.psm1  -Force
Foreach ($t in $techniques) {
    Write-Host "Executing $t technique" -fore green
    Invoke-AtomicTest $t -Uuid $t"_atomicteest" -PathToAtomicsFolder C:\atomic-red-team\atomics -Verbose
    #Write-Host "C:\atomic-red-team\atomics\$t\$t.yaml"
    #$tObj= Get-AtomicTechnique -Path "C:\atomic-red-team\atomics\$t\$t.yaml"
    #Invoke-AtomicTest $tObj -Verbose
}


Write-Host "[$Test] Demo Execution finished!"
