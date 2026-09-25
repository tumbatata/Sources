// ----------------------------------------------------------------------
// <copyright file="IsAliveSteps.cs" company="Eurofins">
//  Copyright 2024 Eurofins Scientific Ltd, Ireland
//  Usage reserved to Eurofins Global Franchise Model subscribers.
// </copyright>
// ----------------------------------------------------------------------

namespace QuoteAcceptanceTests.StepDefinitions
{
    using System.Net;

    using Reqnroll;

    /// <summary>
    /// The is alive steps.
    /// </summary>
    [Binding, Scope(Tag = "IsAlive")]
    internal class IsAliveSteps
    {
        /// <summary>
        /// The response.
        /// </summary>
        private HttpResponseMessage? response;

        /// <summary>
        /// The client.
        /// </summary>
        private HttpClient client = new HttpClient();

        #region Given
        [Given(@"the Quote Service Running")]
        public void GivenTheQuoteServiceRunning()
        {

        }

        #endregion

        #region When

        /// <summary>
        /// The when i call is alive.
        /// </summary>
        /// <returns>
        /// The <see cref="Task"/>.
        /// </returns>
        [When(@"I check if it is alive")]
        public async Task WhenICallIsAlive()
        {
            Uri uri = new Uri("http://localhost:59252/api/Quotes/isalive");

            this.response = await this.client.GetAsync(uri);
        }

        #endregion

        #region Then

        /// <summary>
        /// The then it returns ok.
        /// </summary>
        /// <param name="a">
        /// The a.
        /// </param>
        [Then(@"it returns OK \(http {int}\)")]
        public void ThenItReturnsOk(int a)
        {
            var httpResponseMessage = this.response;
            if (httpResponseMessage != null)
            {
                Assert.AreEqual(HttpStatusCode.OK, httpResponseMessage.StatusCode);
                Assert.AreEqual(a, (int)httpResponseMessage.StatusCode);
            }
        }

        #endregion
    }
}
