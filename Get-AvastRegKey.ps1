<#
  .SYNOPSIS
  R

  .DESCRIPTION
   


  .EXAMPLE


  .OUTPUTS
  

  .NOTES
#>

Set-ExecutionPolicy Bypass

$pcs = Get-ADComputer -Filter * -Properties *               #use for getting computers from AD
$arr01 = @()
$reg = 'SYSTEM\CurrentControlSet\Services\aswVmm\Parameters'
$prop = 'CsrssCompat'
$domain = $(Get-ADDomain).DNSRoot.Split(".")[0]
$report = "$domain" + "_RegKeys.csv" 
$path = "C:\Avast Reports"
$csvPath = "$path\$report"

if(!(Test-Path -Path $path)){New-Item -ItemType Directory -Path $path}
if(Test-Path -Path $csvPath){Remove-Item $csvPath}

foreach($pc in $pcs)
    {
        if(Test-Connection $pc.Name -Count 1 -Quiet)
            { 
                $open = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $pc.Name)
                $regkey = $open.opensubkey($reg) 
                $value = $regkey.getvalue($prop)
                $obj01 = New-Object System.Object
                $obj01 | Add-Member -Type NoteProperty -Name Computer -Value $pc.Name
                $obj01 | Add-Member -Type NoteProperty -Name Value -Value $value
                $obj01 | Add-Member -Type NoteProperty -Name Key -Value 'SYSTEM\CurrentControlSet\Services\aswVmm\Parameters\CsrssCompat'
                $arr01 += $obj01
            }
    
    }

 $arr01 | Export-Csv $csvPath -NoTypeInformation