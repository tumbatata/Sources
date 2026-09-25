using System;
using System.Diagnostics;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text;
using System.Threading.Tasks;
using Models;
using Reqnroll;

namespace QuoteAcceptanceTests.StepDefinitions
{
    [Binding]
    public class CreateQuoteSteps
    {
        private readonly CreateQuoteRequest request = new CreateQuoteRequest();
        private readonly HttpClient client = new HttpClient();

        private HttpResponseMessage? response;
        private CreateQuoteResponse? responseBody;
        private long responseTimeMilliseconds;

        [Given(@"a customer ""(.*)""")]
        public void GivenACustomer(string customer)
        {
            this.request.Customer = customer;
        }

        [Given(@"an item ""(.*)"" with quantity (.*) and unitary price (.*)")]
        public void GivenAnItem(
            string item,
            float quantity,
            decimal price)
        {
            this.request.Items.Add(
                new CreateQuoteRequestItem
                {
                    Item = item,
                    Quantity = quantity,
                    UnitaryPrice = price,
                    DiscountPercentage = 0
                });
        }

        [Given(@"an item ""(.*)"" with quantity (.*), unitary price (.*) and discount (.*)")]
        public void GivenAnItemWithDiscount(
            string item,
            float quantity,
            decimal price,
            float discount)
        {
            this.request.Items.Add(
                new CreateQuoteRequestItem
                {
                    Item = item,
                    Quantity = quantity,
                    UnitaryPrice = price,
                    DiscountPercentage = discount
                });
        }

        [Given(@"(.*) valid items")]
        public void GivenValidItems(int numberOfItems)
        {
            for (int i = 1; i <= numberOfItems; i++)
            {
                this.request.Items.Add(
                    new CreateQuoteRequestItem
                    {
                        Item = $"Item {i}",
                        Quantity = 1,
                        UnitaryPrice = 10,
                        DiscountPercentage = 0
                    });
            }
        }

        [When(@"I create the quote")]
        public async Task WhenICreateTheQuote()
        {
            Uri uri = new Uri(
                "http://localhost:59252/api/Quotes/create");

            this.response =
                await this.client.PostAsJsonAsync(uri, this.request);

            this.responseBody =
                await this.response.Content
                    .ReadFromJsonAsync<CreateQuoteResponse>();
        }

        [When(@"I try to create the quote")]
        public async Task WhenITryToCreateTheQuote()
        {
            Uri uri = new Uri(
                "http://localhost:59252/api/Quotes/create");

            this.response =
                await this.client.PostAsJsonAsync(uri, this.request);
        }

        [When(@"I send malformed JSON to create the quote")]
        public async Task WhenISendMalformedJsonToCreateTheQuote()
        {
            Uri uri = new Uri(
                "http://localhost:59252/api/Quotes/create");

            string malformedJson =
                "{ \"customer\": \"Customer Security\", \"items\": [ ";

            using StringContent content =
                new StringContent(
                    malformedJson,
                    Encoding.UTF8,
                    "application/json");

            this.response =
                await this.client.PostAsync(uri, content);
        }

        [When(@"I create the quote measuring the response time")]
        public async Task WhenICreateTheQuoteMeasuringTheResponseTime()
        {
            Uri uri = new Uri(
                "http://localhost:59252/api/Quotes/create");

            Stopwatch stopwatch =
                Stopwatch.StartNew();

            this.response =
                await this.client.PostAsJsonAsync(uri, this.request);

            stopwatch.Stop();

            this.responseTimeMilliseconds =
                stopwatch.ElapsedMilliseconds;

            Console.WriteLine(
                $"PERFORMANCE_API_RESPONSE_MS={this.responseTimeMilliseconds}");

            this.responseBody =
                await this.response.Content
                    .ReadFromJsonAsync<CreateQuoteResponse>();
        }

        [Then(@"the line price should be (.*)")]
        public void ThenTheLinePriceShouldBe(decimal total)
        {
            Assert.IsNotNull(this.responseBody);
            Assert.IsNotNull(this.responseBody.Quote);

            Assert.AreEqual(
                total,
                this.responseBody.Quote.Lines[0].LinePrice);
        }

        [Then(@"the discount amount should be (.*)")]
        public void ThenTheDiscountAmountShouldBe(
            decimal discountAmount)
        {
            Assert.IsNotNull(this.responseBody);
            Assert.IsNotNull(this.responseBody.Quote);

            Assert.AreEqual(
                discountAmount,
                this.responseBody.Quote.Lines[0].DiscountAmount);
        }

        [Then(@"the quote should contain (.*) lines")]
        public void ThenTheQuoteShouldContainLines(
            int expectedLines)
        {
            Assert.IsNotNull(this.responseBody);
            Assert.IsNotNull(this.responseBody.Quote);

            Assert.AreEqual(
                expectedLines,
                this.responseBody.Quote.Lines.Count);
        }

        [Then(@"the total price should be (.*)")]
        public void ThenTheTotalPriceShouldBe(decimal total)
        {
            Assert.IsNotNull(this.responseBody);
            Assert.IsNotNull(this.responseBody.Quote);

            Assert.AreEqual(
                total,
                this.responseBody.Quote.TotalPrice);
        }

        [Then(@"the confirmation message should be ""(.*)""")]
        public void ThenTheConfirmationMessageShouldBe(
            string expectedMessage)
        {
            Assert.IsNotNull(this.responseBody);
            Assert.IsNotNull(this.responseBody.Confirmation);

            Assert.AreEqual(
                expectedMessage,
                this.responseBody.Confirmation.Message);
        }

        [Then(@"the HTTP status should be (.*)")]
        public void ThenTheHttpStatusShouldBe(
            int expectedStatus)
        {
            Assert.IsNotNull(this.response);

            Assert.AreEqual(
                expectedStatus,
                (int)this.response.StatusCode);
        }

        [Then(@"the error response should contain ""(.*)""")]
        public async Task ThenTheErrorResponseShouldContain(
            string expectedMessage)
        {
            Assert.IsNotNull(this.response);

            string responseContent =
                await this.response.Content.ReadAsStringAsync();

            StringAssert.Contains(
                responseContent,
                expectedMessage);
        }

        [Then(@"the response should not contain internal exception details")]
        public async Task ThenTheResponseShouldNotContainInternalExceptionDetails()
        {
            Assert.IsNotNull(this.response);

            string responseContent =
                await this.response.Content.ReadAsStringAsync();

            Assert.IsFalse(
                responseContent.Contains(
                    "System.",
                    StringComparison.OrdinalIgnoreCase));

            Assert.IsFalse(
                responseContent.Contains(
                    "StackTrace",
                    StringComparison.OrdinalIgnoreCase));
        }

        [Then(@"the response time should be less than (.*) milliseconds")]
        public void ThenTheResponseTimeShouldBeLessThanMilliseconds(
            long maximumMilliseconds)
        {
            Console.WriteLine(
                $"PERFORMANCE_THRESHOLD_MS={maximumMilliseconds}");

            Assert.IsTrue(
                this.responseTimeMilliseconds < maximumMilliseconds,
                $"Expected response time to be less than {maximumMilliseconds} ms, " +
                $"but it was {this.responseTimeMilliseconds} ms.");
        }
    }
}