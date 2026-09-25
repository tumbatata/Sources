// ----------------------------------------------------------------------
// <copyright file="CreateQuoteResponse.cs" company="Eurofins">
//  Copyright 2024 Eurofins Scientific Ltd, Ireland
//  Usage reserved to Eurofins Global Franchise Model subscribers.
// </copyright>
// ----------------------------------------------------------------------

namespace Models
{
    /// <summary>
    /// The create quote response.
    /// </summary>
    public class CreateQuoteResponse
    {
        /// <summary>
        /// Gets or sets the quote.
        /// </summary>
        public Quote? Quote { get; set; }

        /// <summary>
        /// Gets or sets the confirmation.
        /// </summary>
        public Confirmation? Confirmation { get; set; }
    }
}
