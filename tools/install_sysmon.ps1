& 'C:\Program Files (x86)\Simplerity\SimplerityMon\SimplerityMon64.exe' -u
$config = 'C:\Program Files (x86)\Simplerity\SimplerityMon\sysconfig.xml'
& 'C:\Program Files (x86)\Simplerity\SimplerityMon\SimplerityMon64.exe' -i $config -accepteula
Restart-Service Winlogbeat
