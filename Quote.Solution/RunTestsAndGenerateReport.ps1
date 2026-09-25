$ErrorActionPreference = "Stop"

# ============================================================
# CONFIGURATION
# ============================================================

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

$TestProject = Join-Path $Root "QuoteAcceptanceTests\QuoteAcceptanceTests.csproj"

$ResultsDir = Join-Path $Root "TestResults"
$RunsDir = Join-Path $ResultsDir "Runs"
$FailureDir = Join-Path $ResultsDir "FailureEvidence"

$HistoryPath = Join-Path $ResultsDir "History.csv"
$MetricsPath = Join-Path $ResultsDir "Metrics.json"
$StatePath = Join-Path $ResultsDir "FindingsState.json"

$TestReportPath = Join-Path $ResultsDir "TestReport.html"
$FailureReportPath = Join-Path $FailureDir "FailureReport.html"

$RunId = Get-Date -Format "yyyyMMdd-HHmmss"
$Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"

$RunDir = Join-Path $RunsDir $RunId
$TrxPath = Join-Path $RunDir "TestResults.trx"
$ConsoleLogPath = Join-Path $RunDir "ConsoleOutput.log"


# ============================================================
# KNOWN FINDINGS
#
# IMPORTANT:
# This catalogue does NOT determine which tests fail.
# All tests run first. Classification happens only after the
# actual TRX results are available.
# ============================================================

$KnownFindings = @(

    [pscustomobject]@{
        Id = "F01"
        Pattern = "Reject quote with empty item name"
        Title = "Empty item name returns HTTP 200"
        Category = "API Contract / Error Handling"
        Severity = "Medium"
        RequirementStatus = "Strong inconsistency"
        Expected = "HTTP 400 Bad Request"
    },

    [pscustomobject]@{
        Id = "F02"
        Pattern = "Reject quote with negative item quantity"
        Title = "Negative quantity is accepted"
        Category = "Business Validation / Data Integrity"
        Severity = "High"
        RequirementStatus = "Expected validation"
        Expected = "HTTP 400 Bad Request"
    },

    [pscustomobject]@{
        Id = "F03"
        Pattern = "Reject quote with negative unitary price"
        Title = "Negative unitary price is accepted"
        Category = "Financial Validation / Data Integrity"
        Severity = "High"
        RequirementStatus = "Expected validation"
        Expected = "HTTP 400 Bad Request"
    },

    [pscustomobject]@{
        Id = "F04"
        Pattern = "Reject quote with discount greater than 100 percent"
        Title = "Discount greater than 100% is accepted"
        Category = "Financial Validation / Business Logic"
        Severity = "High"
        RequirementStatus = "Expected validation"
        Expected = "HTTP 400 Bad Request"
    },

    [pscustomobject]@{
        Id = "F05"
        Pattern = "Reject quote with zero item quantity"
        Title = "Zero quantity is accepted"
        Category = "Business Validation"
        Severity = "Medium"
        RequirementStatus = "Needs clarification"
        Expected = "HTTP 400 Bad Request"
    },

    [pscustomobject]@{
        Id = "F06"
        Pattern = "Reject quote with negative discount"
        Title = "Negative discount is accepted"
        Category = "Financial Validation / Business Logic"
        Severity = "High"
        RequirementStatus = "Expected validation"
        Expected = "HTTP 400 Bad Request"
    }
)


# ============================================================
# HELPERS
# ============================================================

function Normalize-TestName {
    param([string]$Name)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        return ""
    }

    return (($Name -replace "[^A-Za-z0-9]", "")).ToLowerInvariant()
}


function Get-FindingForTestName {
    param([string]$TestName)

    $NormalizedTestName = Normalize-TestName $TestName

    foreach ($Finding in $KnownFindings) {
        $NormalizedPattern = Normalize-TestName $Finding.Pattern

        if ($NormalizedTestName.Contains($NormalizedPattern)) {
            return $Finding
        }
    }

    return $null
}


function HtmlEncode {
    param($Value)

    if ($null -eq $Value) {
        return ""
    }

    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}


function Get-OutcomeCssClass {
    param([string]$Outcome)

    switch ($Outcome) {
        "Passed" { return "passed" }
        "Failed" { return "failed" }
        default  { return "other" }
    }
}


function Get-FriendlyTestName {
    param([string]$TestName)

    if ([string]::IsNullOrWhiteSpace($TestName)) {
        return ""
    }

    # Order matters: more specific names must come before shorter prefixes.
    $Mappings = @(

        [pscustomobject]@{
            Technical = "SuccessfullyCreateANewQuoteWithOneItemWithDiscount"
            Friendly = "Successfully create a new quote with one item with discount"
        },

        [pscustomobject]@{
            Technical = "SuccessfullyCreateANewQuoteWithOneItem"
            Friendly = "Successfully create a new quote with one item"
        },

        [pscustomobject]@{
            Technical = "SuccessfullyCreateANewQuoteWithTwoItems"
            Friendly = "Successfully create a new quote with two items"
        },

        [pscustomobject]@{
            Technical = "SuccessfullyCreateAQuoteWithMultipleItemsIncludingDiscount"
            Friendly = "Successfully create a quote with multiple items including discount"
        },

        [pscustomobject]@{
            Technical = "RejectQuoteWithEmptyCustomer"
            Friendly = "Reject quote with empty customer"
        },

        [pscustomobject]@{
            Technical = "RejectQuoteWithNoItems"
            Friendly = "Reject quote with no items"
        },

        [pscustomobject]@{
            Technical = "RejectQuoteWithEmptyItemName"
            Friendly = "Reject quote with empty item name"
        },

        [pscustomobject]@{
            Technical = "RejectQuoteWithNegativeItemQuantity"
            Friendly = "Reject quote with negative item quantity"
        },

        [pscustomobject]@{
            Technical = "RejectQuoteWithNegativeUnitaryPrice"
            Friendly = "Reject quote with negative unitary price"
        },

        [pscustomobject]@{
            Technical = "RejectQuoteWithDiscountGreaterThan100Percent"
            Friendly = "Reject quote with discount greater than 100 percent"
        },

        [pscustomobject]@{
            Technical = "SuccessfullyCreateAQuoteWith100PercentDiscount"
            Friendly = "Successfully create a quote with 100 percent discount"
        },

        [pscustomobject]@{
            Technical = "RejectQuoteWithZeroItemQuantity"
            Friendly = "Reject quote with zero item quantity"
        },

        [pscustomobject]@{
            Technical = "RejectQuoteWithNegativeDiscount"
            Friendly = "Reject quote with negative discount"
        },

        [pscustomobject]@{
            Technical = "RejectMalformedJSONWithoutExposingInternalServerDetails"
            Friendly = "Reject malformed JSON without exposing internal server details"
        },

        [pscustomobject]@{
            Technical = "CreateAQuoteWith100ItemsWithinAnAcceptableResponseTime"
            Friendly = "Create a quote with 100 items within an acceptable response time"
        },

        [pscustomobject]@{
            Technical = "AbleToAccessIsAlivePageWhileTheServiceIsRunning"
            Friendly = "Able to access isAlive page while the service is running"
        }
    )

    foreach ($Mapping in $Mappings) {

        if ($TestName.StartsWith($Mapping.Technical)) {

            $Suffix =
                $TestName.Substring(
                    $Mapping.Technical.Length
                ).Trim()

            if (-not [string]::IsNullOrWhiteSpace($Suffix)) {

                # Keep Scenario Outline example values, but format them
                # for human-readable HTML instead of Reqnroll method style.
                $Suffix =
                    $Suffix -replace ",\s*", ", "

                $Suffix =
                    $Suffix -replace ",\s*\)", ")"

                return "$($Mapping.Friendly) $Suffix"
            }

            return $Mapping.Friendly
        }
    }

    # Safe fallback: if a future scenario is not mapped,
    # preserve the original TRX name instead of hiding it.
    return $TestName
}


# ============================================================
# PRE-FLIGHT
# ============================================================

Write-Host ""
Write-Host "========================================="
Write-Host " QA AUTOMATED TEST EXECUTION"
Write-Host "========================================="
Write-Host ""

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: dotnet was not found." -ForegroundColor Red
    exit 2
}

if (-not (Test-Path $TestProject)) {
    Write-Host "ERROR: Test project was not found:" -ForegroundColor Red
    Write-Host $TestProject
    exit 2
}


# ============================================================
# API HEALTH CHECK
# ============================================================

Write-Host "Checking API availability..."

try {
    $HealthResponse = Invoke-WebRequest `
        -Uri "http://localhost:59252/api/Quotes/isalive" `
        -Method GET `
        -UseBasicParsing `
        -TimeoutSec 3

    if ($HealthResponse.StatusCode -lt 200 -or $HealthResponse.StatusCode -ge 300) {
        throw "API health check did not return success."
    }

    Write-Host "API is running." -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "ERROR: The Quote API is not running." -ForegroundColor Red
    Write-Host ""
    Write-Host "Start the API before executing this script:"
    Write-Host 'dotnet run --project .\Quote\Quote.csproj --urls "http://localhost:59252"'
    Write-Host ""
    exit 2
}


# ============================================================
# CREATE DIRECTORIES
# ============================================================

New-Item -ItemType Directory -Force -Path $ResultsDir | Out-Null
New-Item -ItemType Directory -Force -Path $RunsDir | Out-Null
New-Item -ItemType Directory -Force -Path $RunDir | Out-Null
New-Item -ItemType Directory -Force -Path $FailureDir | Out-Null

# Clean only the latest highlighted failure evidence.
Get-ChildItem -Path $FailureDir -File -ErrorAction SilentlyContinue | Remove-Item -Force


# ============================================================
# RUN TESTS
# ============================================================

Write-Host ""
Write-Host "Running automated tests..."
Write-Host ""

Push-Location $Root

try {
    & dotnet test `
        $TestProject `
        --results-directory $RunDir `
        --logger "trx;LogFileName=TestResults.trx" `
        2>&1 |
        Tee-Object -FilePath $ConsoleLogPath

    $DotnetExitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

if (-not (Test-Path $TrxPath)) {
    Write-Host ""
    Write-Host "ERROR: TRX report was not generated." -ForegroundColor Red
    exit 3
}


# ============================================================
# READ TRX
# ============================================================

[xml]$Trx = Get-Content -Path $TrxPath -Raw

$NamespaceManager = New-Object System.Xml.XmlNamespaceManager($Trx.NameTable)
$NamespaceManager.AddNamespace("t", $Trx.DocumentElement.NamespaceURI)

$ResultNodes = @(
    $Trx.SelectNodes("//t:UnitTestResult", $NamespaceManager)
)

$ResultRows = @()

foreach ($Node in $ResultNodes) {

    $TestName = $Node.GetAttribute("testName")
    $Outcome = $Node.GetAttribute("outcome")
    $DurationText = $Node.GetAttribute("duration")

    $DurationMs = 0

    if (-not [string]::IsNullOrWhiteSpace($DurationText)) {
        try {
            $DurationMs = [Math]::Round(
                ([TimeSpan]::Parse($DurationText)).TotalMilliseconds,
                2
            )
        }
        catch {
            $DurationMs = 0
        }
    }

    $MessageNode = $Node.SelectSingleNode(
        "t:Output/t:ErrorInfo/t:Message",
        $NamespaceManager
    )

    $StackNode = $Node.SelectSingleNode(
        "t:Output/t:ErrorInfo/t:StackTrace",
        $NamespaceManager
    )

    $StdOutNode = $Node.SelectSingleNode(
        "t:Output/t:StdOut",
        $NamespaceManager
    )

    $ErrorMessage = if ($MessageNode) { $MessageNode.InnerText } else { "" }
    $StackTrace = if ($StackNode) { $StackNode.InnerText } else { "" }
    $StdOut = if ($StdOutNode) { $StdOutNode.InnerText } else { "" }

    # Classification happens AFTER the real test result exists.
    $Finding = Get-FindingForTestName $TestName

    $FindingId = $null
    $FindingTitle = $null
    $FindingScenario = $null
    $Category = $null
    $Severity = $null
    $RequirementStatus = $null
    $Expected = $null

    if ($Finding) {
        $FindingId = $Finding.Id
        $FindingTitle = $Finding.Title
        $FindingScenario = $Finding.Pattern
        $Category = $Finding.Category
        $Severity = $Finding.Severity
        $RequirementStatus = $Finding.RequirementStatus
        $Expected = $Finding.Expected
    }
    elseif ($Outcome -eq "Failed") {
        # Do not invent a severity for an uninvestigated failure.
        $Category = "Needs triage"
        $Severity = "Unclassified"
        $RequirementStatus = "Needs investigation"
        $Expected = "Not classified yet"
    }

    $ResultRows += [pscustomobject]@{
        TestName = $TestName
        DisplayName = Get-FriendlyTestName $TestName
        NormalizedName = Normalize-TestName $TestName
        Outcome = $Outcome
        DurationMs = $DurationMs
        ErrorMessage = $ErrorMessage
        StackTrace = $StackTrace
        StdOut = $StdOut
        FindingId = $FindingId
        FindingTitle = $FindingTitle
        FindingScenario = $FindingScenario
        Category = $Category
        Severity = $Severity
        RequirementStatus = $RequirementStatus
        Expected = $Expected
    }
}


# ============================================================
# EXECUTION METRICS
# ============================================================

$Total = $ResultRows.Count

$Passed = @(
    $ResultRows | Where-Object { $_.Outcome -eq "Passed" }
).Count

$Failed = @(
    $ResultRows | Where-Object { $_.Outcome -eq "Failed" }
).Count

$Skipped = $Total - $Passed - $Failed

if ($Skipped -lt 0) {
    $Skipped = 0
}

$KnownFindingFailures = @(
    $ResultRows | Where-Object {
        $_.Outcome -eq "Failed" -and
        -not [string]::IsNullOrWhiteSpace($_.FindingId)
    }
)

$UnexpectedFailures = @(
    $ResultRows | Where-Object {
        $_.Outcome -eq "Failed" -and
        [string]::IsNullOrWhiteSpace($_.FindingId)
    }
)

$TotalDurationMs = [Math]::Round(
    (
        $ResultRows |
        Measure-Object -Property DurationMs -Sum
    ).Sum,
    2
)


# ============================================================
# PERFORMANCE
#
# CreateQuoteSteps.cs writes:
#
# PERFORMANCE_API_RESPONSE_MS=<value>
# PERFORMANCE_THRESHOLD_MS=<value>
# ============================================================

$PerformancePattern = Normalize-TestName `
    "Create a quote with 100 items within an acceptable response time"

$PerformanceResult = $ResultRows |
    Where-Object {
        $_.NormalizedName.Contains($PerformancePattern)
    } |
    Select-Object -First 1

$PerformanceOutcome = $null
$PerformanceTestDurationMs = $null
$PerformanceApiResponseMs = $null
$PerformanceThresholdMs = $null

if ($PerformanceResult) {

    $PerformanceOutcome = $PerformanceResult.Outcome
    $PerformanceTestDurationMs = $PerformanceResult.DurationMs

    if (-not [string]::IsNullOrWhiteSpace($PerformanceResult.StdOut)) {

        $ApiTimeMatch = [regex]::Match(
            $PerformanceResult.StdOut,
            "PERFORMANCE_API_RESPONSE_MS=(\d+)"
        )

        if ($ApiTimeMatch.Success) {
            $PerformanceApiResponseMs =
                [long]$ApiTimeMatch.Groups[1].Value
        }

        $ThresholdMatch = [regex]::Match(
            $PerformanceResult.StdOut,
            "PERFORMANCE_THRESHOLD_MS=(\d+)"
        )

        if ($ThresholdMatch.Success) {
            $PerformanceThresholdMs =
                [long]$ThresholdMatch.Groups[1].Value
        }
    }
}


# ============================================================
# FINDING HISTORY
# ============================================================

$ExistingState = $null

if (Test-Path $StatePath) {
    try {
        $ExistingState =
            Get-Content -Path $StatePath -Raw |
            ConvertFrom-Json
    }
    catch {
        $ExistingState = $null
    }
}

$PreviousRunCount = 0

if (
    $ExistingState -and
    $ExistingState.PSObject.Properties.Name -contains "totalRuns"
) {
    $PreviousRunCount = [int]$ExistingState.totalRuns
}

$TotalRuns = $PreviousRunCount + 1
$NewFindingState = @()

foreach ($KnownFinding in $KnownFindings) {

    $ExistingFinding = $null

    if ($ExistingState) {
        $ExistingFinding =
            $ExistingState.findings |
            Where-Object { $_.id -eq $KnownFinding.Id } |
            Select-Object -First 1
    }

    $Occurrences = 0
    $FirstSeen = ""
    $LastSeen = ""

    if ($ExistingFinding) {
        $Occurrences = [int]$ExistingFinding.occurrences
        $FirstSeen = [string]$ExistingFinding.firstSeen
        $LastSeen = [string]$ExistingFinding.lastSeen
    }

    $MatchingResults = @(
        $ResultRows |
        Where-Object { $_.FindingId -eq $KnownFinding.Id }
    )

    $FailedNow = @(
        $MatchingResults |
        Where-Object { $_.Outcome -eq "Failed" }
    ).Count -gt 0

    $PassedNow = @(
        $MatchingResults |
        Where-Object { $_.Outcome -eq "Passed" }
    ).Count -gt 0

    $Status = "Not executed"
    $LatestOutcome = "Not executed"

    if ($FailedNow) {

        $Occurrences++

        if ([string]::IsNullOrWhiteSpace($FirstSeen)) {
            $FirstSeen = $Timestamp
        }

        $LastSeen = $Timestamp
        $Status = "Reproduced"
        $LatestOutcome = "Failed"
    }
    elseif ($PassedNow) {

        $LatestOutcome = "Passed"

        if ($Occurrences -gt 0) {
            $Status = "Not reproduced in latest run"
        }
        else {
            $Status = "Not observed"
        }
    }

    $NewFindingState += [pscustomobject]@{
        id = $KnownFinding.Id
        title = $KnownFinding.Title
        scenario = $KnownFinding.Pattern
        category = $KnownFinding.Category
        severity = $KnownFinding.Severity
        requirementStatus = $KnownFinding.RequirementStatus
        status = $Status
        latestOutcome = $LatestOutcome
        occurrences = $Occurrences
        firstSeen = $FirstSeen
        lastSeen = $LastSeen
    }
}

$StateObject = [pscustomobject]@{
    version = 1
    totalRuns = $TotalRuns
    updatedAt = $Timestamp
    findings = $NewFindingState
}

$StateObject |
    ConvertTo-Json -Depth 8 |
    Set-Content -Path $StatePath -Encoding UTF8


# ============================================================
# CUMULATIVE METRICS
# ============================================================

$UniqueFindingsSeen = @(
    $NewFindingState |
    Where-Object { $_.occurrences -gt 0 }
).Count

$ActiveFindings = @(
    $NewFindingState |
    Where-Object { $_.status -eq "Reproduced" }
).Count

$HighActive = @(
    $NewFindingState |
    Where-Object {
        $_.status -eq "Reproduced" -and
        $_.severity -eq "High"
    }
).Count

$MediumActive = @(
    $NewFindingState |
    Where-Object {
        $_.status -eq "Reproduced" -and
        $_.severity -eq "Medium"
    }
).Count


# ============================================================
# METRICS.JSON
# ============================================================

$Metrics = [pscustomobject]@{

    generatedAt = $Timestamp
    runId = $RunId

    execution = [pscustomobject]@{
        total = $Total
        passed = $Passed
        failed = $Failed
        skipped = $Skipped
        durationMs = $TotalDurationMs
        dotnetExitCode = $DotnetExitCode
    }

    failureClassification = [pscustomobject]@{
        knownFindingFailures = $KnownFindingFailures.Count
        unexpectedFailures = $UnexpectedFailures.Count
    }

    cumulative = [pscustomobject]@{
        totalRuns = $TotalRuns
        uniqueFindingsSeen = $UniqueFindingsSeen
        activeFindings = $ActiveFindings
        highSeverityActive = $HighActive
        mediumSeverityActive = $MediumActive
    }

    performance = [pscustomobject]@{
        scenarioOutcome = $PerformanceOutcome
        apiResponseMs = $PerformanceApiResponseMs
        thresholdMs = $PerformanceThresholdMs
        testDurationMs = $PerformanceTestDurationMs
    }

    findings = $NewFindingState
}

$Metrics |
    ConvertTo-Json -Depth 10 |
    Set-Content -Path $MetricsPath -Encoding UTF8


# ============================================================
# HISTORY.CSV
# ============================================================

$HistoryRow = [pscustomobject][ordered]@{
    timestamp = $Timestamp
    runId = $RunId
    total = $Total
    passed = $Passed
    failed = $Failed
    skipped = $Skipped
    knownFindingFailures = $KnownFindingFailures.Count
    unexpectedFailures = $UnexpectedFailures.Count
    uniqueFindingsSeen = $UniqueFindingsSeen
    activeFindings = $ActiveFindings
    highSeverityActive = $HighActive
    mediumSeverityActive = $MediumActive
    durationMs = $TotalDurationMs
    performanceOutcome = $PerformanceOutcome
    performanceApiResponseMs = $PerformanceApiResponseMs
    performanceThresholdMs = $PerformanceThresholdMs
    performanceTestDurationMs = $PerformanceTestDurationMs
}

if (Test-Path $HistoryPath) {
    $HistoryRow |
        Export-Csv `
            -Path $HistoryPath `
            -NoTypeInformation `
            -Encoding UTF8 `
            -Append
}
else {
    $HistoryRow |
        Export-Csv `
            -Path $HistoryPath `
            -NoTypeInformation `
            -Encoding UTF8
}


# ============================================================
# RAW FAILURE EVIDENCE
# ============================================================

$EvidenceLookup = @{}
$UnexpectedCounter = 0

foreach (
    $Failure in @(
        $ResultRows |
        Where-Object { $_.Outcome -eq "Failed" }
    )
) {

    if (-not [string]::IsNullOrWhiteSpace($Failure.FindingId)) {
        $EvidenceId = $Failure.FindingId
    }
    else {
        $UnexpectedCounter++
        $EvidenceId = "UNEXPECTED-{0:D2}" -f $UnexpectedCounter
    }

    $SafeTestName =
        $Failure.TestName -replace "[^A-Za-z0-9\-]", "-"

    if ($SafeTestName.Length -gt 70) {
        $SafeTestName = $SafeTestName.Substring(0, 70)
    }

    $EvidenceFileName =
        "$EvidenceId-$SafeTestName.txt"

    $EvidencePath =
        Join-Path $FailureDir $EvidenceFileName

    $EvidenceContent = @"
QA FAILURE EVIDENCE

Run ID:
$RunId

Timestamp:
$Timestamp

Evidence ID:
$EvidenceId

Finding:
$($Failure.FindingTitle)

Automated Scenario:
$($Failure.FindingScenario)

Test Result Name:
$($Failure.TestName)

Outcome:
$($Failure.Outcome)

Category:
$($Failure.Category)

Severity:
$($Failure.Severity)

Requirement Status:
$($Failure.RequirementStatus)

Expected:
$($Failure.Expected)

Failure Message:
$($Failure.ErrorMessage)

Stack Trace:
$($Failure.StackTrace)
"@

    Set-Content `
        -Path $EvidencePath `
        -Value $EvidenceContent `
        -Encoding UTF8

    $EvidenceLookup[$Failure.TestName] =
        $EvidenceFileName
}


# ============================================================
# GENERAL TEST TABLE
# ============================================================

$AllRowsHtml = ""

foreach (
    $Row in $ResultRows |
    Sort-Object TestName
) {

    $OutcomeClass =
        Get-OutcomeCssClass $Row.Outcome

    $Classification =
        "Normal execution"

    if (
        $Row.Outcome -eq "Failed" -and
        -not [string]::IsNullOrWhiteSpace($Row.FindingId)
    ) {
        $Classification =
            "Known finding $($Row.FindingId)"
    }
    elseif ($Row.Outcome -eq "Failed") {
        $Classification =
            "Unexpected Failure - Needs Triage"
    }

    $AllRowsHtml += @"
<tr>
    <td>
        <span class="$OutcomeClass">
            $(HtmlEncode $Row.Outcome)
        </span>
    </td>
    <td>$(HtmlEncode $Row.DisplayName)</td>
    <td>$(HtmlEncode $Row.DurationMs) ms</td>
    <td>$(HtmlEncode $Classification)</td>
</tr>
"@
}


# ============================================================
# FINDING STATUS TABLE
# ============================================================

$FindingRowsHtml = ""

foreach ($Finding in $NewFindingState) {

    $StatusClass = "other"

    if ($Finding.status -eq "Reproduced") {
        $StatusClass = "failed"
    }
    elseif (
        $Finding.status -eq
        "Not reproduced in latest run"
    ) {
        $StatusClass = "passed"
    }

    $FindingRowsHtml += @"
<tr>
    <td>$(HtmlEncode $Finding.id)</td>
    <td>$(HtmlEncode $Finding.title)</td>
    <td>$(HtmlEncode $Finding.severity)</td>
    <td>$(HtmlEncode $Finding.category)</td>
    <td>
        <span class="$StatusClass">
            $(HtmlEncode $Finding.status)
        </span>
    </td>
    <td>$(HtmlEncode $Finding.occurrences)</td>
    <td>$(HtmlEncode $Finding.firstSeen)</td>
    <td>$(HtmlEncode $Finding.lastSeen)</td>
</tr>
"@
}


# ============================================================
# PERFORMANCE CARD
# ============================================================

$PerformanceHtml = ""

if ($PerformanceResult) {

    $ApiTimeDisplay = "Not captured"
    $ThresholdDisplay = "Not captured"

    if ($null -ne $PerformanceApiResponseMs) {
        $ApiTimeDisplay =
            "$PerformanceApiResponseMs ms"
    }

    if ($null -ne $PerformanceThresholdMs) {
        $ThresholdDisplay =
            "< $PerformanceThresholdMs ms"
    }

    $PerformanceHtml = @"
<div class="metric performance-card">

    <h3>Performance Scenario</h3>

    <strong class="$(Get-OutcomeCssClass $PerformanceOutcome)">
        $(HtmlEncode $PerformanceOutcome)
    </strong>

    <div>
        API response time:
        <b>$(HtmlEncode $ApiTimeDisplay)</b>
    </div>

    <div>
        Threshold:
        <b>$(HtmlEncode $ThresholdDisplay)</b>
    </div>

    <small>
        Measured around the HTTP request using Stopwatch.
    </small>

</div>
"@
}


# ============================================================
# GENERAL HTML REPORT
# ============================================================

$TestReportHtml = @"
<!DOCTYPE html>
<html>

<head>
<meta charset="utf-8">
<title>QA Test Report</title>

<style>
body {
    font-family: Arial, Helvetica, sans-serif;
    margin: 40px;
    background: #f6f7f9;
    color: #222;
}

h1, h2, h3 {
    margin-bottom: 10px;
}

.summary {
    display: flex;
    flex-wrap: wrap;
    gap: 14px;
    margin: 25px 0;
}

.metric {
    background: white;
    padding: 18px;
    border-radius: 8px;
    min-width: 150px;
    box-shadow: 0 1px 4px rgba(0,0,0,.12);
}

.metric strong {
    display: block;
    font-size: 28px;
    margin-bottom: 5px;
}

.performance-card strong {
    font-size: 20px;
}

.passed {
    color: #167c3a;
    font-weight: bold;
}

.failed {
    color: #b42318;
    font-weight: bold;
}

.other {
    color: #7a5b00;
    font-weight: bold;
}

table {
    width: 100%;
    border-collapse: collapse;
    background: white;
    margin-bottom: 35px;
}

th {
    background: #222;
    color: white;
    text-align: left;
    padding: 10px;
}

td {
    border-bottom: 1px solid #ddd;
    padding: 10px;
    vertical-align: top;
}

.notice {
    padding: 16px;
    background: #fff4ce;
    border-left: 5px solid #d89b00;
    margin: 20px 0;
}

a {
    color: #005fb8;
}

small {
    color: #666;
}

code {
    background: #ececec;
    padding: 2px 5px;
    border-radius: 4px;
}
</style>

</head>

<body>

<h1>QA Automated Test Report</h1>

<p>
Run ID:
<strong>$(HtmlEncode $RunId)</strong>
<br>
Generated at:
$(HtmlEncode $Timestamp)
</p>

<div class="summary">

<div class="metric">
    <strong>$Total</strong>
    Total Tests
</div>

<div class="metric">
    <strong class="passed">$Passed</strong>
    Passed
</div>

<div class="metric">
    <strong class="failed">$Failed</strong>
    Failed
</div>

<div class="metric">
    <strong>$Skipped</strong>
    Skipped
</div>

<div class="metric">
    <strong>$($KnownFindingFailures.Count)</strong>
    Known Findings Reproduced
</div>

<div class="metric">
    <strong class="failed">$($UnexpectedFailures.Count)</strong>
    Unexpected Failures
</div>

<div class="metric">
    <strong>$UniqueFindingsSeen</strong>
    Unique Findings Seen
</div>

<div class="metric">
    <strong>$TotalRuns</strong>
    Recorded Runs
</div>

$PerformanceHtml

</div>

<div class="notice">
<strong>Important:</strong>
Known finding failures represent behaviors already investigated and
documented in <code>TEST_FINDINGS.md</code>.
A finding is classified as reproduced only after the automated test
actually fails. Repeated executions do not create duplicate defects.
The same finding keeps its unique ID while its occurrence count and
last-seen timestamp are updated.
</div>

<h2>Current Finding Status</h2>

<table>
<thead>
<tr>
    <th>ID</th>
    <th>Finding</th>
    <th>Severity</th>
    <th>Category</th>
    <th>Status</th>
    <th>Occurrences</th>
    <th>First Seen</th>
    <th>Last Seen</th>
</tr>
</thead>

<tbody>
$FindingRowsHtml
</tbody>
</table>

<h2>Test Execution</h2>

<table>
<thead>
<tr>
    <th>Outcome</th>
    <th>Scenario</th>
    <th>Duration</th>
    <th>Classification</th>
</tr>
</thead>

<tbody>
$AllRowsHtml
</tbody>
</table>

<p>
<a href="FailureEvidence/FailureReport.html">
Open highlighted failure report
</a>
</p>

<p>
Raw TRX:
<code>Runs/$RunId/TestResults.trx</code>
</p>

<p>
Console log:
<code>Runs/$RunId/ConsoleOutput.log</code>
</p>

</body>
</html>
"@

Set-Content `
    -Path $TestReportPath `
    -Value $TestReportHtml `
    -Encoding UTF8


# ============================================================
# KNOWN FAILURE REPORT BLOCKS
# ============================================================

$KnownFailureHtml = ""

foreach ($Failure in $KnownFindingFailures) {

    $EvidenceFile =
        $EvidenceLookup[$Failure.TestName]

    $KnownFailureHtml += @"
<div class="finding">

<h3>
$(HtmlEncode $Failure.FindingId)
-
$(HtmlEncode $Failure.FindingTitle)
</h3>

<p>
<strong>Automated scenario:</strong>
$(HtmlEncode $Failure.FindingScenario)
</p>

<p>
<strong>Severity:</strong>
$(HtmlEncode $Failure.Severity)
</p>

<p>
<strong>Category:</strong>
$(HtmlEncode $Failure.Category)
</p>

<p>
<strong>Requirement Status:</strong>
$(HtmlEncode $Failure.RequirementStatus)
</p>

<p>
<strong>Expected:</strong>
$(HtmlEncode $Failure.Expected)
</p>

<p>
<strong>Automated test result:</strong>
<span class="failed">FAILED</span>
</p>

<h4>Failure message</h4>

<pre>$(HtmlEncode $Failure.ErrorMessage)</pre>

<p>
<a href="$(HtmlEncode $EvidenceFile)">
Open raw evidence
</a>
</p>

</div>
"@
}

if ([string]::IsNullOrWhiteSpace($KnownFailureHtml)) {
    $KnownFailureHtml =
        "<p>No known findings were reproduced in this run.</p>"
}


# ============================================================
# UNEXPECTED FAILURE REPORT BLOCKS
# ============================================================

$UnexpectedFailureHtml = ""

foreach ($Failure in $UnexpectedFailures) {

    $EvidenceFile =
        $EvidenceLookup[$Failure.TestName]

    $UnexpectedFailureHtml += @"
<div class="unexpected">

<h3>Unexpected Failure - Needs Triage</h3>

<p>
<strong>Test:</strong>
$(HtmlEncode $Failure.TestName)
</p>

<p>
<strong>Severity:</strong>
$(HtmlEncode $Failure.Severity)
</p>

<p>
<strong>Category:</strong>
$(HtmlEncode $Failure.Category)
</p>

<p>
<strong>Requirement Status:</strong>
$(HtmlEncode $Failure.RequirementStatus)
</p>

<p>
<strong>Expected:</strong>
$(HtmlEncode $Failure.Expected)
</p>

<h4>Failure message</h4>

<pre>$(HtmlEncode $Failure.ErrorMessage)</pre>

<p>
<a href="$(HtmlEncode $EvidenceFile)">
Open raw evidence
</a>
</p>

</div>
"@
}

if ([string]::IsNullOrWhiteSpace($UnexpectedFailureHtml)) {
    $UnexpectedFailureHtml =
        "<p>No unexpected failures were detected.</p>"
}


# ============================================================
# FAILURE REPORT
# ============================================================

$FailureReportHtml = @"
<!DOCTYPE html>
<html>

<head>
<meta charset="utf-8">
<title>QA Failure Evidence</title>

<style>
body {
    font-family: Arial, Helvetica, sans-serif;
    margin: 40px;
    background: #f6f7f9;
    color: #222;
}

.finding {
    background: #fff4ce;
    border-left: 7px solid #d89b00;
    padding: 20px;
    margin-bottom: 22px;
}

.unexpected {
    background: #fde7e7;
    border-left: 7px solid #b42318;
    padding: 20px;
    margin-bottom: 22px;
}

.failed {
    color: #b42318;
    font-weight: bold;
}

pre {
    background: #222;
    color: #f5f5f5;
    padding: 15px;
    overflow-x: auto;
    white-space: pre-wrap;
}

a {
    color: #005fb8;
}
</style>

</head>

<body>

<h1>Highlighted Failure Evidence</h1>

<p>
Run ID:
<strong>$(HtmlEncode $RunId)</strong>
</p>

<h2>Known Findings Reproduced</h2>

$KnownFailureHtml

<h2>Unexpected Failures</h2>

$UnexpectedFailureHtml

<p>
<a href="../TestReport.html">
Back to full test report
</a>
</p>

</body>
</html>
"@

Set-Content `
    -Path $FailureReportPath `
    -Value $FailureReportHtml `
    -Encoding UTF8


# ============================================================
# FINAL TERMINAL SUMMARY
# ============================================================

Write-Host ""
Write-Host "========================================="
Write-Host " QA REPORT GENERATED"
Write-Host "========================================="
Write-Host ""

Write-Host "Total tests:                $Total"
Write-Host "Passed:                     $Passed" -ForegroundColor Green
Write-Host "Failed:                     $Failed" -ForegroundColor Yellow
Write-Host "Skipped:                    $Skipped"

Write-Host ""
Write-Host "Known findings reproduced: $($KnownFindingFailures.Count)"
Write-Host "Unexpected failures:       $($UnexpectedFailures.Count)"

Write-Host ""
Write-Host "Unique findings seen:      $UniqueFindingsSeen"
Write-Host "Recorded runs:             $TotalRuns"

if ($null -ne $PerformanceApiResponseMs) {
    Write-Host ""
    Write-Host "API performance:           $PerformanceApiResponseMs ms"
}

if ($null -ne $PerformanceThresholdMs) {
    Write-Host "Performance threshold:     < $PerformanceThresholdMs ms"
}

Write-Host ""
Write-Host "Generated files:"
Write-Host "  $TestReportPath"
Write-Host "  $FailureReportPath"
Write-Host "  $MetricsPath"
Write-Host "  $HistoryPath"
Write-Host "  $StatePath"
Write-Host "  $TrxPath"
Write-Host "  $ConsoleLogPath"
Write-Host ""


# ============================================================
# EXIT BEHAVIOR
# ============================================================

if ($UnexpectedFailures.Count -gt 0) {
    Write-Host `
        "Execution contains unexpected failures. Investigation required." `
        -ForegroundColor Red

    exit 1
}

if ($KnownFindingFailures.Count -gt 0) {
    Write-Host `
        "Execution completed successfully with documented findings reproduced." `
        -ForegroundColor Yellow

    exit 0
}

Write-Host `
    "Execution completed successfully with no failures." `
    -ForegroundColor Green

exit 0
