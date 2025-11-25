//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import INCITS_4_1986

extension HTMLPrinter {
    
    /// Configuration options for HTML rendering.
    ///
    /// This struct provides options to control how HTML is rendered,
    /// including pretty-printing options and special handling for
    /// specific contexts like email.
    public struct Configuration: Sendable {
        /// Whether to add `!important` to all CSS rules.
        package let forceImportant: Bool
        
        /// The bytes to use for indentation.
        ///
        /// Stored as bytes to avoid UTF-8 conversion overhead during rendering.
        package let indentation: [UInt8]
        
        /// The bytes to use for newlines.
        ///
        /// Stored as bytes to avoid UTF-8 conversion overhead during rendering.
        package let newline: [UInt8]
        
        /// Reserved capacity for the byte buffer (in bytes).
        ///
        /// Pre-allocating capacity avoids multiple reallocations during rendering.
        /// Set to 0 for no reservation (default), or estimate your typical document size.
        ///
        /// ## Typical Sizes
        /// - Small documents (< 1KB): 512 bytes
        /// - Medium documents (1-10KB): 4096 bytes
        /// - Large documents (> 10KB): 16384 bytes
        package let reservedCapacity: Int
        
        /// Default configuration with no indentation or newlines.
        ///
        /// Pre-allocates 1KB to handle most simple documents without reallocation.
        public static let `default` = Self(forceImportant: false, indentation: [], newline: [], reservedCapacity: 1024)
        
        /// Pretty-printing configuration with 2-space indentation and newlines.
        ///
        /// Pre-allocates 2KB to accommodate additional whitespace from formatting.
        public static let pretty = Self(
            forceImportant: false,
            indentation: [UInt8.ascii.space, UInt8.ascii.space],
            newline: [UInt8.ascii.lf],
            reservedCapacity: 2048
        )
        
        /// Configuration optimized for email HTML with forced important styles.
        ///
        /// Pre-allocates 2KB as email HTML tends to be verbose with inline styles.
        public static let email = Self(
            forceImportant: true,
            indentation: [UInt8.ascii.space],
            newline: [UInt8.ascii.lf],
            reservedCapacity: 2048
        )
        
        /// Performance-optimized configuration for typical documents (~4KB).
        ///
        /// Pre-allocates 4096 bytes to avoid reallocations for most documents.
        /// Use this when rendering performance is critical.
        public static let optimized = Self(forceImportant: false, indentation: [], newline: [], reservedCapacity: 4096)
    }
}




