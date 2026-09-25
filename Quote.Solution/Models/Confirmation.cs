// ----------------------------------------------------------------------
// <copyright file="Confirmation.cs" company="Eurofins">
//  Copyright 2024 Eurofins Scientific Ltd, Ireland
//  Usage reserved to Eurofins Global Franchise Model subscribers.
// </copyright>
// ----------------------------------------------------------------------

namespace Models
{
    /// <summary>
    /// The confirmation.
    /// </summary>
    public class Confirmation
    {
        /// <summary>
        /// Gets or sets the message.
        /// </summary>
        public string? Message { get; set; }

        /// <summary>
        /// Gets or sets the level.
        /// </summary>
        public ConfirmationLevel Level { get; set; }
    }
}
