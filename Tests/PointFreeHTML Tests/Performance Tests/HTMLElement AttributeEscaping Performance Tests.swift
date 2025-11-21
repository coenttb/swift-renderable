//
//  HTMLElement AttributeEscaping PerformanceTests.swift
//  pointfree-html
//
//  Performance tests for HTML attribute value escaping optimization.
//

import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing
import TestingPerformance

extension `Performance Tests` {
    @Suite
    struct `HTMLElement AttributeEscaping` {
        
        // MARK: - Fast Path Tests (No Escaping Needed)
        
        @Test(.timed(threshold: .seconds(4)))
        func `fast path - simple attributes 10K renders`() {
            for _ in 0..<10_000 {
                _ = try! String(
                    HTMLDocument {
                        tag("div")
                            .attribute("id", "simple-id")
                            .attribute("class", "container")
                            .attribute("data-value", "12345")
                    }
                )
            }
        }
        
        @Test(.timed(threshold: .milliseconds(400)))
        func `fast path - many simple attributes 1K renders`() {
            for _ in 0..<1_000 {
                _ = try! String(
                    HTMLDocument {
                        tag("input")
                            .attribute("type", "text")
                            .attribute("name", "username")
                            .attribute("id", "user-input")
                            .attribute("placeholder", "Enter name")
                            .attribute("class", "form-control")
                            .attribute("data-testid", "username-field")
                    }
                )
            }
        }
        
        @Test(.timed(threshold: .milliseconds(600)))
        func `fast path - large document simple attributes`() {
            for _ in 0..<100 {
                _ = try! String(
                    HTMLDocument {
                        tag("div") {
                            for i in 0..<100 {
                                tag("div")
                                    .attribute("id", "item-\(i)")
                                    .attribute("class", "list-item")
                                    .attribute("data-index", String(i))
                            }
                        }
                    }
                )
            }
        }
        
        // MARK: - Slow Path Tests (Escaping Required)
        
        @Test(.timed(threshold: .seconds(3)))
        func `slow path - attributes with quotes 10K renders`() {
            for _ in 0..<10_000 {
                _ = try! String(
                    HTMLDocument {
                        tag("div")
                            .attribute("data-message", "He said \"Hello\"")
                            .attribute("data-alt", "It's working")
                    }
                )
            }
        }
        
        @Test(.timed(threshold: .seconds(4)))
        func `slow path - attributes with HTML entities 10K renders`() {
            for _ in 0..<10_000 {
                _ = try! String(
                    HTMLDocument {
                        tag("a")
                            .attribute("href", "/search?q=foo&bar=baz")
                            .attribute("title", "x < 10 && y > 5")
                    }
                )
            }
        }
        
        @Test(.timed(threshold: .milliseconds(1800)))
        func `slow path - complex escaping 5K renders`() {
            for _ in 0..<5_000 {
                _ = try! String(
                    HTMLDocument {
                        tag("div")
                            .attribute("data-complex", "<tag attr=\"value\" & 'quotes'>")
                            .attribute("data-json", "{\"key\": \"value & more\"}")
                    }
                )
            }
        }
        
        // MARK: - Mixed Workload Tests
        
        @Test(.timed(threshold: .milliseconds(3500)))
        func `mixed - 80 percent fast path 20 percent slow path`() {
            for i in 0..<10_000 {
                if i % 5 < 4 {
                    // Fast path: 80% of operations
                    _ = try! String(
                        HTMLDocument {
                            tag("div")
                                .attribute("id", "simple-id")
                                .attribute("class", "container")
                        }
                    )
                } else {
                    // Slow path: 20% of operations
                    _ = try! String(
                        HTMLDocument {
                            tag("div")
                                .attribute("data-message", "He said \"Hello\"")
                        }
                    )
                }
            }
        }
        
        // MARK: - Baseline Comparison Tests

        @Test(.timed(threshold: .seconds(4)))
        func `baseline - element without attributes 10K renders`() {
            for _ in 0..<10_000 {
                _ = try! String(
                    HTMLDocument {
                        tag("div") {
                            tag("p") { "Hello World" }
                        }
                    }
                )
            }
        }
        
        @Test(.timed(threshold: .milliseconds(3500)))
        func `baseline - empty element with single attribute 10K renders`() {
            for _ in 0..<10_000 {
                _ = try! String(
                    HTMLDocument {
                        tag("div").attribute("id", "test")
                    }
                )
            }
        }
        
        // MARK: - Real-World Scenario Tests
        
        @Test(.timed(threshold: .milliseconds(600)))
        func `real-world - form with mixed attributes 1K renders`() {
            for _ in 0..<1_000 {
                _ = try! String(
                    HTMLDocument {
                        tag("form") {
                            tag("input")
                                .attribute("type", "text")
                                .attribute("name", "email")
                                .attribute("placeholder", "user@example.com")
                                .attribute("pattern", "[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,}$")
                            
                            tag("input")
                                .attribute("type", "password")
                                .attribute("name", "password")
                                .attribute("placeholder", "Enter password")
                            
                            tag("button")
                                .attribute("type", "submit")
                                .attribute("onclick", "return validate() && confirm('Submit?')")
                        }
                    }
                )
            }
        }
        
        @Test(.timed(threshold: .seconds(1)))
        func `real-world - data table with URLs 500 renders`() {
            for _ in 0..<500 {
                _ = try! String(
                    HTMLDocument {
                        tag("table") {
                            for i in 0..<50 {
                                tag("tr") {
                                    tag("td") { "Item \(i)" }
                                    tag("td") {
                                        tag("a")
                                            .attribute("href", "/item?id=\(i)&ref=table")
                                            .attribute("title", "View item #\(i)")
                                    }
                                }
                            }
                        }
                    }
                )
            }
        }
    }
}
