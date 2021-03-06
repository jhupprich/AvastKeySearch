<#
  .SYNOPSIS
    Queries computers found in Active Directory for a registry key from Avast. 
    This script will create a folder named 'Avast Reports' on the C: drive and generate a report there

  .DESCRIPTION
   Run from either a domain controller or a server with the AD DS RSAT tools installed
   Run this script as admin as it performs an execution policy bypass

  .EXAMPLE
    .\Get-AvastRegKeys.ps1

  .OUTPUTS
  C:\Avast Reports\localdomain_RegKeys.csv
  

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
                $open = $NULL
                $open = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $pc.Name)
                $pc.Name

                if(!$open)
                    {
                        $obj01 = New-Object System.Object
                        $obj01 | Add-Member -Type NoteProperty -Name Computer -Value $pc.Name
                        $obj01 | Add-Member -Type NoteProperty -Name Value -Value 'N/A'
                        $obj01 | Add-Member -Type NoteProperty -Name Key -Value 'Registry access denied'
                        $arr01 += $obj01
                        Write-Host -ForegroundColor Yellow $pc.Name 'Cannot connect!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
                    }

                else 
                {
                    $regkey = $NULL
                    $regkey = $open.opensubkey($reg) 

                    if(!$regkey)
                        {
                            $obj01 = New-Object System.Object
                            $obj01 | Add-Member -Type NoteProperty -Name Computer -Value $pc.Name
                            $obj01 | Add-Member -Type NoteProperty -Name Value -Value 'NONE'
                            $obj01 | Add-Member -Type NoteProperty -Name Key -Value 'Key not found'
                            $arr01 += $obj01
                            Write-Host -ForegroundColor Green $pc.Name 'NO KEY FOUND!!!!!!!!!!!!!!!!!!!!!!!!!!!'
                        }

                    $value = $regkey.getvalue($prop)
                    $obj01 = New-Object System.Object
                    $obj01 | Add-Member -Type NoteProperty -Name Computer -Value $pc.Name
                    $obj01 | Add-Member -Type NoteProperty -Name Value -Value $value
                    $obj01 | Add-Member -Type NoteProperty -Name Key -Value 'SYSTEM\CurrentControlSet\Services\aswVmm\Parameters\CsrssCompat'
                    $arr01 += $obj01
                }

            }
    
    }

 $arr01 | Export-Csv $csvPath -NoTypeInformation