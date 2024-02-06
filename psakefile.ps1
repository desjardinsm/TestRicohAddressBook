Task test {
    $configuration = New-PesterConfiguration

    $resultsDirectory = 'TestResults'

    $configuration.Run.Throw = $true

    if ('True' -eq $env:CI -or $Results) {
        $resultsDirectory = 'TestResults'

        $configuration.TestResult.Enabled = $true
        $configuration.TestResult.OutputFormat = 'NUnit3'
        $configuration.TestResult.OutputPath = Join-Path $resultsDirectory 'testResults.xml'

        $configuration.CodeCoverage.Enabled = $true
        $configuration.CodeCoverage.Path = './Module/'
        $configuration.CodeCoverage.OutputPath = Join-Path $resultsDirectory 'coverage.xml'
    }

    Invoke-Pester -Configuration $configuration
}
