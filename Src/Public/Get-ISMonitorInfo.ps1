function Get-ISMonitorInfo {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    PROCESS {
        foreach ($computer in $ComputerName) {
            try {
                $ComputerInfo = Get-CimInstance -ComputerName $computer -ClassName Win32_ComputerSystem -ErrorAction Stop

                Write-Verbose -Message "Retrieved computer data from Win32_ComputerSystem for computer $computer."
                Write-Debug -Message $computer
            } catch {
                Write-Error -Message "Unable to query Win32_ComputerSystem on computer $computer.`n($_.Exception.Message)"
            }

            try {
                $Monitors = Get-CimInstance -ComputerName $computer -ClassName wmiMonitorID -Namespace root\wmi -ErrorAction Stop
                
                foreach ($monitor in $Monitors) {
                    $info = @{
                        ComputerName = $computer
                        ComputerType = $ComputerInfo.Model
                        MonitorType = ''
                        MonitorSerial = [System.Text.Encoding]::ASCII.GetString($monitor.SerialNumberID)
                    }
                    if ($monitor.UserFriendlyName -ne $null) {
                        $info.MonitorType = [System.Text.Encoding]::ASCII.GetString($monitor.UserFriendlyName)
                    }
                
                    $object = New-Object -TypeName PSObject -Property $info
                
                    Write-Output $object

                    Write-Verbose -Message "Retrieved monitor data from wmiMonitorID for computer $computer."
                    Write-Debug -Message $info
                }
            } catch {
                Write-Error "Unable to query wmiMonitorID on computer $computer. $($_.Exception.Message)"
            }
        }
    }
}