@CreateQuote
Feature: Create Quote

  @AC1
  Scenario Outline: Successfully create a new quote with one item
    Given a customer "<customer>"
    And an item "<item>" with quantity <quantity> and unitary price <price>
    When I create the quote
    Then the line price should be <total>
    And the confirmation message should be "Quote created successfully."

    Examples:
      | customer   | item   | quantity | price | total |
      | Customer A | Banana | 3        | 5     | 15    |
      | Customer B | Milk   | 2        | 10    | 20    |


  @AC2
  Scenario Outline: Successfully create a new quote with one item with discount
    Given a customer "<customer>"
    And an item "<item>" with quantity <quantity>, unitary price <price> and discount <discount>
    When I create the quote
    Then the discount amount should be <discountAmount>
    And the line price should be <total>
    And the confirmation message should be "Quote created successfully."

    Examples:
      | customer   | item     | quantity | price | discount | discountAmount | total |
      | Customer C | Notebook | 2        | 100   | 0.10     | 20             | 180   |


  @AC3
  Scenario Outline: Successfully create a new quote with two items
    Given a customer "<customer>"
    And an item "<item1>" with quantity <quantity1> and unitary price <price1>
    And an item "<item2>" with quantity <quantity2> and unitary price <price2>
    When I create the quote
    Then the quote should contain 2 lines
    And the total price should be <total>
    And the confirmation message should be "Quote created successfully."

    Examples:
      | customer   | item1  | quantity1 | price1 | item2 | quantity2 | price2 | total |
      | Customer D | Banana | 3         | 5      | Milk  | 2         | 10     | 35    |


  @AC4
  Scenario Outline: Successfully create a quote with multiple items including discount
    Given a customer "<customer>"
    And an item "<item1>" with quantity <quantity1>, unitary price <price1> and discount <discount1>
    And an item "<item2>" with quantity <quantity2> and unitary price <price2>
    When I create the quote
    Then the quote should contain 2 lines
    And the total price should be <total>
    And the confirmation message should be "Quote created successfully."

    Examples:
      | customer   | item1    | quantity1 | price1 | discount1 | item2 | quantity2 | price2 | total |
      | Customer E | Notebook | 2         | 100    | 0.10      | Mouse | 1         | 50     | 230   |


  @AC5 @Negative
  Scenario: Reject quote with empty customer
    Given a customer ""
    And an item "Banana" with quantity 1 and unitary price 5
    When I try to create the quote
    Then the HTTP status should be 400
    And the error response should contain "Customer or Items cannot be null or empty"


  @AC6 @Negative
  Scenario: Reject quote with no items
    Given a customer "Customer F"
    When I try to create the quote
    Then the HTTP status should be 400
    And the error response should contain "Customer or Items cannot be null or empty"


  @AC7 @Negative
  Scenario: Reject quote with empty item name
    Given a customer "Customer G"
    And an item "" with quantity 1 and unitary price 5
    When I try to create the quote
    Then the HTTP status should be 400


  @AC8 @Negative @Boundary
  Scenario: Reject quote with negative item quantity
    Given a customer "Customer H"
    And an item "Banana" with quantity -1 and unitary price 5
    When I try to create the quote
    Then the HTTP status should be 400


  @AC9 @Negative @Boundary
  Scenario: Reject quote with negative unitary price
    Given a customer "Customer I"
    And an item "Banana" with quantity 1 and unitary price -5
    When I try to create the quote
    Then the HTTP status should be 400


  @AC10 @Negative @Boundary
  Scenario: Reject quote with discount greater than 100 percent
    Given a customer "Customer J"
    And an item "Notebook" with quantity 1, unitary price 100 and discount 1.10
    When I try to create the quote
    Then the HTTP status should be 400


  @AC11 @Boundary
  Scenario: Successfully create a quote with 100 percent discount
    Given a customer "Customer K"
    And an item "Notebook" with quantity 1, unitary price 100 and discount 1.00
    When I create the quote
    Then the discount amount should be 100
    And the line price should be 0
    And the total price should be 0
    And the confirmation message should be "Quote created successfully."


  @AC12 @Negative @Boundary
  Scenario: Reject quote with zero item quantity
    Given a customer "Customer L"
    And an item "Banana" with quantity 0 and unitary price 5
    When I try to create the quote
    Then the HTTP status should be 400


  @AC13 @Negative @Boundary
  Scenario: Reject quote with negative discount
    Given a customer "Customer M"
    And an item "Notebook" with quantity 1, unitary price 100 and discount -0.10
    When I try to create the quote
    Then the HTTP status should be 400


  @AC14 @Security
  Scenario: Reject malformed JSON without exposing internal server details
    When I send malformed JSON to create the quote
    Then the HTTP status should be 400
    And the response should not contain internal exception details


  @AC15 @Performance
  Scenario: Create a quote with 100 items within an acceptable response time
    Given a customer "Performance Customer"
    And 100 valid items
    When I create the quote measuring the response time
    Then the HTTP status should be 200
    And the quote should contain 100 lines
    And the response time should be less than 2000 milliseconds