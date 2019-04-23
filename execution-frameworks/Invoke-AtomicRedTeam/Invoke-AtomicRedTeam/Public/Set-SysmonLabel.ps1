<#
.SYNOPSIS
    Add meta fields to sysmon config
.DESCRIPTION
    Add meta fields to sysmon config
.EXAMPLE Add meta fields to sysmon config
    PS/> Set-SysmonLabel -uuid "3333" -path "C:\config_2222.xml" -Verbose
.NOTES
.LINK
#>

function Set-SysmonLabel {
  Param ([String]$uuid, [String]$path)
  if(!(Test-Path -Path $path )){
    Write-Host "Sysmon config not exists at $path"
  	exit
  }
  $new_config_file = (get-item $path).Directory.Fullname
  $new_config_file = "new_config_file/config_$uuid.xml"

  #try extract current uuid
  $text = (Get-Content $path -Raw)
  $Pat1 = [regex]  'mitre_test_uuid=(.*?),technique_id'
  $existed_uuid = [regex]::Match($text, $Pat1).Groups[1].Value
  if(!$existed_uuid ){
    Write-Verbose "Seems $path is fresh config"
    $text -replace '"technique_id=',"`"mitre_test_uuid=$uuid,technique_id="| Set-Content -path $new_config_file
  } else {
    Write-Verbose "Found $existed_uuid in config, lets replace it"
    $text -replace "`"mitre_test_uuid=$existed_uuid,","`"mitre_test_uuid=$uuid,"| Set-Content -path $new_config_file
  }
  Write-Verbose "Done!"
  & 'C:\Program Files (x86)\Simplerity\SimplerityMon\SimplerityMon64.exe' -c $new_config_file
  return $true
}

