<#
.SYNOPSIS
    Add meta fields to winlogbeat config
.DESCRIPTION
    Add meta fields to winlogbeat config
.EXAMPLE Add meta fields to winlogbeat config
    PS/> Set-WinlogbeatMeta -Name T1117
.NOTES
.LINK
#>

function Set-WinlogbeatMeta {
    Param
     (
          [Parameter(Mandatory=$true, Position=0)]
          [string] $Name,
          [Parameter(Mandatory=$true, Position=1)]
          [string] $UUID,
          [Parameter(Mandatory=$true, Position=2)]
          [string] $Rule
     )
    Begin { Write-Debug -Message "Setting winlogbeat meta field to $Name" }


    Process
    {
        Write-Verbose -Message 'Attempting to update winlogbeat meta'
        Start-Sleep -Seconds 60
        #Stop-Service winlogbeat
        # Import-Module C:\ps-yaml\powershell-yaml.psm1
        $config_path = 'C:\Program Files (x86)\Simplerity\Winlogbeat\winlogbeat.yml'
        [string[]]$fileContent = Get-Content $config_path
        $content = ''
        foreach ($line in $fileContent) { $content = $content + "`n" + $line }
        $yaml = ConvertFrom-YAML $content
        #$yaml.fields.metta_mitre_attack_technique = 'T1085'
        $yaml.fields.metta_techniquue = $Name
        $yaml.fields.metta_rule_name = $Rule
        $yaml.fields.metta_rule_uuid = $Uuid

        $new_config = ConvertTo-YAML $yaml
        $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
        [System.IO.File]::WriteAllLines($config_path, $new_config, $Utf8NoBomEncoding)
        #Start-Service winlogbeat
        Restart-Service winlogbeat
        Write-Verbose -Message "Done!"
        #Start-Sleep -Seconds 5
    }
}
