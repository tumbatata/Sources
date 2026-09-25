// ----------------------------------------------------------------------
// <copyright file="Quote.cs" company="Eurofins">
//  Copyright 2024 Eurofins Scientific Ltd, Ireland
//  Usage reserved to Eurofins Global Franchise Model subscribers.
// </copyright>
// ----------------------------------------------------------------------

namespace Models
{
    /// <summary>
    /// The quote.
    /// </summary>
    public class Quote
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="Quote"/> class.
        /// </summary>
        public Quote()
        {
            this.Lines = new List<QuoteLine>();
        }

        /// <summary>
        /// Gets or sets the id.
        /// </summary>
        public Guid ID { get; set; }

        /// <summary>
        /// Gets or sets the customer.
        /// </summary>
        public string? Customer { get; set; }

        /// <summary>
        /// Gets or sets the revision.
        /// </summary>
        public int Revision { get; set; } = 1; // Default value of 1

        /// <summary>
        /// Gets or sets the total price.
        /// </summary>
        public decimal TotalPrice { get; set; }

        /// <summary>
        /// Gets or sets the lines.
        /// </summary>
        public IList<QuoteLine> Lines { get; set; }

        /// <summary>
        /// Gets or sets the status.
        /// </summary>
        public QuoteStatus Status { get; set; }
    }
}
