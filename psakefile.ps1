Task test {
    $configuration = New-PesterConfiguration
    $configuration.Run.Throw = $true
    $configuration.TestResult.Enabled = $true
    $configuration.TestResult.OutputFormat = 'NUnit3'
    $configuration.TestResult.OutputPath = 'results.nunit3.xml'
    Invoke-Pester -Configuration $configuration
}
