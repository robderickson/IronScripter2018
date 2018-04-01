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
                Get-CimInstance -ComputerName $computer -ClassName Win32_LogicalDisk -ErrorAction Stop |
                ForEach-Object -Process {
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
                        DeviceID = $_.DeviceID
                        Description = $_.Description
                        Size = $_.Size
                        FreeSpace = $_.FreeSpace
                        PercentFree = ''
                        Compressed = $_.Compressed
                        PSTypeName = 'ComputerInfo'
                    }

                    if ($_.Size -gt 0) {
                        $properties.PercentFree = "{0:P0}" -f ($_.FreeSpace / $_.Size)
                    }

                    Write-Verbose -Message "Retrieved disk data from Win32_LogicalDisk for computer $computer"
                    Write-Debug -Message $properties

                    $object = New-Object -TypeName PSObject -Property $properties
                    
                    Write-Output $object
                }
            } catch {
                Write-Error -Message "Unable to query Win32_LogicalDisk on computer $computer.`n$($_.Exception.Message)"
            }
        }
    }
}