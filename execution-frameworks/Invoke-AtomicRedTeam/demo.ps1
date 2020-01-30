<#
(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1
choco install GoogleChrome -y --ignore-checksums
choco install atom -y
choco install git -y
choco install 7zip.install -y
choco install winrar -y
choco install procdump -y
cmd.exe /c "C:\Program Files\Git\bin\git.exe" clone https://github.com/duzvik/atomic-red-team.git C:\AtomicRedTeam
write-verbose "Installing NuGet PackageProvider"
#if needed
#choco upgrade powershell -y
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

write-verbose "Installing powershell-yaml"
Install-Module -Name powershell-yaml -Force

 cd C:\AtomicRedTeam\execution-frameworks\Invoke-AtomicRedTeam
 .\demo.ps1 *>&1 | Out-File C:\demo.log -encoding ASCII -Append


Get-Content -Path "C:\scripts\test.txt" -Wait
update winlogbeat
queue.mem:
  flush.min_events: 0
  flush.timeout: 0s

#>

Set-MpPreference -DisableRealtimeMonitoring $true




#$techniques = @("T1003", "T1086",  "T1059", "T1060", "T1105", "T1002", "T1053", "T1107", "T1057", "T1016", "T1083", "T1082", "T1036", "T1076", "T1074", "T1033", "T1018", "T1140", "T1087", "T1047", "T1102", "T1049")
$techniques = @("T1003", "T1086",  "T1059", "T1060", "T1105", "T1002", "T1053", "T1107", "T1057", "T1016", "T1083", "T1082", "T1036", "T1076", "T1074", "T1033", "T1018", "T1140", "T1087", "T1047", "T1102", "T1049", "T1112","T1065","T1050","T1110","T1100","T1063","T1012","T1114","T1085","T1119","T1070","T1088","T1069","T1007","T1048","T1117","T1158","T1099","T1035","T1097","T1015","T1075","T1040","T1223","T1124","T1098","T1136","T1135","T1081","T1031","T1170","T1084","T1197","T1485","T1134","T1191","T1218","T1037","T1004","T1010","T1489","T1141","T1201","T1028","T1126","T1138","T1122","T1183","T1115","T1222","T1216","T1096","T1123","T1179","T1089")
Import-Module C:\AtomicRedTeam\execution-frameworks\Invoke-AtomicRedTeam\Invoke-AtomicRedTeam\Invoke-AtomicRedTeam.psm1  -Force
Foreach ($t in $techniques) {
    Write-Host "Executing $t technique" -fore green
    Invoke-AtomicTest $t -PathToAtomicsFolder C:\AtomicRedTeam\atomics -Verbose
}

Write-Host "[$Test] Demo Execution finished!"

