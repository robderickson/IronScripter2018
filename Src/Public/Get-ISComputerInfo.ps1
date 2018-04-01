function Get-ISComputerInfo {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    PROCESS {
        Foreach ($computer in $ComputerName) {
            try {
                $OSInfo = Get-CimInstance -ComputerName $computer -ClassName Win32_OperatingSystem -ErrorAction Stop

                Write-Verbose -Message "Retrieved operating system data from Win32_OperatingSystem for computer $computer"
                Write-Debug -Message $computer
            } catch {
                Write-Error -Message "Unable to query Win32_OperatingSystem on computer $computer.`n$($_.Exception.Message)"
            }

            try {
                $DiskInfo = Get-CimInstance -ComputerName $computer -ClassName Win32_LogicalDisk -ErrorAction Stop
                Foreach ($disk in $DiskInfo) {
                    $properties = @{
                        OSName = $OSInfo.Caption
                        OSVersion = $OSInfo.Version
                        ServicePack = "$($OSInfo.ServicePackMajorVersion).$($OSInfo.ServicePackMinorVersion)"
                        Manufacturer = $OSInfo.Manufacturer
                        WindowsDirectory = $OSInfo.WindowsDirectory
                        Locale = $OSInfo.Locale
                        FreePhysicalMemory = $OSInfo.FreePhysicalMemory
                        TotalVirtualMemorySize = $OSInfo.TotalVirtualMemorySize
                        FreeVirtualMemory = $OSInfo.FreeVirtualMemory
                        DeviceID = $disk.DeviceID
                        Description = $disk.Description
                        Size = $disk.Size
                        FreeSpace = $disk.FreeSpace
                        PercentFree = ''
                        Compressed = $disk.Compressed
                    }

                    if ($disk.Size -gt 0) {
                        $properties.PercentFree = "{0:P0}" -f ($disk.FreeSpace / $disk.Size)
                    }

                    Write-Verbose -Message "Retrieved disk data from Win32_LogicalDisk for computer $computer"
                    Write-Debug -Message $properties

                    $object = New-Object -TypeName PSObject -Property $properties
                    $object.PSTypeNames.Insert(0,'Custom.ComputerInfo')

                    Write-Output $object
                }
            } catch {
                Write-Error -Message "Unable to query Win32_LogicalDisk on computer $computer.`n$($_.Exception.Message)"
            }
        }
    }
}