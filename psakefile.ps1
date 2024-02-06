Task test {
    $configuration = New-PesterConfiguration

    $configuration.Run.Throw = $true
    $configuration.TestResult.Enabled = $true
    $configuration.CodeCoverage.Enabled = $true
    $configuration.CodeCoverage.Path = './Module/'

    Invoke-Pester -Configuration $configuration
}
