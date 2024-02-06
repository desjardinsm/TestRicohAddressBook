Task test {
    Write-Host "psake:" $ErrorActionPreference
    Invoke-Pester
    Write-Host "Finished Invoke-Pester"
}
