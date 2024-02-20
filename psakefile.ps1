Task Test {
    $configuration = New-PesterConfiguration

    $configuration.Output.Verbosity = if ($Detailed) {
        'Detailed'
    } else {
        'Normal'
    }

    if ('True' -ieq $env:CI) {
        $configuration.Run.Exit = $true
        $Results = $true
    }

    if ($Results) {
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

    Write-Host "git tag -a $tagName -m $tagName"
    git tag -a $tagName -m $tagName
}

if ('True' -ieq $env:CI) {
    Task InitializeDeployments {
        if ('True' -ieq $env:APPVEYOR) {
            if ('True' -ieq $env:APPVEYOR_REPO_TAG) {
                $env:IS_PRERELEASE = $env:APPVEYOR_REPO_TAG_NAME -like '*-pre.*'
                Write-Host ('$env:IS_PRERELEASE = "{0}"' -f $env:IS_PRERELEASE)
            }

            $env:RELEASE_DESCRIPTION = if ($null -eq $env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED) {
                "Release $env:APPVEYOR_REPO_TAG_NAME"
            } else {
                $env:APPVEYOR_REPO_COMMIT_MESSAGE_EXTENDED
            }
            Write-Host ('$env:RELEASE_DESCRIPTION = "{0}"' -f $env:RELEASE_DESCRIPTION)
        }
    }

    Task DeployToPowerShellGallery -precondition { 'False' -ieq $env:IS_PRERELEASE } {
        Remove-Item -Recurse './Publish/TestRicohAddressBook/' -ErrorAction Ignore
        Copy-Item -Recurse './Module/' './Publish/TestRicohAddressBook/'

        Publish-Module -Path './Publish/TestRicohAddressBook/' -NuGetApiKey $env:NuGetApiKey
    }

    Task UploadTestResults {
        if ('True' -ieq $env:APPVEYOR) {
            # Upload test results to AppVeyor
            $client = [System.Net.WebClient]::new()
            $results = Resolve-Path (Join-Path 'TestResults' 'testResults.xml')
            $client.UploadFile("$env:APPVEYOR_URL/api/testresults/nunit3/$env:APPVEYOR_JOB_ID", $results)
        }
    }

    TaskTearDown {
        param($task)

        if (-not $task.Success) {
            Write-Host "Task $($task.Name) failed:" $task.ErrorMessage
            exit 1
        }
    }
}
