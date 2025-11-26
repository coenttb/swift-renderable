//
//  _HTMLAttributes Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `_HTMLAttributes Tests` {
    
    @Test
    func `Single attribute`() throws {
        let element = tag("div") {
            HTML.Text("content")
        }.attribute("class", "test-class")
        
        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("class=\"test-class\""))
        #expect(rendered.contains("content"))
    }
    
    @Test
    func `Multiple attributes`() throws {
        let element = tag("div") {
            HTML.Text("content")
        }
            .attribute("class", "test-class")
            .attribute("id", "test-id")
        
        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("class=\"test-class\""))
        #expect(rendered.contains("id=\"test-id\""))
    }
    
    @Test
    func `Nil attribute value omits attribute`() throws {
        let element = tag("div") {
            HTML.Text("content")
        }.attribute("class", nil)
        
        let rendered = try String(HTML.Document { element })
        #expect(!rendered.contains("class="))
    }
    
    @Test
    func `Empty string attribute value`() throws {
        let element = tag("div") {
            HTML.Text("content")
        }.attribute("hidden", "")
        
        let rendered = try String(element)
        #expect(rendered.contains("hidden"))
    }
    
    @Test
    func `Attribute chaining`() throws {
        let element = tag("input")
            .attribute("type", "text")
            .attribute("name", "username")
            .attribute("placeholder", "Enter username")
            .attribute("required", "")
        
        let rendered = try String(HTML.Document { element })
        
        print("rendered", rendered)
        #expect(rendered.contains("type=\"text\""))
        #expect(rendered.contains("name=\"username\""))
        #expect(rendered.contains("placeholder=\"Enter username\""))
        #expect(rendered.contains("required"))
    }
}

extension `Snapshot Tests` {
    @Suite
    struct AttributeTests {
        
        // MARK: - Snapshot Tests
        @Test
        func `Form with various attributes snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("form") {
                        tag("div") {
                            tag("label") {
                                HTML.Text("Name:")
                            }
                            .attribute("for", "name")

                            tag("input")
                                .attribute("type", "text")
                                .attribute("id", "name")
                                .attribute("name", "name")
                                .attribute("placeholder", "Enter your name")
                                .attribute("required", "")
                        }
                        .attribute("class", "form-group")

                        tag("div") {
                            tag("label") {
                                HTML.Text("Email:")
                            }
                            .attribute("for", "email")

                            tag("input")
                                .attribute("type", "email")
                                .attribute("id", "email")
                                .attribute("name", "email")
                                .attribute("placeholder", "Enter your email")
                                .attribute("required", "")
                        }
                        .attribute("class", "form-group")

                        tag("button") {
                            HTML.Text("Submit")
                        }
                        .attribute("type", "submit")
                        .attribute("class", "btn-primary")
                    }
                    .attribute("method", "post")
                    .attribute("action", "/submit")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <form method="post" action="/submit">
                      <div class="form-group"><label for="name">Name:</label><input type="text" id="name" name="name" placeholder="Enter your name" required>
                      </div>
                      <div class="form-group"><label for="email">Email:</label><input type="email" id="email" name="email" placeholder="Enter your email" required>
                      </div><button type="submit" class="btn-primary">Submit</button>
                    </form>
                  </body>
                </html>
                """
            }
        }

        @Test
        func `Media attributes snapshot`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        tag("img")
                            .attribute("src", "/images/hero.jpg")
                            .attribute("alt", "Hero image")
                            .attribute("width", "800")
                            .attribute("height", "600")
                            .attribute("loading", "lazy")

                        tag("video") {
                            tag("source")
                                .attribute("src", "/videos/demo.mp4")
                                .attribute("type", "video/mp4")
                            HTML.Text("Your browser does not support the video tag.")
                        }
                        .attribute("controls", "")
                        .attribute("width", "640")
                        .attribute("height", "480")
                        .attribute("poster", "/images/video-poster.jpg")
                    }
                    .attribute("class", "media-container")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                  </head>
                  <body>
                    <div class="media-container"><img src="/images/hero.jpg" alt="Hero image" width="800" height="600" loading="lazy">
                      <video controls width="640" height="480" poster="/images/video-poster.jpg">
                        <source src="/videos/demo.mp4" type="video/mp4">Your browser does not support the video tag.
                      </video>
                    </div>
                  </body>
                </html>
                """
            }
        }
    }
}
