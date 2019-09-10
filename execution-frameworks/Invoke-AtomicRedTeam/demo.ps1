<#
(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1
choco install GoogleChrome -y --ignore-checksums
choco install git -y
choco install 7zip.install -y
choco install winrar -y
choco install procdump -y
cmd.exe /c "C:\Program Files\Git\bin\git.exe" clone https://github.com/duzvik/atomic-red-team.git C:\AtomicRedTeam
write-verbose "Installing NuGet PackageProvider"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

write-verbose "Installing powershell-yaml"
Install-Module -Name powershell-yaml -Force

.\demo.ps1 *>&1 | Out-File C:\demo.log -encoding ASCII -Append


Get-Content -Path "C:\scripts\test.txt" -Wait
update winlogbeat
queue.mem:
  flush.min_events: 0
  flush.timeout: 0s

#>



$techniques = @("T1003", "T1086",  "T1059", "T1060", "T1105", "T1002", "T1053", "T1107", "T1057", "T1016", "T1083", "T1082", "T1036", "T1076", "T1074", "T1033", "T1018", "T1140", "T1087", "T1047", "T1102", "T1049")
Import-Module C:\AtomicRedTeam\execution-frameworks\Invoke-AtomicRedTeam\Invoke-AtomicRedTeam\Invoke-AtomicRedTeam.psm1  -Force
Foreach ($t in $techniques) {
    Write-Host "Executing $t technique" -fore green
    Invoke-AtomicTest $t -PathToAtomicsFolder C:\AtomicRedTeam\atomics -Verbose
    #Write-Host "C:\atomic-red-team\atomics\$t\$t.yaml"
    #$tObj= Get-AtomicTechnique -Path "C:\atomic-red-team\atomics\$t\$t.yaml"
    #Invoke-AtomicTest $tObj -Verbose
}


Write-Host "[$Test] Demo Execution finished!"

