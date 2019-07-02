<#
(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1
choco install GoogleChrome -y --ignore-checksums
choco install git -y
cmd.exe /c "C:\Program Files\Git\bin\git.exe" clone https://github.com/duzvik/atomic-red-team.git C:\AtomicRedTeam
write-verbose "Installing NuGet PackageProvider"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

write-verbose "Installing powershell-yaml"
Install-Module -Name powershell-yaml -Force
#>



$techniques = @("T1036", "T1057", "T1088","T1050", "T1053", "T1059", "T1060")
Import-Module C:\AtomicRedTeam\execution-frameworks\Invoke-AtomicRedTeam\Invoke-AtomicRedTeam\Invoke-AtomicRedTeam.psm1
Foreach ($t in $techniques) {
    Write-Host "Executing $t technique" -fore green
    $tObj= Get-AtomicTechnique -Path "C:\AtomicRedTeam\atomics\$t\$t.yaml"
    Invoke-AtomicTest $tObj -Verbose
}


Write-Host "[$Test] Demo Execution finished!"
