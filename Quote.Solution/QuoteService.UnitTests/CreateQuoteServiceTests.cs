namespace QuoteService.UnitTests
{
    using Models;

    [TestClass]
    public class CreateQuoteServiceTests
    {
        #region Properties

        private string SuccessfulMessage = "Quote created successfully.";
        private string ErrorMessage = "Cannot create the quote for a null item.";

        public CreateQuoteRequestItem item1;
        public  CreateQuoteRequestItem item2;
        public CreateQuoteRequestItem item3;
        public CreateQuoteRequest request;

        public CreateQuoteService createQuoteService;


        #endregion

        #region TestInitialise

        /// <summary>
        /// The test initialise.
        /// </summary>
        [TestInitialize]
        public void TestInitialise()
        {
            this.item1 = new CreateQuoteRequestItem { Item = "Milk", Quantity = 2f, UnitaryPrice = 0.8M };
            this.item2 = new CreateQuoteRequestItem { Item = "Cheese", Quantity = 1.5f, UnitaryPrice = 2.33M };
            this.item3 = new CreateQuoteRequestItem { Item = "Bread", Quantity = 4f, UnitaryPrice = 1.99M, DiscountPercentage = 0.75f };

            this.request = new CreateQuoteRequest
                               {
                                   Customer = "A"
                               };

            // Object to test
            this.createQuoteService = new CreateQuoteService();
        }

        #endregion


        #region Tests
        [TestMethod]
        public void CreateQuoteService_GivenACustomerWithOneItem_WhenCreateTheQuote_ThenGotTheQuoteWithDetailsAndSuccessfulConfiramtion()
        {
            // Arrange
            this.request.Items = new List<CreateQuoteRequestItem> { this.item1 };

            // Act
            var result = this.createQuoteService.CreateQuote(this.request);

            // Assert
            Assert.IsNotNull(result);
            Assert.IsTrue(result.Confirmation.Message.Equals(SuccessfulMessage, StringComparison.OrdinalIgnoreCase));
            Assert.AreEqual((decimal)2f*0.8M, result.Quote.TotalPrice);
        }

        [TestMethod]
        public void CreateQuoteService_GivenACustomerOneItemHasDiscounts_WhenCreateTheQuote_ThenGotTheQuoteWithDetailsAndSuccessfulConfiramtion()
        {
            // Arrange
            this.request.Items = new List<CreateQuoteRequestItem> { this.item3 };
            // Act
            var result = this.createQuoteService.CreateQuote(this.request);

            // Assert
            Assert.IsNotNull(result);
            Assert.IsTrue(result.Confirmation.Message.Equals(SuccessfulMessage, StringComparison.OrdinalIgnoreCase));
            Assert.AreEqual(((decimal)4f * 1.99M) - (decimal)4f * 1.99M* (decimal)0.75f, result.Quote.TotalPrice);
        }

        [TestMethod]
        public void CreateQuoteService_GivenACustomerTwoItems_WhenCreateTheQuote_ThenGotTheQuoteWith2DetailsAndSuccessfulConfiramtion()
        {
            // Arrange
            this.request.Items = new List<CreateQuoteRequestItem> { this.item2, this.item3 };
            var expectedTotalPrice = (((decimal)4f * 1.99M) - ((decimal)4f * 1.99M * (decimal)0.75f)) + (decimal)1.5f * 2.33M;

            // Act
            var result = this.createQuoteService.CreateQuote(this.request);

            // Assert
            Assert.IsNotNull(result);
            Assert.AreEqual(2, result.Quote.Lines.Count);
            Assert.IsTrue(result.Confirmation.Message.Equals(SuccessfulMessage, StringComparison.OrdinalIgnoreCase));
            Assert.AreEqual(expectedTotalPrice, result.Quote.TotalPrice);
        }

        [TestMethod]
        public void CreateQuoteService_GivenACustomerWithTwoItemsButOneIsNull_WhenCreateTheQuote_ThenGotTheQuoteWithErrorConfiramtion()
        {
            // Arrange
            this.request.Items = new List<CreateQuoteRequestItem> { this.item2, new CreateQuoteRequestItem() };

            // Act
            var result = this.createQuoteService.CreateQuote(this.request);

            // Assert
            Assert.IsNotNull(result);
            Assert.IsTrue(result.Confirmation.Message.Equals(this.ErrorMessage, StringComparison.OrdinalIgnoreCase));
        }

        #endregion
    }
}