$ErrorActionPreference = 'Stop'
$demoRoot = $PSScriptRoot
$apiProcess = $null
$demoExit = 1
$healthUrl = 'http://localhost:59252/api/Quotes/isalive'

function Test-DemoApi {
    try {
        $response = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 2
        return $response.StatusCode -eq 200
    } catch { return $false }
}

Push-Location $demoRoot
try {
    Get-Command dotnet -ErrorAction Stop | Out-Null
    if (Test-DemoApi) {
        Write-Host 'Reusing the API already responding on localhost:59252. It will remain running.'
    } else {
        $logDir = Join-Path $demoRoot 'TestResults\Demo'
        New-Item -ItemType Directory -Force -Path $logDir | Out-Null
        $apiProject = Join-Path $demoRoot 'Quote\Quote.csproj'
        Write-Host 'Starting the API and waiting for its health endpoint...'
        $apiProcess = Start-Process -FilePath 'dotnet' -WorkingDirectory $demoRoot -ArgumentList @(
            'run', '--project', ('"{0}"' -f $apiProject), '--no-launch-profile', '--urls', 'http://localhost:59252'
        ) -RedirectStandardOutput (Join-Path $logDir 'Api.stdout.log') -RedirectStandardError (Join-Path $logDir 'Api.stderr.log') -PassThru
        $deadline = [DateTime]::UtcNow.AddSeconds(120)
        $ready = $false
        while ([DateTime]::UtcNow -lt $deadline) {
            if ($apiProcess.HasExited) { throw "API startup failed. Read the logs in $logDir" }
            if (Test-DemoApi) { $ready = $true; break }
            Start-Sleep -Milliseconds 500
        }
        if (-not $ready) { throw "API was not ready within 120 seconds. Read the logs in $logDir" }
    }

    $reportScript = Join-Path $demoRoot 'RunTestsAndGenerateReport.ps1'
    Unblock-File -LiteralPath $reportScript
    $runStarted = Get-Date
    # A child process keeps the reporting script's exit statement from skipping cleanup.
    & powershell.exe -NoProfile -File $reportScript
    $demoExit = $LASTEXITCODE
    $report = Join-Path $demoRoot 'TestResults\TestReport.html'
    if ((Test-Path $report) -and (Get-Item $report).LastWriteTime -ge $runStarted) {
        Start-Process -FilePath $report
    } else {
        Write-Warning 'No fresh HTML report was generated. Review the errors above.'
        if ($demoExit -eq 0) { $demoExit = 1 }
    }
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    $demoExit = 1
} finally {
    # Only stop the process tree created by this launcher, never a pre-existing API.
    if ($null -ne $apiProcess -and -not $apiProcess.HasExited) {
        & taskkill.exe /PID $apiProcess.Id /T /F | Out-Null
    }
    Pop-Location
}
exit $demoExit
