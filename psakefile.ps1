Task test {
    $configuration = New-PesterConfiguration
    $configuration.Run.Throw = $true
    Invoke-Pester -Configuration $configuration
}
