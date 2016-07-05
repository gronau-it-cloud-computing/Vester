#requires -Modules Pester
#requires -Modules VMware.VimAutomation.Core

# Variables
Invoke-Expression -Command (Get-Item -Path ($PSScriptRoot + '\Config.ps1'))
[int]$snapretention = $global:config.host.snapretention
[bool]$fix = $global:config.pester.remediate

# Tests
Describe -Name 'VM Configuration: Snaphot(s)' -Fixture {
    foreach ($VM in (Get-VM)) 
    {
        It -name "$($VM.name) has no snaphsot older than $snapretention day(s)" -test {
            [array]$value = $VM | Get-Snapshot | Where {$_.Created -lt (Get-Date).AddDays(-$snapretention)}
            try 
            {
                $value | Should BeNullOrEmpty
            }
            catch 
            {
                if ($fix) 
                {
                    Write-Warning -Message $_
                    Write-Warning -Message "Remediating $VM"
                    Remove-Snapshot -Snapshot $value -ErrorAction Stop -Confirm:$false
                }
                else 
                {
                    throw $_
                }
            }
        }
    }
}
