# Additional Acceptance Criteria

## User Story

**Create a New Quote**

As a sales representative,  
I want to create a new quote for a customer,  
So that I can provide them with pricing and product details quickly.

---

## Purpose

The following acceptance criteria complement the acceptance criteria originally provided with the assignment.

They were designed to increase coverage of:

- Additional positive behavior
- Business validation
- Financial validation
- Negative scenarios
- Boundary and edge cases
- API error handling
- Security-related behavior
- Performance behavior

Some of these criteria represent proposed business rules derived during QA analysis. Where the original requirements do not explicitly define the expected behavior, the assumption is documented.

---

# Functional Acceptance Criteria

## AC4 - Successfully create a quote with multiple items and a discount

**Category:** Positive / Happy Path

```gherkin
Scenario: Successfully create a quote with two items where one item has a discount

Given a valid customer
And two valid items
And one of the items has a valid discount
When I create the quote
Then the quote should contain both items
And the discount should be correctly applied to the discounted item
And the total quote price should be the sum of the calculated line prices
And the quote should be created successfully
```

**Automated test note:**  
The implemented automated scenario uses example values whose expected total quote price is `230`.

---

## AC5 - Reject a quote without a customer

**Category:** Negative / Required Data Validation

```gherkin
Scenario: Reject quote with empty customer

Given the customer value is empty
And the quote contains at least one valid item
When I try to create the quote
Then the HTTP status should be 400
```

**Expected behavior:**  
A quote should not be created without identifying the customer.

---

## AC6 - Reject a quote without items

**Category:** Negative / Required Data Validation

```gherkin
Scenario: Reject quote without items

Given a valid customer
And no items are included in the quote
When I try to create the quote
Then the HTTP status should be 400
```

**Expected behavior:**  
A quote should contain at least one item.

---

## AC7 - Reject an item with an empty name

**Category:** Negative / Data Validation

```gherkin
Scenario: Reject quote with empty item name

Given a valid customer
And an item with an empty item name
When I try to create the quote
Then the HTTP status should be 400
```

**Expected behavior:**  
An item without an identifiable name should not be accepted as a valid quote line.

**Current implementation observation:**  
This criterion is not currently satisfied by the API and is documented as finding **F01** in `TEST_FINDINGS.md`.

---

## AC8 - Reject an item with a negative quantity

**Category:** Negative / Business Validation / Data Integrity

```gherkin
Scenario: Reject quote with negative item quantity

Given a valid customer
And an item with a quantity lower than zero
When I try to create the quote
Then the HTTP status should be 400
```

**Expected behavior:**  
Negative quantities should not be accepted because they can generate invalid quote values.

**Current implementation observation:**  
This criterion is not currently satisfied by the API and is documented as finding **F02** in `TEST_FINDINGS.md`.

---

## AC9 - Reject an item with a negative unitary price

**Category:** Negative / Financial Validation

```gherkin
Scenario: Reject quote with negative unitary price

Given a valid customer
And an item with a unitary price lower than zero
When I try to create the quote
Then the HTTP status should be 400
```

**Expected behavior:**  
A negative unitary price should not be accepted because it can generate an invalid negative quote total.

**Current implementation observation:**  
This criterion is not currently satisfied by the API and is documented as finding **F03** in `TEST_FINDINGS.md`.

---

## AC10 - Reject a discount greater than 100%

**Category:** Boundary / Financial Validation

```gherkin
Scenario: Reject quote with discount greater than 100 percent

Given a valid customer
And an item with a discount greater than 100%
When I try to create the quote
Then the HTTP status should be 400
```

**Expected behavior:**  
A percentage discount greater than `100%` should not be accepted because the discount amount can become greater than the gross line price and generate a negative line total.

**Current implementation observation:**  
This criterion is not currently satisfied by the API and is documented as finding **F04** in `TEST_FINDINGS.md`.

---

## AC11 - Accept a 100% discount as a valid boundary

**Category:** Boundary / Positive

```gherkin
Scenario: Successfully create a quote with 100 percent discount

Given a valid customer
And a valid item
And the item has a discount of exactly 100%
When I create the quote
Then the quote should be created successfully
And the discount amount should equal the gross line price
And the line price should be zero
And the total quote price should be zero
```

**Expected behavior:**  
Exactly `100%` is considered the upper valid boundary for the discount percentage.

This also verifies the distinction between:

```text
100% discount       → valid boundary
greater than 100%   → invalid value
```

---

## AC12 - Reject an item with zero quantity

**Category:** Edge Case / Business Validation

```gherkin
Scenario: Reject quote with zero item quantity

Given a valid customer
And an item with quantity equal to zero
When I try to create the quote
Then the HTTP status should be 400
```

**Proposed business rule:**  
A quote line representing zero units does not produce a meaningful commercial transaction and is therefore assumed to be invalid.

**Requirement status:**  
**Needs business clarification.**

The original requirements do not explicitly state whether a quantity of `0` should be allowed.

Therefore, this criterion represents a QA assumption that should be validated with a product or business stakeholder.

**Current implementation observation:**  
The API currently accepts this value. The behavior is documented as finding **F05** in `TEST_FINDINGS.md`.

---

## AC13 - Reject a negative discount

**Category:** Boundary / Financial Validation

```gherkin
Scenario: Reject quote with negative discount

Given a valid customer
And an item with a discount lower than 0%
When I try to create the quote
Then the HTTP status should be 400
```

**Expected behavior:**  
A negative discount should not be accepted because it increases the calculated price instead of reducing it.

The expected valid discount range is therefore assumed to be:

```text
0% <= discount <= 100%
```

**Current implementation observation:**  
This criterion is not currently satisfied by the API and is documented as finding **F06** in `TEST_FINDINGS.md`.

---

# Non-Functional Acceptance Criteria

## AC14 - Reject malformed JSON without exposing internal server details

**Category:** Security / Error Handling

```gherkin
Scenario: Reject malformed JSON without exposing internal server details

Given a malformed JSON request
When the request is sent to the Create Quote endpoint
Then the HTTP status should be 400
And the response should not expose internal exception details
And the response should not expose stack trace information
```

**Purpose:**  
The API should safely reject structurally invalid input without exposing implementation details that could unnecessarily disclose internal system information.

**Scope:**  
This is a basic information-disclosure and API error-handling check. It is not intended to represent a complete security or penetration test.

---

## AC15 - Create a quote with 100 items within an acceptable response time

**Category:** Performance

```gherkin
Scenario: Create a quote with 100 items within an acceptable response time

Given a valid customer
And 100 valid items
When I create the quote measuring the response time
Then the HTTP status should be 200
And the quote should contain 100 lines
And the response time should be less than 2000 milliseconds
```

### Performance Assumption

No response-time SLA or official performance threshold was provided in the requirements.

For this exercise, the following threshold was adopted as an illustrative baseline:

```text
< 2000 ms
```

This value is a **QA testing assumption**, not an official system SLA.

In a real project, the acceptable response time should be defined or validated with the appropriate product and technical stakeholders.

The automated reporting process records both:

```text
Configured threshold
Actual API response time measured during execution
```

The HTTP request duration is measured using `Stopwatch`.

---

# Assumptions and Clarifications

The additional criteria contain a small number of assumptions made during QA analysis because the original user story does not define every validation rule.

The main assumptions are:

### Quantity

```text
quantity > 0
```

A quantity of zero is currently treated as invalid by the proposed acceptance criterion, but this rule requires business confirmation.

### Unitary Price

```text
unitaryPrice >= 0
```

Negative monetary values are considered invalid.

### Discount

```text
0 <= discount <= 1
```

Where:

```text
0    = 0%
1    = 100%
```

Values below `0` or above `1` are considered invalid.

### Performance

```text
response time < 2000 ms
```

This is an illustrative testing baseline because no official SLA was provided.

---

# Traceability

Findings discovered while executing these acceptance criteria are documented separately in:

```text
TEST_FINDINGS.md
```

Automated test execution evidence and metrics are generated under:

```text
TestResults/
```

Manual API requests used for selected reproductions are available in:

```text
QuoteAcceptanceTests/Requests/CreateQuoteRequests.http
```

The automated scenarios themselves are implemented in the Reqnroll feature and step-definition files under:

```text
QuoteAcceptanceTests/
```