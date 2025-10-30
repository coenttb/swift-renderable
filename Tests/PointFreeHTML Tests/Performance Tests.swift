//
//  Performance Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import Dependencies
import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
  import Darwin
#endif

@Suite(
  "Performance Tests",
  .serialized,
  .snapshots(record: .missing),
  .disabled()
)
struct PerformanceTests {

  // MARK: - Large Document Rendering Tests

  @Test("Large Document Rendering - 1M items")
  func largeDocumentRendering() throws {
    let itemCount = 1_000_000
    let items = Array(1...itemCount)

    let clock = ContinuousClock()
    let result = clock.measure {
      let document = HTMLDocument {
        tag("div") {
          for item in items {
            tag("p") { "Item \(item)" }
          }
        }
      }
      _ = try! String(document)
    }

    print("📊 PERFORMANCE DATA - Large Document (\(itemCount) items):")
    print("   Time: \(result)")
    print(
      "   Time (seconds): \(Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18)"
    )
    print(
      "   Items per second: \(Double(itemCount) / (Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18))"
    )

    // Performance assertion - should complete within reasonable time
    #expect(result < .seconds(1.5), "Large document should render within 1.5 seconds")
  }

  @Test("Moderate Document Rendering - 100K items")
  func moderateDocumentRendering() throws {
    let itemCount = 100_000
    let items = Array(1...itemCount)

    let clock = ContinuousClock()
    let result = clock.measure {
      let document = HTMLDocument {
        tag("div") {
          for item in items {
            tag("p") { "Item \(item)" }
          }
        }
      } head: {
        tag("title") { "Performance Test" }
        tag("meta").attribute("charset", "utf-8")
      }
      _ = try! String(document)
    }

    print("📊 PERFORMANCE DATA - Moderate Document (\(itemCount) items):")
    print("   Time: \(result)")
    print(
      "   Time (seconds): \(Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18)"
    )
    print(
      "   Items per second: \(Double(itemCount) / (Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18))"
    )

    // Should be much faster for moderate size
    #expect(result < .milliseconds(150), "Moderate document should render within 1 second")
  }

  // MARK: - Style Deduplication Performance

  @Test("Style Deduplication - 10K identical styles")
  func styleDeduplicationPerformance() throws {
    let itemCount = 10_000

    let clock = ContinuousClock()
    print("📊 PERFORMANCE DATA - Style Deduplication (\(itemCount) elements):")

    let result = clock.measure {
      let document = HTMLDocument {
        tag("div") {
          for i in 1...itemCount {
            tag("span") { "Item \(i)" }
              .inlineStyle("color", "red")
              .inlineStyle("font-size", "14px")
              .inlineStyle("font-weight", "bold")
          }
        }
      }
      let htmlString = try! String(document)

      // Verify deduplication worked - should have minimal CSS rules
      let cssRuleCount = htmlString.components(separatedBy: "{").count - 1
      let htmlSize = htmlString.utf8.count

      print("   CSS rules generated: \(cssRuleCount)")
      print("   HTML size: \(htmlSize) bytes (\(htmlSize / 1024)KB)")
      print("   Deduplication efficiency: \(cssRuleCount) rules for \(itemCount) styled elements")

      #expect(cssRuleCount < 10, "Should generate very few CSS rules due to deduplication")
    }

    print(
      "   Time (seconds): \(Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18)"
    )
    print(
      "   Elements per second: \(Double(itemCount) / (Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18))"
    )
    print("   Time: \(result)")

    #expect(result < .seconds(3), "Style deduplication should be fast")
  }

  @Test("Mixed Styles Performance - 1K unique styles")
  func mixedStylesPerformance() throws {
    let itemCount = 1_000
    let colors = ["red", "blue", "green", "yellow", "purple", "orange", "pink", "brown"]
    let sizes = ["12px", "14px", "16px", "18px", "20px"]

    let clock = ContinuousClock()
    let result = clock.measure {
      let document = HTMLDocument {
        tag("div") {
          for i in 0..<itemCount {
            tag("div") { "Item \(i)" }
              .inlineStyle("color", colors[i % colors.count])
              .inlineStyle("font-size", sizes[i % sizes.count])
              .inlineStyle("margin", "\(i % 10)px")
          }
        }
      }
      _ = try! String(document)
    }

    let timeInSeconds =
      Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
    print("📊 PERFORMANCE DATA - Mixed Styles (\(itemCount) elements):")
    print("   Time: \(result)")
    print("   Time (seconds): \(timeInSeconds)")
    print("   Elements per second: \(Double(itemCount) / timeInSeconds)")
    print("   Unique color combinations: \(colors.count)")
    print("   Unique size combinations: \(sizes.count)")

    #expect(result < .milliseconds(300), "Mixed styles should render quickly")
  }

  // MARK: - Memory Usage Tests

  @Test("Memory Efficient Rendering")
  func memoryEfficientRendering() throws {
    let itemCount = 100_000

    // Measure memory before
    let initialMemory = getMemoryUsage()

    let clock = ContinuousClock()
    let result = clock.measure {
      let document = HTMLDocument {
        tag("div") {
          for i in 1...itemCount {
            tag("p") { "Memory test item \(i)" }
              .inlineStyle("padding", "4px")
          }
        }
      }
      _ = try! String(document)
    }

    // Measure memory after
    let finalMemory = getMemoryUsage()
    let memoryIncrease = finalMemory - initialMemory
    let timeInSeconds =
      Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18

    print("📊 PERFORMANCE DATA - Memory Efficient Rendering (\(itemCount) items):")
    print("   Time: \(result)")
    print("   Time (seconds): \(timeInSeconds)")
    print("   Elements per second: \(Double(itemCount) / timeInSeconds)")
    print("   Initial memory: \(initialMemory / 1024 / 1024)MB")
    print("   Final memory: \(finalMemory / 1024 / 1024)MB")
    print("   Memory increase: \(memoryIncrease / 1024 / 1024)MB")
    print("   Memory per item: \(Double(memoryIncrease) / Double(itemCount)) bytes")

    // Memory should be reasonable (less than 500MB for 100K items)
    #expect(memoryIncrease < 500_000_000, "Memory usage should be reasonable")
    // Time should be reasonable for memory measurement test
    #expect(result < .seconds(12), "Memory test should complete within reasonable time")
  }

  // MARK: - Nested Structure Performance

  @Test("Deep Nesting Performance")
  func deepNestingPerformance() throws {
    let depth = 100  // Reduced from 1000 to avoid stack overflow

    func createNestedStructure(depth: Int) -> AnyHTML {
      if depth <= 0 {
        return AnyHTML(tag("p") { "End of nesting" })
      } else {
        return AnyHTML(
          tag("div") {
            tag("h3") { "Level \(depth)" }
            createNestedStructure(depth: depth - 1)
          }
        )
      }
    }

    let clock = ContinuousClock()
    let result = clock.measure {
      let document = HTMLDocument {
        createNestedStructure(depth: depth)
      }
      _ = try! String(document)
    }

    let timeInSeconds =
      Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
    print("📊 PERFORMANCE DATA - Deep Nesting (\(depth) levels):")
    print("   Time: \(result)")
    print("   Time (seconds): \(timeInSeconds)")
    print("   Levels per second: \(Double(depth) / timeInSeconds)")
    print("   Average time per level: \(timeInSeconds / Double(depth) * 1000)ms")
    print("   Total elements: \(depth + 1)")  // h3 at each level + final p

    #expect(result < .seconds(0.02), "Deep nesting should handle efficiently")
  }

  @Test("Wide Structure Performance")
  func wideStructurePerformance() throws {
    let width = 10_000

    let clock = ContinuousClock()
    let result = clock.measure {
      let document = HTMLDocument {
        tag("div") {
          for i in 1...width {
            tag("div") {
              tag("span") { "Column \(i)" }
              tag("span") { "Value \(i * 2)" }
              tag("span") { "Status: Active" }
            }
            .attribute("class", "row")
          }
        }
        .attribute("class", "grid")
      }
      _ = try! String(document)
    }

    let timeInSeconds =
      Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
    print("📊 PERFORMANCE DATA - Wide Structure (\(width) elements):")
    print("   Time: \(result)")
    print("   Time (seconds): \(timeInSeconds)")
    print("   Elements per second: \(Double(width * 3) / timeInSeconds)")  // 3 spans per div
    print("   Total elements rendered: \(width * 4)")  // 1 div + 3 spans per iteration

    #expect(result < .seconds(1), "Wide structures should render very efficiently")
  }

  // MARK: - Configuration Performance Comparison

  @Test("Compact vs Pretty Configuration Performance")
  func configurationPerformanceComparison() throws {
    let itemCount = 50_000

    let document = HTMLDocument {
      tag("div") {
        for i in 1...itemCount {
          tag("div") {
            tag("h3") { "Item \(i)" }
            tag("p") { "Description for item \(i)" }
            tag("span") { "Status: Active" }
          }
          .attribute("class", "item")
        }
      }
      .attribute("class", "container")
    } head: {
      tag("title") { "Performance Test" }
    }

    // Test compact configuration
    let compactResult = ContinuousClock().measure {
      withDependencies {
        $0.htmlPrinter = .init()
      } operation: {
        _ = try! String(document)
      }
    }

    // Test pretty configuration
    let prettyResult = ContinuousClock().measure {
      withDependencies {
        $0.htmlPrinter = .init(.pretty)
      } operation: {
        _ = try! String(document)
      }
    }

    let compactTimeInSeconds =
      Double(compactResult.components.seconds) + Double(compactResult.components.attoseconds) / 1e18
    let prettyTimeInSeconds =
      Double(prettyResult.components.seconds) + Double(prettyResult.components.attoseconds) / 1e18
    let slowdownFactor = prettyTimeInSeconds / compactTimeInSeconds

    print("📊 PERFORMANCE DATA - Configuration Comparison (\(itemCount) items):")
    print("   Compact Time: \(compactResult)")
    print("   Compact Time (seconds): \(compactTimeInSeconds)")
    print("   Compact Items per second: \(Double(itemCount) / compactTimeInSeconds)")
    print("   Pretty Time: \(prettyResult)")
    print("   Pretty Time (seconds): \(prettyTimeInSeconds)")
    print("   Pretty Items per second: \(Double(itemCount) / prettyTimeInSeconds)")
    print("   Pretty slowdown factor: \(String(format: "%.2f", slowdownFactor))x")
    print("   Total elements rendered: ~\(itemCount * 3)")  // h3, p, span per item
    print(
      "   Compact performance: \(String(format: "%.2f", Double(itemCount * 3) / compactTimeInSeconds)) elements/sec"
    )
    print(
      "   Pretty performance: \(String(format: "%.2f", Double(itemCount * 3) / prettyTimeInSeconds)) elements/sec"
    )

    // Both configurations should complete within reasonable time
    #expect(compactResult < .seconds(3), "Compact rendering should be fast")
    #expect(prettyResult < .seconds(3), "Pretty rendering should also be fast")

    // Performance difference should be minimal (within 2x of each other)
    let maxTime = max(compactTimeInSeconds, prettyTimeInSeconds)
    let minTime = min(compactTimeInSeconds, prettyTimeInSeconds)
    let performanceDifference = maxTime / minTime

    print("   Performance difference: \(String(format: "%.2f", performanceDifference))x")
    #expect(performanceDifference < 2.0, "Configuration performance should be similar (within 2x)")
  }

  // MARK: - Complex Component Performance

  @Test("Complex Component Composition Performance")
  func complexComponentPerformance() throws {
    struct UserCard: HTML {
      let name: String
      let email: String
      let isActive: Bool

      var body: some HTML {
        tag("div") {
          tag("div") {
            tag("img")
              .attribute("src", "/avatar/\(name.lowercased()).jpg")
              .attribute("alt", "\(name)'s avatar")
              .inlineStyle("width", "50px")
              .inlineStyle("height", "50px")
              .inlineStyle("border-radius", "50%")
          }
          .attribute("class", "avatar")

          tag("div") {
            tag("h3") { HTMLText(name) }
            tag("p") { HTMLText(email) }
            if isActive {
              tag("span") { "● Online" }
                .inlineStyle("color", "green")
            } else {
              tag("span") { "● Offline" }
                .inlineStyle("color", "gray")
            }
          }
          .attribute("class", "info")
        }
        .attribute("class", "user-card")
        .inlineStyle("display", "flex")
        .inlineStyle("align-items", "center")
        .inlineStyle("padding", "16px")
        .inlineStyle("border", "1px solid #ddd")
        .inlineStyle("margin-bottom", "8px")
      }
    }

    let userCount = 5_000
    let users = (1...userCount).map { i in
      ("User \(i)", "user\(i)@example.com", i % 3 == 0)
    }

    let clock = ContinuousClock()
    let result = clock.measure {
      let document = HTMLDocument {
        tag("div") {
          tag("h1") { "User Directory (\(userCount) users)" }
          for (name, email, isActive) in users {
            UserCard(name: name, email: email, isActive: isActive)
          }
        }
        .attribute("class", "user-directory")
      } head: {
        tag("title") { "User Directory" }
        tag("meta").attribute("charset", "utf-8")
        tag("meta").attribute("name", "viewport")
          .attribute("content", "width=device-width, initial-scale=1")
      }
      _ = try! String(document)
    }

    let timeInSeconds =
      Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
    print("📊 PERFORMANCE DATA - Complex Component Composition (\(userCount) users):")
    print("   Time: \(result)")
    print("   Time (seconds): \(timeInSeconds)")
    print("   Components per second: \(Double(userCount) / timeInSeconds)")
    print("   Elements per component: ~7")  // div, div, img, div, h3, p, span
    print("   Total elements: ~\(userCount * 7)")
    print("   Average time per component: \(timeInSeconds / Double(userCount) * 1000)ms")

    #expect(result < .seconds(4.5), "Complex component composition should be efficient")
  }

  @Test("Form Generation Performance")
  func formGenerationPerformance() throws {
    struct FormField: HTML {
      let name: String
      let label: String
      let type: String
      let isRequired: Bool

      var body: some HTML {
        tag("div") {
          tag("label") {
            "\(label)\(isRequired ? " *" : "")"
          }
          .attribute("for", name)

          tag("input")
            .attribute("type", type)
            .attribute("name", name)
            .attribute("id", name)
            .attribute("required", isRequired ? "" : nil)
            .inlineStyle("width", "100%")
            .inlineStyle("padding", "8px")
            .inlineStyle("margin-top", "4px")
            .inlineStyle("border", "1px solid #ccc")
            .inlineStyle("border-radius", "4px")
        }
        .attribute("class", "form-field")
        .inlineStyle("margin-bottom", "16px")
      }
    }

    let fieldCount = 1_000
    let fieldTypes = ["text", "email", "tel", "url", "password"]

    let clock = ContinuousClock()
    let result = clock.measure {
      let document = HTMLDocument {
        tag("form") {
          tag("h2") { "Large Form (\(fieldCount) fields)" }

          for i in 1...fieldCount {
            FormField(
              name: "field_\(i)",
              label: "Field \(i)",
              type: fieldTypes[i % fieldTypes.count],
              isRequired: i % 5 == 0
            )
          }

          tag("button") { "Submit" }
            .attribute("type", "submit")
            .inlineStyle("background-color", "#007bff")
            .inlineStyle("color", "white")
            .inlineStyle("padding", "12px 24px")
            .inlineStyle("border", "none")
            .inlineStyle("border-radius", "4px")
            .inlineStyle("cursor", "pointer")
        }
        .attribute("method", "POST")
        .attribute("action", "/submit")
      } head: {
        tag("title") { "Large Form Test" }
      }
      _ = try! String(document)
    }

    let timeInSeconds =
      Double(result.components.seconds) + Double(result.components.attoseconds) / 1e18
    print("📊 PERFORMANCE DATA - Form Generation (\(fieldCount) fields):")
    print("   Time: \(result)")
    print("   Time (seconds): \(timeInSeconds)")
    print("   Fields per second: \(Double(fieldCount) / timeInSeconds)")
    print("   Field types used: \(fieldTypes.count)")
    print("   Elements per field: ~3")  // div, label, input
    print("   Total form elements: ~\(fieldCount * 3 + 2)")  // +2 for h2 and button
    print("   Average time per field: \(timeInSeconds / Double(fieldCount) * 1000)ms")

    #expect(result < .seconds(1), "Form generation should be very efficient")
  }

  // MARK: - Helper Functions

  private func getMemoryUsage() -> Int64 {
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
      var info = mach_task_basic_info_data_t()
      var count = mach_msg_type_number_t(
        MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<integer_t>.size
      )

      let kerr = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
          task_info(
            mach_task_self_,
            task_flavor_t(MACH_TASK_BASIC_INFO),
            $0,
            &count
          )
        }
      }

      return kerr == KERN_SUCCESS ? Int64(info.resident_size) : 0
    #else
      return 0
    #endif
  }
}
