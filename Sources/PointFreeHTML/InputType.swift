//
//  InputType.swift
//
//
//  Created by Coen ten Thije Boonkkamp
//

import Foundation

/// Represents the possible types for HTML input elements.
///
/// `InputType` encapsulates all standard HTML input types as defined
/// in the HTML specification. Using this enum ensures type safety when
/// specifying input types in your HTML.
///
/// Example:
/// ```swift
/// input()
///     .attribute("type", InputType.email.rawValue)
///     .attribute("placeholder", "Enter your email")
/// ```
///
/// - Note: These values correspond directly to the values used in the
///   `type` attribute of HTML input elements.
public enum InputType: String {
    /// A single-line text input field.
    case text
    
    /// An input field for email addresses.
    case email
    
    /// A password input field that masks the characters.
    case password
    
    /// An input field for numerical values.
    case number
    
    /// An input field for telephone numbers.
    case tel
    
    /// An input field for URLs.
    case url
    
    /// A checkbox input for selecting options.
    case checkbox
    
    /// A radio button input for selecting one option from a group.
    case radio
    
    /// An input field for entering a date.
    case date
    
    /// An input field for entering a time.
    case time
    
    /// An input field for entering both date and time.
    case datetimeLocal = "datetime-local"
    
    /// An input field for entering a month and year.
    case month
    
    /// An input field for entering a week and year.
    case week
    
    /// A color picker input.
    case color
    
    /// A file upload input.
    case file
    
    /// A hidden input that is not displayed to the user.
    case hidden
    
    /// An input that allows an image to be submitted.
    case image
    
    /// A slider control for selecting a numeric value within a range.
    case range
    
    /// A button that resets the form to its initial values.
    case reset
    
    /// A search input field.
    case search
    
    /// A button that submits the form.
    case submit
    
    /// A clickable button with no default behavior.
    case button
}
