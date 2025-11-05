//
//  AtRule mediaTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite(
    "AtRule media Tests",
    .snapshots(record: .failed)
)
struct AtRuleTests {

    @Test("AtRule media basic creation")
    func atRuleBasicCreation() throws {
        let atRule = AtRule(rawValue: "screen and (max-width: 768px)")

        // Test that media query can be created
        #expect(atRule.rawValue == "screen and (max-width: 768px)")
    }

    @Test("AtRule media with different conditions")
    func atRuleWithDifferentConditions() throws {
        let mobileQuery = AtRule(rawValue: "screen and (max-width: 480px)")
        let tabletQuery = AtRule(rawValue: "screen and (min-width: 481px) and (max-width: 1024px)")
        let desktopQuery = AtRule(rawValue: "screen and (min-width: 1025px)")

        #expect(mobileQuery.rawValue.contains("max-width: 480px"))
        #expect(tabletQuery.rawValue.contains("min-width: 481px"))
        #expect(desktopQuery.rawValue.contains("min-width: 1025px"))
    }

    @Test("AtRule media with print media")
    func atRuleWithPrintMedia() throws {
        let printQuery = AtRule(rawValue: "print")

        #expect(printQuery.rawValue == "print")
    }

    @Test("AtRule media with orientation")
    func atRuleWithOrientation() throws {
        let portraitQuery = AtRule(rawValue: "screen and (orientation: portrait)")
        let landscapeQuery = AtRule(rawValue: "screen and (orientation: landscape)")

        #expect(portraitQuery.rawValue.contains("portrait"))
        #expect(landscapeQuery.rawValue.contains("landscape"))
    }

    @Test("AtRule media with device features")
    func atRuleWithDeviceFeatures() throws {
        let retinaQuery = AtRule(rawValue: "screen and (-webkit-min-device-pixel-ratio: 2)")
        let hoverQuery = AtRule(rawValue: "screen and (hover: hover)")

        #expect(retinaQuery.rawValue.contains("device-pixel-ratio"))
        #expect(hoverQuery.rawValue.contains("hover: hover"))
    }

    @Test("AtRule media equality")
    func atRuleEquality() throws {
        let query1 = AtRule(rawValue: "screen and (max-width: 768px)")
        let query2 = AtRule(rawValue: "screen and (max-width: 768px)")
        let query3 = AtRule(rawValue: "screen and (max-width: 1024px)")

        #expect(query1.rawValue == query2.rawValue)
        #expect(query1.rawValue != query3.rawValue)
    }

    @Test("AtRule media snapshot - mobile styles")
    func atRuleMediaSnapshotMobile() {
        assertInlineSnapshot(
            of: HTMLDocument {
                tag("div") {
                    "Mobile content"
                }
                .inlineStyle("color", "blue", atRule: AtRule(rawValue: "@media (max-width: 768px)"))
                .inlineStyle(
                    "font-size",
                    "14px",
                    atRule: AtRule(rawValue: "@media (max-width: 768px)")
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
              .color-IFTUA{color:blue}
              .font-size-gu1YL{font-size:14px}
            }

                </style>
              </head>
              <body>
            <div class="color-IFTUA font-size-gu1YL">Mobile content
            </div>
              </body>
            </html>
            """
        }
    }

    @Test("AtRule media snapshot - print styles")
    func atRuleMediaSnapshotPrint() {
        assertInlineSnapshot(
            of: HTMLDocument {
                tag("div") {
                    "Print content"
                }
                .inlineStyle("display", "none", atRule: AtRule(rawValue: "@media print"))
                .inlineStyle("color", "black", atRule: AtRule(rawValue: "@media print"))
            },
            as: .html
        ) {
            """
            <!doctype html>
            <html>
              <head>
                <style>
            @media print{
              .display-D5ekn{display:none}
              .color-JZgIp4{color:black}
            }

                </style>
              </head>
              <body>
            <div class="display-D5ekn color-JZgIp4">Print content
            </div>
              </body>
            </html>
            """
        }
    }

    @Test("AtRule media snapshot - mixed media queries")
    func atRuleMediaSnapshotMixed() {
        assertInlineSnapshot(
            of: HTMLDocument {
                tag("div") {
                    tag("h1") { "Responsive Title" }
                        .inlineStyle(
                            "font-size",
                            "24px",
                            atRule: AtRule(rawValue: "@media (min-width: 768px)")
                        )
                        .inlineStyle(
                            "font-size",
                            "18px",
                            atRule: AtRule(rawValue: "@media (max-width: 767px)")
                        )

                    tag("p") { "This paragraph adapts to different screen sizes" }
                        .inlineStyle(
                            "margin",
                            "1rem",
                            atRule: AtRule(rawValue: "@media (min-width: 768px)")
                        )
                        .inlineStyle(
                            "margin",
                            "0.5rem",
                            atRule: AtRule(rawValue: "@media (max-width: 767px)")
                        )
                        .inlineStyle("display", "none", atRule: AtRule(rawValue: "@media print"))
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
              .font-size-brRBu{font-size:24px}
              .margin-aLmST1{margin:1rem}
            }
            @media (max-width: 767px){
              .font-size-kN7yq1{font-size:18px}
              .margin-VpBjc3{margin:0.5rem}
            }
            @media print{
              .display-D5ekn{display:none}
            }

                </style>
              </head>
              <body>
            <div>
              <h1 class="font-size-brRBu font-size-kN7yq1">Responsive Title
              </h1>
              <p class="margin-aLmST1 margin-VpBjc3 display-D5ekn">This paragraph adapts to different screen sizes
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
            of: HTMLDocument {
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
            .color-dMYaj4{color:red}
            .padding-dnNPN1{padding:1rem}

                </style>
              </head>
              <body>
            <div class="color-dMYaj4 padding-dnNPN1">Regular content without media queries
            </div>
              </body>
            </html>
            """
        }
    }
}

enum AtRule2 {
    case rule(String)
    indirect case nested(String, AtRule2)
}
