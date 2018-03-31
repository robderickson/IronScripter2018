function Get-ISMonitorInfo {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    BEGIN {}

    PROCESS {
        foreach ($computer in $ComputerName) {
            try {
                $ComputerInfo = Get-CimInstance -ComputerName $computer -ClassName Win32_ComputerSystem -ErrorAction Stop
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
                }
            } catch {
                Write-Error "Unable to query WMI class on computer $computer. $($_.Exception.Message)"
                Continue
            }
        }
    }

    END {}
}