// ----------------------------------------------------------------------
// <copyright file="CreateQuoteRequest.cs" company="Eurofins">
//  Copyright 2024 Eurofins Scientific Ltd, Ireland
//  Usage reserved to Eurofins Global Franchise Model subscribers.
// </copyright>
// ----------------------------------------------------------------------

namespace Models
{
    /// <summary>
    /// The create quote request.
    /// </summary>
    public class CreateQuoteRequest
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="CreateQuoteRequest"/> class.
        /// </summary>
        public CreateQuoteRequest()
        {
            this.Items = new List<CreateQuoteRequestItem>();
        }

        /// <summary>
        /// Gets or sets the customer.
        /// </summary>
        public string? Customer { get; set; }

        /// <summary>
        /// Gets or sets the items.
        /// </summary>
        public IList<CreateQuoteRequestItem> Items { get; set; }
    }
}
