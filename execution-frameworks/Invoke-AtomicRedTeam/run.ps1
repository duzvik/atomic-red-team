<#
.SYNOPSIS
    Execure atomic test
.DESCRIPTION
    Execure atomic test
.EXAMPLE Add meta fields to winlogbeat config
    PS/> run.ps1 -Path C:\AtomicRedTeam\atomics\T1085\T1085.yaml
.NOTES
.LINK
#>

Param
(
  [Parameter(Mandatory=$true, Position=0)]
  [string] $Test
)

Import-Module C:\AtomicRedTeam\execution-frameworks\Invoke-AtomicRedTeam\Invoke-AtomicRedTeam\Invoke-AtomicRedTeam.psm1
$t= Get-AtomicTechnique -Path "C:\AtomicRedTeam\atomics\$Test\$Test.yaml"
Invoke-AtomicTest $t -Verbose

Write-Host "[$Test] Execution finished!"