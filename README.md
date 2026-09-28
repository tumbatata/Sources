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

<<<<<<< HEAD
Wait until the API is listening on `http://localhost:59252`.

**Terminal 2 — navigate to `Quote.Solution` again, then run the acceptance suite:**
=======
Keep this terminal running while executing the automated tests.

The API health endpoint can be accessed at:

```text
http://localhost:59252/api/Quotes/isalive
```

---

## Run All Automated Tests

Open another terminal in the solution root directory and run:
>>>>>>> cf9f0763ebea26088b567f1d3471a462e888b619

```powershell
dotnet test .\QuoteAcceptanceTests\QuoteAcceptanceTests.csproj
```

<<<<<<< HEAD
To execute the same suite and generate HTML reports instead, run:
=======
This executes the complete automated test suite.

---

## Run a Specific Test

A specific scenario can be executed using the `--filter` option.

Example:

```powershell
dotnet test .\QuoteAcceptanceTests\QuoteAcceptanceTests.csproj --filter "Name~RejectMalformedJSONWithoutExposingInternalServerDetails"
```

For a more detailed console output:

```powershell
dotnet test .\QuoteAcceptanceTests\QuoteAcceptanceTests.csproj --logger "console;verbosity=detailed"
```

The filter is useful when investigating or validating one scenario independently from the complete regression suite.

---

## Run Tests and Generate QA Reports

Open a second terminal.

The solution includes an automated QA reporting script. The commands below are safe even if the terminal opens one level above the solution:

```text
RunTestsAndGenerateReport.ps1
```

Make sure the Quote API is already running.

Execute:

```powershell
if (Test-Path ".\Sources\Quote.Solution\Quote.sln") {
    Set-Location ".\Sources\Quote.Solution"
}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\RunTestsAndGenerateReport.ps1
```


### PowerShell Execution Policy

On some Windows environments, PowerShell may block the reporting script because local script execution is restricted.

If this happens, run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

Then execute the reporting script normally:
>>>>>>> cf9f0763ebea26088b567f1d3471a462e888b619

```powershell
.\RunTestsAndGenerateReport.ps1
```

<<<<<<< HEAD
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
=======
This setting applies only to the current PowerShell process and does not permanently change the machine-wide execution policy.

The script automatically:

- Executes the complete automated test suite
- Generates the MSTest TRX result
- Reads the actual test execution results
- Classifies failed tests as known findings or unexpected failures
- Generates quality and execution metrics
- Tracks findings across multiple executions
- Prevents the same known finding from being counted as a new defect on every run
- Records finding occurrences
- Records first-seen and last-seen timestamps
- Records performance measurements
- Updates execution history
- Generates a full HTML test report
- Generates a highlighted failure report
- Stores raw evidence for failed tests

---

## Generated Reports

Reports are generated automatically under:

```text
TestResults/
```

### Main Test Report

```text
TestResults/TestReport.html
```

Contains:

- Total tests
- Passed tests
- Failed tests
- Skipped tests
- Known findings reproduced
- Unexpected failures
- Unique findings
- Number of recorded executions
- Performance result
- Current finding status
- Complete test execution list

The report can be opened using:

```powershell
start .\TestResults\TestReport.html
```

### Highlighted Failure Report

```text
TestResults/FailureEvidence/FailureReport.html
```

This report highlights the failed scenarios and displays:

- Finding ID
- Severity
- Category
- Requirement status
- Expected behavior
- Automated test result
- Failure message
- Raw execution evidence

It can be opened using:

```powershell
start .\TestResults\FailureEvidence\FailureReport.html
```

### Additional Generated Files

```text
TestResults/Metrics.json
```

Stores structured metrics from the latest execution.

```text
TestResults/History.csv
```

Stores the execution history and allows metrics to be compared between test runs.

```text
TestResults/FindingsState.json
```

Stores the cumulative state of known findings, including:

- Status
- Number of occurrences
- First seen
- Last seen
- Latest result

```text
TestResults/Runs/
```

Stores the raw `.trx` file and console output for each individual execution.

---

## Failure Classification

The report distinguishes between two different types of failures.

### Known Finding

A known finding is a behavior that:

1. Was identified during test execution
2. Was investigated
3. Was reproduced
4. Was documented in `TEST_FINDINGS.md`
5. Was classified by QA

When the same finding fails again in another execution, it is **not counted as a new defect**.

Instead, the report updates:

- Occurrence count
- Last seen date
- Current reproduction status

Severity and category are assigned during QA analysis and are not automatically inferred by the test framework.

### Unexpected Failure

If a test fails and does not correspond to a previously documented finding, the report classifies it as:

```text
Unexpected Failure
Severity: Unclassified
Category: Needs triage
Requirement Status: Needs investigation
```

The failure must then be investigated before a severity or business impact is assigned.

This prevents the reporting process from automatically treating every technical failure as a confirmed defect.

---

## Test Scope

The automated suite covers:

- Provided acceptance criteria
- Additional happy-path scenarios
- Negative scenarios
- Boundary cases
- Edge cases
- Business validation
- Financial validation
- API error handling
- Security-related behavior
- Performance behavior

Some additional automated tests intentionally fail because they reproduce behaviors that do not satisfy the proposed additional acceptance criteria.

Production code was not modified to force these tests to pass.

---

## Known Findings

Detailed findings are documented in:

```text
TEST_FINDINGS.md
```

Each documented finding contains:

- Scenario
- Expected result
- Actual result
- Category
- Severity
- Requirement status
- Observation
- Related automated test
- Reproduction information

Manual API requests used to reproduce selected behaviors are available in:

```text
QuoteAcceptanceTests/Requests/CreateQuoteRequests.http
```

---

## Additional Acceptance Criteria

The additional acceptance criteria created during the QA analysis are documented separately in:

```text
AdditionalAcceptanceCriteria.md
```

They include positive, negative, boundary, edge, security and performance scenarios.

---

## Performance Test Assumption

The performance scenario creates a quote containing **100 valid items**.

The automated test currently uses the following response-time threshold:

```text
< 2000 ms
```

No official performance SLA or response-time requirement was provided for the exercise.

Therefore, the `2000 ms` threshold is an **assumed baseline used for testing purposes only** and should be validated with product and technical stakeholders in a real project.

The test report records both:

- The configured threshold
- The actual API response time measured during the execution

The HTTP request duration is measured using `Stopwatch`.

---

## Security Scenario

The security-related scenario sends malformed JSON to the Create Quote endpoint and validates that:

- The request is rejected with an HTTP `400` response
- Internal exception or stack trace information is not exposed in the API response

This is a basic API security and information-disclosure validation and is not intended to represent a complete penetration test.

---


## Troubleshooting

### Terminal opened in the wrong folder

Check the current directory:

```powershell
pwd
```

The path should end with:

```text
...\Sources\Quote.Solution
```

If it does not, either reopen `Sources/Quote.Solution` using **File > Open Folder...** or navigate manually:

```powershell
cd .\Sources\Quote.Solution
```

### `Project file does not exist`

This usually means the command was executed outside the solution root directory.

Make sure the terminal is inside the folder that contains:

```text
Quote.sln
```

Then run the command again.

### `RunTestsAndGenerateReport.ps1 is not recognized`

Confirm that:

- The terminal is inside `Sources/Quote.Solution`
- The file is named `RunTestsAndGenerateReport.ps1`
- The script is executed with `.\`

Run:

```powershell
.\RunTestsAndGenerateReport.ps1
```

### PowerShell blocks script execution

If PowerShell blocks the script because of the execution policy, allow script execution only for the current terminal session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

Then run:

```powershell
.\RunTestsAndGenerateReport.ps1
```

### Reporting script says the API is not running

Make sure the API is running in a separate terminal on port `59252`.

Start it with:

```powershell
dotnet run --project .\Quote\Quote.csproj --urls "http://localhost:59252"
```

Keep that terminal open while running the automated tests.

### `NoProcessFoundForGivenName`

This can happen if the PowerShell prompt itself was copied together with the command.

Do not copy:

```text
PS C:\...
```

Copy only the command that comes after the prompt.

---

## Notes

The purpose of the additional scenarios is not only to verify successful behavior, but also to identify unclear requirements, business risks and inconsistent API behavior.

Where the original requirements do not explicitly define the expected behavior, the assumption or need for clarification is documented instead of being treated automatically as a confirmed requirement defect.
>>>>>>> cf9f0763ebea26088b567f1d3471a462e888b619
