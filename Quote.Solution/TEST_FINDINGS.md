# Test Findings

This document records findings identified while executing the additional acceptance criteria.

Some expected behaviors are based on reasonable business and API consistency assumptions where the original requirements do not explicitly define the validation rule. These cases are documented as findings and potential defects rather than changes to the production code.

## Summary

- **F01 - Empty item name returns HTTP 200**
  - Category: API Contract / Error Handling
  - Severity: Medium
  - Status: Reproduced
  - Requirement Status: Strong inconsistency

- **F02 - Negative quantity is accepted**
  - Category: Business Validation / Data Integrity
  - Severity: High
  - Status: Reproduced
  - Requirement Status: Expected validation

- **F03 - Negative unitary price is accepted**
  - Category: Financial Validation / Data Integrity
  - Severity: High
  - Status: Reproduced
  - Requirement Status: Expected validation

- **F04 - Discount greater than 100% is accepted**
  - Category: Financial Validation / Business Logic
  - Severity: High
  - Status: Reproduced
  - Requirement Status: Expected validation

- **F05 - Zero quantity is accepted**
  - Category: Business Validation
  - Severity: Medium
  - Status: Reproduced
  - Requirement Status: Needs clarification

- **F06 - Negative discount is accepted**
  - Category: Financial Validation / Business Logic
  - Severity: High
  - Status: Reproduced
  - Requirement Status: Expected validation

---

## Finding 1 - Empty item name returns HTTP 200

**Category:** API Contract / Error Handling  
**Severity:** Medium  
**Status:** Reproduced  
**Requirement Status:** Strong inconsistency

### Scenario

Create a quote using:

- A valid customer
- One item with an empty name
- Valid quantity and unitary price

### Expected Result

The request should be rejected with:

`HTTP 400 Bad Request`

### Actual Result

The API returns:

`HTTP 200 OK`

The response body indicates an error:

- `quote` is null
- `confirmation.message` is `"Cannot create the quote for a null item."`
- `confirmation.level` indicates an error

### Observation

The application correctly identifies the empty item name as invalid in the business logic.

However, the HTTP response status is `200 OK`, which indicates a successful HTTP request.

This behavior is inconsistent with other invalid requests, such as an empty customer or an empty items collection, which are rejected with `HTTP 400 Bad Request`.

The response message also refers to a `null item`, although the tested value is an empty string.

### Related Automated Test

`Reject quote with empty item name`

### Test Status

Failing as expected.

### Reproduction

The behavior can also be reproduced manually using:

`QuoteAcceptanceTests/Requests/CreateQuoteRequests.http`

---

## Finding 2 - Negative quantity is accepted and creates a quote with negative total price

**Category:** Business Validation / Data Integrity  
**Severity:** High  
**Status:** Reproduced  
**Requirement Status:** Expected validation

### Scenario

Create a quote using:

- A valid customer
- A valid item name
- Quantity equal to `-1`
- Unitary price equal to `5`

### Expected Result

The request should be rejected with:

`HTTP 400 Bad Request`

### Actual Result

The API returns:

`HTTP 200 OK`

A quote is successfully created with:

- `quantity = -1`
- `unitaryPrice = 5`
- `totalPrice = -5`

### Observation

The API does not validate negative item quantities.

As a result, the quote is successfully created with a negative total price, which represents an invalid business value and may compromise pricing data integrity.

### Related Automated Test

`Reject quote with negative item quantity`

### Test Status

Failing as expected.

### Reproduction

The behavior can also be reproduced manually using:

`QuoteAcceptanceTests/Requests/CreateQuoteRequests.http`

---

## Finding 3 - Negative unitary price is accepted and creates a quote with negative total price

**Category:** Financial Validation / Data Integrity  
**Severity:** High  
**Status:** Reproduced  
**Requirement Status:** Expected validation

### Scenario

Create a quote using:

- A valid customer
- A valid item name
- Quantity equal to `1`
- Unitary price equal to `-5`

### Expected Result

The request should be rejected with:

`HTTP 400 Bad Request`

### Actual Result

The API returns:

`HTTP 200 OK`

A quote is successfully created with:

- `quantity = 1`
- `unitaryPrice = -5`
- `totalPrice = -5`

### Observation

The API does not validate negative unitary prices.

As a result, the quote is successfully created with an invalid negative monetary value, which may compromise financial data integrity.

### Related Automated Test

`Reject quote with negative unitary price`

### Test Status

Failing as expected.

### Reproduction

The behavior can also be reproduced manually using:

`QuoteAcceptanceTests/Requests/CreateQuoteRequests.http`

---

## Finding 4 - Discount greater than 100% is accepted and creates a quote with negative total price

**Category:** Financial Validation / Business Logic  
**Severity:** High  
**Status:** Reproduced  
**Requirement Status:** Expected validation

### Scenario

Create a quote using:

- A valid customer
- A valid item
- Quantity equal to `1`
- Unitary price equal to `100`
- Discount percentage equal to `1.10` (110%)

### Expected Result

The request should be rejected with:

`HTTP 400 Bad Request`

### Actual Result

The API returns:

`HTTP 200 OK`

A quote is successfully created with:

- `unitaryPrice = 100`
- `discountPercentage = 1.10`
- `discountAmount = 110`
- `totalPrice = -10`

### Observation

The API does not validate discount percentages greater than 100%.

As a result, a discount greater than the item value is accepted and the quote is created with a negative total price.

The boundary case using exactly 100% discount was also tested and is accepted with a total price of `0`, while values greater than 100% are not rejected.

### Related Automated Test

`Reject quote with discount greater than 100 percent`

### Test Status

Failing as expected.

### Reproduction

The behavior can also be reproduced manually using:

`QuoteAcceptanceTests/Requests/CreateQuoteRequests.http`

---

## Finding 5 - Zero quantity is accepted

**Category:** Business Validation  
**Severity:** Medium  
**Status:** Reproduced  
**Requirement Status:** Needs clarification

### Scenario

Create a quote using:

- A valid customer
- A valid item
- Quantity equal to `0`
- Unitary price equal to `5`

### Expected Result

Based on the assumed business rule that a quote line must represent at least one unit, the request should be rejected with:

`HTTP 400 Bad Request`

### Actual Result

The API returns:

`HTTP 200 OK`

A quote is successfully created with:

- `quantity = 0`
- `totalPrice = 0`

### Observation

The API does not validate zero item quantity.

This allows the creation of a quote line with no effective quantity.

Unlike negative quantity, the original requirements do not explicitly state whether zero quantity should be considered invalid. Therefore, this behavior should be clarified with the product or business owner.

### Related Automated Test

`Reject quote with zero item quantity`

### Test Status

Failing based on the assumed business rule.

### Reproduction

The behavior can also be reproduced manually using:

`QuoteAcceptanceTests/Requests/CreateQuoteRequests.http`

## Finding 6 - Negative discount is accepted and increases the quote price

**Category:** Financial Validation / Business Logic  
**Severity:** High  
**Status:** Reproduced  
**Requirement Status:** Expected validation

### Scenario

Create a quote using:

- A valid customer
- A valid item
- Quantity equal to `1`
- Unitary price equal to `100`
- Discount percentage equal to `-0.10` (-10%)

### Expected Result

The request should be rejected with:

`HTTP 400 Bad Request`

### Actual Result

The API returns:

`HTTP 200 OK`

The negative discount is accepted and increases the final item price.

### Observation

The API does not validate negative discount percentages.

A negative discount is mathematically subtracted from the original price, which effectively increases the quote value instead of applying a discount.

### Related Automated Test

`Reject quote with negative discount`

### Test Status

Failing as expected.

### Reproduction

The behavior can also be reproduced manually using:

`QuoteAcceptanceTests/Requests/CreateQuoteRequests.http`