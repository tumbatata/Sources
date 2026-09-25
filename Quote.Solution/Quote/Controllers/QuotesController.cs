// ----------------------------------------------------------------------
// <copyright file="QuotesController.cs" company="Eurofins">
//  Copyright 2024 Eurofins Scientific Ltd, Ireland
//  Usage reserved to Eurofins Global Franchise Model subscribers.
// </copyright>
// ----------------------------------------------------------------------

namespace Quote.Controllers
{
    using Microsoft.AspNetCore.Mvc;

    using Models;

    using QuoteService;

    /// <summary>
    /// The quotes controller.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class QuotesController : ControllerBase
    {
        /// <summary>
        /// The quotes service.
        /// </summary>
        private readonly CreateQuoteService quotesService;

        /// <summary>
        /// Initializes a new instance of the <see cref="QuotesController"/> class.
        /// </summary>
        public QuotesController()
        {
            this.quotesService = new CreateQuoteService();
        }

        /// <summary>
        /// The is alive.
        /// </summary>
        /// <returns>
        /// The <see cref="IActionResult"/>.
        /// </returns>
        [HttpGet]
        [Route("isalive")]
        public IActionResult IsAlive()
        {
            return this.Ok(DateTime.Now);
        }

        /// <summary>
        /// The create quote.
        /// </summary>
        /// <param name="request">
        /// The request.
        /// </param>
        /// <returns>
        /// The <see cref="IActionResult"/>.
        /// </returns>
        [HttpPost("create")]
        public IActionResult CreateQuote([FromBody] CreateQuoteRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Customer) || request.Items.Count == 0)
            {
                string errorMessage = "Customer or Items cannot be null or empty";
                return new BadRequestObjectResult(errorMessage);
            }

            var response = this.quotesService.CreateQuote(request);
            return this.Ok(response);
        }
    }
}
