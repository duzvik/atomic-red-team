function Manager-Process-Start ([string]$fileName, [string]$arg) {
  $pinfo = New-Object System.Diagnostics.ProcessStartInfo
  $pinfo.FileName = $fileName
  $pinfo.Verb = "runas"
  $pinfo.RedirectStandardError = $true
  $pinfo.RedirectStandardOutput = $true
  $pinfo.UseShellExecute = $false
  $pinfo.Arguments = $arg
  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $pinfo
  $p.Start() | Out-Null
  $p.WaitForExit()
  $stdout = $p.StandardOutput.ReadToEnd()
  $stderr = $p.StandardError.ReadToEnd()
  $exitCode = $p.ExitCode
  if ($exitCode -ne 0) {
      $message = "Process out message: $stdout`nProcess out error message: $stderr`nExitCode: $exitCode`nFileNeme: $fileName`nArguments: $arg"
      throw $message
  }
}

$sysmon = "Sysmon"
$simplerityMon = "SimplerityMon"
$is64 = [Environment]::Is64BitOperatingSystem
if ($is64) {
  $sysmon = "Sysmon64"
  $simplerityMon = "SimplerityMon64"
}
$service = Get-WmiObject -Class Win32_Service -Filter "Name='$simplerityMon'"
if ($service) {
    Manager-Process-Start -fileName $service.pathname -arg "-u"
}

$service = Get-WmiObject -Class Win32_Service -Filter "Name='$sysmon'"
if ($service) {
    Manager-Process-Start -fileName $service.pathname -arg "-u"
}
$driverPath = "C:\Windows\SysmonDrv.sys"
if (Test-Path $driverPath) {
  $driverRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\SysmonDrv"
  if (Test-Path $driverRegPath) {
      Remove-Item $driverRegPath -Recurse
  }
  Remove-Item $driverPath
}
