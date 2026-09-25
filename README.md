# Quality Assurance Take-Home - Create Quote API

## Overview

This solution contains the automated acceptance tests created for the **Create a New Quote** user story.

The implementation uses:

- C#
- .NET 8
- Reqnroll / Gherkin for BDD scenarios
- MSTest for test execution and assertions
- PowerShell for automated test reporting and quality metrics

The test suite covers the acceptance criteria provided in the assignment as well as additional scenarios identified during the QA analysis.

---

## Prerequisites

The following are required:

- .NET 8 SDK
- Visual Studio 2022 or Visual Studio Code
- PowerShell

The application and tests were executed using the .NET CLI.

---

## Project Structure

Main files and folders relevant to the QA solution:

```text
Quote.Solution
├── Quote
├── QuoteAcceptanceTests
│   ├── Features
│   ├── StepDefinitions
│   └── Requests
│       └── CreateQuoteRequests.http
├── QuoteService
├── QuoteService.UnitTests
├── TEST_FINDINGS.md
├── AdditionalAcceptanceCriteria.md
├── RunTestsAndGenerateReport.ps1
├── TestResults
└── Quote.sln
```

---

## Start the Quote API

From the solution root directory, run:

```powershell
dotnet run --project .\Quote\Quote.csproj --urls "http://localhost:59252"
```

Keep this terminal running while executing the automated tests.

The API health endpoint can be accessed at:

```text
http://localhost:59252/api/Quotes/isalive
```

---

## Run All Automated Tests

Open another terminal in the solution root directory and run:

```powershell
dotnet test .\QuoteAcceptanceTests\QuoteAcceptanceTests.csproj
```

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

The solution includes an automated QA reporting script:

```text
RunTestsAndGenerateReport.ps1
```

Make sure the Quote API is already running.

From the solution root directory, execute:

```powershell
.\RunTestsAndGenerateReport.ps1
```

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

## Notes

The purpose of the additional scenarios is not only to verify successful behavior, but also to identify unclear requirements, business risks and inconsistent API behavior.

Where the original requirements do not explicitly define the expected behavior, the assumption or need for clarification is documented instead of being treated automatically as a confirmed requirement defect.