// ----------------------------------------------------------------------
// <copyright file="CreateQuoteRequestItem.cs" company="Eurofins">
//  Copyright 2024 Eurofins Scientific Ltd, Ireland
//  Usage reserved to Eurofins Global Franchise Model subscribers.
// </copyright>
// ----------------------------------------------------------------------

namespace Models
{
    /// <summary>
    /// The create quote request item.
    /// </summary>
    public class CreateQuoteRequestItem
    {
        /// <summary>
        /// Gets or sets the item.
        /// </summary>
        public string? Item { get; set; }

        /// <summary>
        /// Gets or sets the quantity.
        /// </summary>
        public float Quantity { get; set; }

        /// <summary>
        /// Gets or sets the unitary price.
        /// </summary>
        public decimal UnitaryPrice { get; set; }

        /// <summary>
        /// Gets or sets the discount percentage.
        /// </summary>
        public float DiscountPercentage { get; set; }
    }
}
