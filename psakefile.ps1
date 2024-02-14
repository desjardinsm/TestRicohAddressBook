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

Task TagRelease {
    $module = Test-ModuleManifest -Path (Join-Path 'Module' 'RicohAddressBook.psd1')
    $tagName = "v$($module.Version)"

    if ($PreRelease) {
        $lastRelease = git tag --list "$tagName-pre.*" |
            Where-Object { $_ -match '\.(\d+)$' } |
            ForEach-Object { [uint32] $Matches[1] } |
            Measure-Object -Maximum |
            Select-Object -ExpandProperty Maximum

        $next = [string] ($lastRelease + 1)
        $tagName += "-pre.$next"
    }

    git tag -a $tagName -m $tagName
}

if ($env:CI -eq $true) {
    Task InitializeDeployments {
        if ($env:APPVEYOR -eq $true) {
            if ($env:APPVEYOR_REPO_TAG -eq $true) {
                $env:IS_PRERELEASE = $env:APPVEYOR_REPO_TAG_NAME -like '*-pre.*'
            }

            $env:RELEASE_DESCRIPTION = if ($null -eq $env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED) {
                "Release $env:APPVEYOR_REPO_TAG_NAME"
            } else {
                $env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED
            }
        }
    }

    Task DeployToPowerShellGallery {
        throw 'not implemented'
        if ($env:IS_PRERELEASE -eq $false) {
            Remove-Item -Recurse './Publish/RicohAddressBook/' -ErrorAction Ignore
            Copy-Item -Recurse './Module/' './Publish/RicohAddressBook/'

            Publish-Module -Path './Publish/RicohAddressBook/' -NuGetApiKey $env:NuGetApiKey
        }
    }
}
