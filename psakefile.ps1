Task test {
    $configuration = New-PesterConfiguration

    $resultsDirectory = 'TestResults'

    $configuration.Run.Throw = $true
    $configuration.TestResult.Enabled = $true
    $configuration.TestResult.OutputPath = Join-Path $resultsDirectory 'testResults.xml'
    $configuration.CodeCoverage.Enabled = $true
    $configuration.CodeCoverage.Path = './Module/'
    $configuration.CodeCoverage.OutputPath = Join-Path $resultsDirectory 'coverage.xml'

    Invoke-Pester -Configuration $configuration
}
