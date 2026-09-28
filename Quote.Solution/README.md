# Create Quote API acceptance tests

This solution tests the supplied quote API using C#, .NET 8, Reqnroll/Gherkin and MSTest. The suite covers the provided criteria and additional positive, negative, boundary, error-handling and response-time scenarios. Proposed business rules and findings are documented separately.

## Automated demo on Windows

With the .NET 8 SDK installed, double-click **RunDemo.cmd** in this folder. No terminal directory setup is required. You can also right-click the file in VS Code, choose **Reveal in File Explorer**, and double-click it there.

The launcher uses its own location, reuses an API already responding at the health endpoint or starts the supplied API, waits up to 120 seconds for readiness, runs the acceptance suite with reports, and opens the newly generated HTML report. It stops only an API process tree it started itself. A pre-existing API remains running; stop it before the demo if you want a fresh instance from this checkout.

The command window remains open for inspection. Six documented failures are expected; the launcher preserves the failing exit code. A startup or reporting error is shown instead of opening an old report. API startup logs are in `TestResults/Demo/`.

The launcher uses `RemoteSigned` for its PowerShell process only and unblocks the two supplied PowerShell files. It does not permanently change the machine's execution policy. Organization-enforced policies still apply.

## Manual execution: working directory

Open the folder containing `Quote.sln` before running commands.

- From the cloned GitHub repository root: `cd .\Quote.Solution`.
- From the original take-home archive root: `cd .\Sources\Quote.Solution`.
- If `Quote.sln` is already in the current folder, no directory change is needed.

Check your location in PowerShell:

```powershell
Test-Path .\Quote.sln
```

The result should be `True`. Use this working directory in both terminals.

## Prerequisites

- .NET 8 SDK.
- PowerShell for the optional report script.
- Visual Studio 2022 or VS Code, if using an IDE.

## Start the API

In terminal 1:

```powershell
dotnet run --project .\Quote\Quote.csproj --urls "http://localhost:59252"
```

Wait for the listening message and leave the process running. The health endpoint is `http://localhost:59252/api/Quotes/isalive`.

## Run tests

In terminal 2, first navigate to the folder containing `Quote.sln` again. Opening a new terminal or opening this README does not automatically change its working directory. Then run:

```powershell
dotnet test .\QuoteAcceptanceTests\QuoteAcceptanceTests.csproj
```

This runs the acceptance test project. To run every test project in the solution, including the supplied unit tests, use `dotnet test .\Quote.sln` with the API running.

To run one scenario:

```powershell
dotnet test .\QuoteAcceptanceTests\QuoteAcceptanceTests.csproj --filter "Name~RejectMalformedJSONWithoutExposingInternalServerDetails"
```

For detailed console output:

```powershell
dotnet test .\QuoteAcceptanceTests\QuoteAcceptanceTests.csproj --logger "console;verbosity=detailed"
```

## Generate reports

The following script executes the acceptance suite and produces reports from the actual TRX results:

```powershell
.\RunTestsAndGenerateReport.ps1
```

If Windows marks this trusted downloaded script as blocked, unblock this file once and retry:

```powershell
Unblock-File -LiteralPath .\RunTestsAndGenerateReport.ps1
.\RunTestsAndGenerateReport.ps1
```

Open the reports:

```powershell
start .\TestResults\TestReport.html
start .\TestResults\FailureEvidence\FailureReport.html
```

The script must be allowed to finish writing reports even when tests fail. It returns the nonzero `dotnet test` exit code; failed, incomplete or empty results also produce a nonzero exit. Known failures are never converted into a successful build.

### Failure classification

A scenario is associated with a known finding by its exact normalized name. A failed execution is classified as reproducing that finding only when its assertion message contains `HTTP_STATUS_MISMATCH expected=400 actual=200` and its stack trace identifies `ThenTheHttpStatusShouldBe`.

A timeout, HTTP 500, different assertion, or other failure in the same scenario is classified as unexpected and requires investigation. This checks the known HTTP-status symptom; it does not automatically prove the full business impact recorded in the finding. Severity remains a human QA assessment.

The state file tracks finding occurrences and first/last reproduction dates. A different failure in a known scenario is marked as needing investigation, without counting it as another reproduction.

### Output files

| File | Purpose |
| --- | --- |
| `TestResults/TestReport.html` | Overall execution report |
| `TestResults/FailureEvidence/FailureReport.html` | Failed tests and available evidence |
| `TestResults/Metrics.json` | Latest execution metrics |
| `TestResults/History.csv` | Execution history |
| `TestResults/FindingsState.json` | Finding reproduction history |
| `TestResults/Runs/` | Per-run TRX and console output, generated locally |

Committed reports are historical snapshots. Re-run the suite after changing code; do not interpret saved snapshots as evidence of the modified suite. HTML reports should be downloaded and opened locally.

## Test scope and findings

- [Gherkin scenarios](QuoteAcceptanceTests/Features/CreateQuote.feature)
- [Step implementations](QuoteAcceptanceTests/StepDefinitions/CreateQuoteSteps.cs)
- [Additional acceptance criteria](AdditionalAcceptanceCriteria.md)
- [Findings and requirement assumptions](TEST_FINDINGS.md)
- [Manual reproduction requests](QuoteAcceptanceTests/Requests/CreateQuoteRequests.http)

Successful quote scenarios check HTTP status, customer, item details and expected calculations. The item-detail check matches unique item names rather than requiring an undocumented response order. The current test data uses unique names.

Six additional validation scenarios are expected to fail against the supplied implementation. The assignment permits this; the failures remain visible, and production code is unchanged. Assumptions should be reviewed with business stakeholders rather than treated as confirmed requirements.

## Performance and error handling

The response-time scenario sends one quote with 100 valid items and measures the request using `Stopwatch`. Its threshold of 2000 ms is an assumed baseline, not an official SLA. This is a single-request timing check, not a load or stress test.

The malformed-JSON scenario expects HTTP 400 and checks for selected internal exception markers. It is a focused error-handling check, not a comprehensive security assessment.

## Troubleshooting

- **Project or script not found:** verify `Test-Path .\Quote.sln` returns `True`.
- **API unavailable:** start it in terminal 1 and confirm port 59252.
- **PowerShell policy error:** use the single-file unblock command above. Organization-enforced signing requirements may still prevent execution.
- **Nonzero exit with reports generated:** review the failed tests; this is intentional even for documented findings.
