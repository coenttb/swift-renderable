//
//  AtRule mediaTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("AtRule media Tests")
struct AtRuleMediaTests {

    @Test("AtRule media basic creation")
    func atRuleBasicCreation() throws {
        let atRule = HTML.AtRule(rawValue: "screen and (max-width: 768px)")

        // Test that media query can be created
        #expect(atRule.rawValue == "screen and (max-width: 768px)")
    }

    @Test("AtRule media with different conditions")
    func atRuleWithDifferentConditions() throws {
        let mobileQuery = HTML.AtRule(rawValue: "screen and (max-width: 480px)")
        let tabletQuery = HTML.AtRule(rawValue: "screen and (min-width: 481px) and (max-width: 1024px)")
        let desktopQuery = HTML.AtRule(rawValue: "screen and (min-width: 1025px)")

        #expect(mobileQuery.rawValue.contains("max-width: 480px"))
        #expect(tabletQuery.rawValue.contains("min-width: 481px"))
        #expect(desktopQuery.rawValue.contains("min-width: 1025px"))
    }

    @Test("AtRule media with print media")
    func atRuleWithPrintMedia() throws {
        let printQuery = HTML.AtRule(rawValue: "print")

        #expect(printQuery.rawValue == "print")
    }

    @Test("AtRule media with orientation")
    func atRuleWithOrientation() throws {
        let portraitQuery = HTML.AtRule(rawValue: "screen and (orientation: portrait)")
        let landscapeQuery = HTML.AtRule(rawValue: "screen and (orientation: landscape)")

        #expect(portraitQuery.rawValue.contains("portrait"))
        #expect(landscapeQuery.rawValue.contains("landscape"))
    }

    @Test("AtRule media with device features")
    func atRuleWithDeviceFeatures() throws {
        let retinaQuery = HTML.AtRule(rawValue: "screen and (-webkit-min-device-pixel-ratio: 2)")
        let hoverQuery = HTML.AtRule(rawValue: "screen and (hover: hover)")

        #expect(retinaQuery.rawValue.contains("device-pixel-ratio"))
        #expect(hoverQuery.rawValue.contains("hover: hover"))
    }

    @Test("AtRule media equality")
    func atRuleEquality() throws {
        let query1 = HTML.AtRule(rawValue: "screen and (max-width: 768px)")
        let query2 = HTML.AtRule(rawValue: "screen and (max-width: 768px)")
        let query3 = HTML.AtRule(rawValue: "screen and (max-width: 1024px)")

        #expect(query1.rawValue == query2.rawValue)
        #expect(query1.rawValue != query3.rawValue)
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct AtRuleSnapshotTests {
        @Test("AtRule media snapshot - mobile styles")
        func atRuleMediaSnapshotMobile() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        "Mobile content"
                    }
                    .inlineStyle("color", "blue", atRule: HTML.AtRule(rawValue: "@media (max-width: 768px)"))
                    .inlineStyle(
                        "font-size",
                        "14px",
                        atRule: HTML.AtRule(rawValue: "@media (max-width: 768px)")
                    )
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>
                      @media (max-width: 768px){
                        .color-0{color:blue}
                        .font-size-1{font-size:14px}
                      }
                    </style>
                  </head>
                  <body>
                    <div class="color-0 font-size-1">Mobile content
                    </div>
                  </body>
                </html>
                """
            }
        }

        @Test("AtRule media snapshot - print styles")
        func atRuleMediaSnapshotPrint() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        "Print content"
                    }
                    .inlineStyle("display", "none", atRule: HTML.AtRule(rawValue: "@media print"))
                    .inlineStyle("color", "black", atRule: HTML.AtRule(rawValue: "@media print"))
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>
                      @media print{
                        .display-0{display:none}
                        .color-1{color:black}
                      }
                    </style>
                  </head>
                  <body>
                    <div class="display-0 color-1">Print content
                    </div>
                  </body>
                </html>
                """
            }
        }

        @Test("AtRule media snapshot - mixed media queries")
        func atRuleMediaSnapshotMixed() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        tag("h1") { "Responsive Title" }
                            .inlineStyle(
                                "font-size",
                                "24px",
                                atRule: HTML.AtRule(rawValue: "@media (min-width: 768px)")
                            )
                            .inlineStyle(
                                "font-size",
                                "18px",
                                atRule: HTML.AtRule(rawValue: "@media (max-width: 767px)")
                            )

                        tag("p") { "This paragraph adapts to different screen sizes" }
                            .inlineStyle(
                                "margin",
                                "1rem",
                                atRule: HTML.AtRule(rawValue: "@media (min-width: 768px)")
                            )
                            .inlineStyle(
                                "margin",
                                "0.5rem",
                                atRule: HTML.AtRule(rawValue: "@media (max-width: 767px)")
                            )
                            .inlineStyle("display", "none", atRule: HTML.AtRule(rawValue: "@media print"))
                    }
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>
                      @media (min-width: 768px){
                        .font-size-0{font-size:24px}
                        .margin-2{margin:1rem}
                      }
                      @media (max-width: 767px){
                        .font-size-1{font-size:18px}
                        .margin-3{margin:0.5rem}
                      }
                      @media print{
                        .display-4{display:none}
                      }
                    </style>
                  </head>
                  <body>
                    <div>
                      <h1 class="font-size-0 font-size-1">Responsive Title
                      </h1>
                      <p class="margin-2 margin-3 display-4">This paragraph adapts to different screen sizes
                      </p>
                    </div>
                  </body>
                </html>
                """
            }
        }

        @Test("AtRule media snapshot - no media query")
        func atRuleMediaSnapshotNoMedia() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        "Regular content without media queries"
                    }
                    .inlineStyle("color", "red")
                    .inlineStyle("padding", "1rem")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>
                      .color-0{color:red}
                      .padding-1{padding:1rem}
                    </style>
                  </head>
                  <body>
                    <div class="color-0 padding-1">Regular content without media queries
                    </div>
                  </body>
                </html>
                """
            }
        }
    }
}

enum AtRule2 {
    case rule(String)
    indirect case nested(String, AtRule2)
}
