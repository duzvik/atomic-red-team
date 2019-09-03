<#
.SYNOPSIS
    Invokes specified Atomic test(s)
.DESCRIPTION
    Invokes specified Atomic tests(s).  Optionally, you can specify if you want to generate Atomic test(s) only.
.EXAMPLE Invokes Atomic Test
    PS/> Invoke-AtomicTest T1117
.EXAMPLE Generate Atomic Test
    PS/> Invoke-AtomicTest T1117 -GenerateOnly
.NOTES
    Create Atomic Tests from yaml files described in Atomic Red Team. https://github.com/redcanaryco/atomic-red-team
.LINK
    Blog: http://subt0x11.blogspot.com/2018/08/invoke-atomictest-automating-mitre-att.html
    Github repo: https://github.com/redcanaryco/atomic-red-team
#>
function Invoke-AtomicTest {
    [CmdletBinding(DefaultParameterSetName = 'technique',
        SupportsShouldProcess = $true,
        PositionalBinding = $false,
        ConfirmImpact = 'Medium')]
    Param(
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'technique')]
        [ValidateNotNullOrEmpty()]
        [String]
        $AtomicTechnique,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'technique')]
        [String]
        $Uuid,

        [Parameter(Mandatory = $false,
            Position = 2,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'technique')]
        [switch]
        $GenerateOnly,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'technique')]
        [String[]]
        $TestNumbers,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'technique')]
        [String[]]
        $TestNames,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'technique')]
        [String]
        $PathToAtomicsFolder = "..\..\atomics"
    )
    BEGIN { } # Intentionally left blank and can be removed
    PROCESS {
        Write-Verbose -Message 'Attempting to run Atomic Techniques'
        Write-Verbose -Message "Tarcking UUID is $Uuid"
        #Write-Verbose -Message "T is $AtomicTechnique"
        #return
        $AtomicTechniqueHash = Get-AtomicTechnique -Path $PathToAtomicsFolder\$AtomicTechnique\$AtomicTechnique.yaml
        $techniqueCount = 0
        Start-Sleep -Seconds 5
        Start-Process -FilePath cmd.exe -ArgumentList "/c echo start-uuid=$Uuid"

        foreach ($technique in $AtomicTechniqueHash) {

            $techniqueCount++

            $props = @{
                Activity        = "Running $($technique.display_name.ToString()) Technique"
                Status          = 'Progress:'
                PercentComplete = ($techniqueCount / ($AtomicTechniqueHash).Count * 100)
            }
            Write-Progress @props

            Write-Debug -Message "Gathering tests for Technique $technique"

            $testCount = 0
            foreach ($test in $technique.atomic_tests) {
                $testCount++

                if ($null -ne $TestNumbers) {
                    if (-Not ($TestNumbers -contains $testCount) ) { continue }
                }

                if ($null -ne $TestNames) {
                    if (-Not ($TestNames -contains $test.name) ) { continue }
                }

                $props = @{
                    Activity        = 'Running Atomic Tests'
                    Status          = 'Progress:'
                    PercentComplete = ($testCount / ($technique.atomic_tests).Count * 100)
                }
                Write-Progress @props

                Write-Verbose -Message 'Determining tests for Windows'

                if (-Not $test.supported_platforms.Contains('windows')) {
                    Write-Verbose -Message 'Unable to run non-Windows tests'
                    continue
                }

                Write-Verbose -Message 'Determining manual tests'

                if ($test.executor.name.Contains('manual')) {
                    Write-Verbose -Message 'Unable to run manual tests'
                    continue
                }

                Write-Information -MessageData ("[********BEGIN TEST*******]`n" +
                    $technique.display_name.ToString(), $technique.attack_technique.ToString()) -Tags 'Details'

                Write-Information -MessageData $test.name.ToString() -Tags 'Details'
                Write-Information -MessageData $test.description.ToString() -Tags 'Details'

                Write-Debug -Message 'Gathering final Atomic test command'

                $finalCommand = $test.executor.command

                if ($test.input_arguments.Count -gt 0) {
                    Write-Verbose -Message 'Replacing inputArgs with default values'
                    $inputArgs = [Array]($test.input_arguments.Keys).Split(" ")
                    $inputDefaults = [Array]($test.input_arguments.Values | ForEach-Object { $_.default }).Split(" ")

                    for ($i = 0; $i -lt $inputArgs.Length; $i++) {
                        $findValue = '#{' + $inputArgs[$i] + '}'
                        $finalCommand = $finalCommand.Replace($findValue, $inputDefaults[$i])
                    }
                }

                Write-Debug -Message 'Getting executor and build command script'

                if ($GenerateOnly) {
                    Write-Information -MessageData $finalCommand -Tags 'Command'
                }
                else {
                    $test_technique = $technique.attack_technique.ToString()
                    #$test_uuid = $test.uuid
                    $test_name = $test.name

                    #if ($Uuid -and ($Uuid -ne $test_uuid)) {
                      #  continue
                    #}
                    #if ($Uuid) {
                    #    $test_uuid = $Uuid
                    #}

                    #Write-Verbose -Message "Set Winlogbeat Meta field $test_technique $test_uuid $test_name"
                    #Set-WinlogbeatMeta  -Name $test_technique -UUID $test_uuid -Rule $test_name -Verbose
                    #Set-SysmonLabel -uuid $test_uuid -path "C:\AtomicRedTeam\tools\sysmon.xml" -Verbose
                    # #Start-Sleep -Seconds 5
                    # Start-Process -FilePath cmd.exe -ArgumentList "/c echo start-uuid=$Uuid"

                    Write-Verbose -Message 'Invoking Atomic Tests using defined executor'
                    if ($pscmdlet.ShouldProcess(($test.name.ToString()), 'Execute Atomic Test')) {
                        switch ($test.executor.name) {
                            "command_prompt" {
                                Write-Verbose -Message "Command Prompt:`n $finalCommand"
                                Write-Information -MessageData "Command Prompt:`n $finalCommand" -Tags 'AtomicTest'
                                $execCommand = $finalCommand.Split("`n")
                                $execCommand | ForEach-Object { Invoke-Expression "cmd.exe /c `"$_`" " }
                                continue
                            }
                            "powershell" {
                                Write-Verbose -Message "PowerShell:`n $finalCommand"
                                Write-Information -MessageData "PowerShell`n $finalCommand" -Tags 'AtomicTest'
                                $execCommand = "Invoke-Command -ScriptBlock {$finalCommand}"
                                Invoke-Expression $execCommand
                                continue
                            }
                            default {
                                Write-Warning -Message "Unable to generate or execute the command line properly."
                                continue
                            }
                        } # End of executor switch
                    } # End of if ShouldProcess block
                    # Start-Sleep -Seconds 15
                    # Start-Process -FilePath cmd.exe -ArgumentList "/c echo stop-uuid=$Uuid"
                    #cleanup
                    # Start-Process -FilePath taskkill -ArgumentList '/F /IM calc.exe'
                    # Start-Process -FilePath taskkill -ArgumentList '/F /IM hh.exe'
                    # Start-Process -FilePath taskkill -ArgumentList '/F /IM cmd.exe'

                } # End of else statement
            } # End of foreach Test in single Atomic Technique
            Start-Sleep -Seconds 30
            Start-Process -FilePath cmd.exe -ArgumentList "/c echo stop-uuid=$Uuid"

            Write-Information -MessageData "[!!!!!!!!END TEST!!!!!!!]`n`n" -Tags 'Details'

        } # End of foreach Technique in Atomic Tests
    } # End of PROCESS block
    END { } # Intentionally left blank and can be removed
}
