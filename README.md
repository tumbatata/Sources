# Quality Assurance Take-Home — Create Quote API

Automated acceptance tests for the Eurofins **Create a New Quote** assignment, using C#, .NET 8, Reqnroll/Gherkin and MSTest.

## Start here

- [Execution instructions](Quote.Solution/README.md)
- [Acceptance scenarios](Quote.Solution/QuoteAcceptanceTests/Features/CreateQuote.feature)
- [Step definitions](Quote.Solution/QuoteAcceptanceTests/StepDefinitions/CreateQuoteSteps.cs)
- [Additional acceptance criteria](Quote.Solution/AdditionalAcceptanceCriteria.md)
- [Documented findings](Quote.Solution/TEST_FINDINGS.md)
- [Saved execution metrics](Quote.Solution/TestResults/Metrics.json)

## Quick start on Windows

Install the .NET 8 SDK. Clone or download this repository, open `Quote.Solution` in Windows File Explorer and double-click **RunDemo.cmd**.

The launcher finds its own folder, starts the API if needed, waits for readiness, executes the acceptance tests, generates reports and opens the fresh HTML report. It preserves failing exit codes and leaves the console open. No `cd` commands or second terminal are needed. See [execution details](Quote.Solution/README.md#automated-demo-on-windows), including process cleanup and PowerShell policy behavior.

### Manual alternative

Use PowerShell in two terminals.
From the repository root (the folder containing this README), run:

```powershell
cd .\Quote.Solution
```

Alternatively, open the `Quote.Solution` folder directly in VS Code or Visual Studio.
Every command below runs from that folder, which contains `Quote.sln`.

**Terminal 1 — start the API and keep it running:**

```powershell
dotnet run --project .\Quote\Quote.csproj --urls "http://localhost:59252"
```

Wait until the API is listening on `http://localhost:59252`.

**Terminal 2 — navigate to `Quote.Solution` again, then run the acceptance suite:**

```powershell
dotnet test .\QuoteAcceptanceTests\QuoteAcceptanceTests.csproj
```

To execute the same suite and generate HTML reports instead, run:

```powershell
.\RunTestsAndGenerateReport.ps1
```

If Windows blocks this trusted downloaded script, unblock only this file once:

```powershell
Unblock-File -LiteralPath .\RunTestsAndGenerateReport.ps1
.\RunTestsAndGenerateReport.ps1
```

## How to interpret failures

Six additional validation scenarios reproduce documented findings against the supplied API. The assignment allows correct tests to fail; production code has not been changed to make those tests pass.

The reporting script writes reports even when tests fail and returns a nonzero exit code for a failing or incomplete run. A known finding is an explanation of a failure, not a passing test. Read the findings and assumptions alongside the results.

The committed reports are snapshots of earlier executions. Run the current suite to produce results for the current code. Download HTML reports and open them locally to view the rendered report; GitHub may display their source.

## Review updates after the initial submission

The initial submission is preserved in commit `6fa0544`. Subsequent review improvements correct clone-relative execution instructions, preserve failing test exit codes, require failure evidence before classifying a known finding, and strengthen successful-response checks. Previously saved reports are retained as historical evidence, not presented as a fresh execution of those changes.
