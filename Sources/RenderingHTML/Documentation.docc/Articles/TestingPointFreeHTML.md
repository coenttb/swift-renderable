# Testing HTML components

Write tests that actually matter. Learn what to test (and what to skip) when building with PointFreeHTML.

## The golden rule: test what you own

Here's the principle that will save you hours of wasted effort: **test what you own, trust what you import**.

Think about it this way: You don't test that Swift's `+` operator adds numbers correctly. You don't test that `Array.append()` works. So why test that PointFreeHTML's `div` function creates a `<div>` tag?

For PointFreeHTML developers, this means:

- **Test your component logic** - Does it show the right content based on your data?
- **Test your styling decisions** - Does the error state get red styling?  
- **Skip testing PointFreeHTML itself** - It has thousands of tests already
- **Skip testing browsers** - Focus on your HTML output, not Chrome's rendering engine

When you follow this rule, your tests run faster, break less often, and actually catch real bugs.

## What makes a great HTML component test

The best tests share three traits:

1. **They're lightning fast** - No network calls, no database, just pure functions
2. **They test one thing** - When they fail, you know exactly what broke
3. **They survive refactoring** - Internal changes don't break them

Let's see this in action.

## Integration testing done right

When you're integrating libraries, test just the glue code. Here's a real example from the `swift-html-css-pointfree` library that adds HTML elements to PointFreeHTML:

```swift
extension HTML_Standard_Elements.Anchor {
    public func callAsFunction(
        @Builder _ content: () -> some HTML
    ) -> some HTML {
        HTMLElement(tag: Self.tag) { content() }
            .attributionSrc(self.attributionsrc)
            .download(self.download)
            .href(self.href)
            // ... more attributes
    }
}
```

And here's how CSS styling gets added:

```swift
extension HTML {
    public func color(
        _ color: W3C_CSS_Color.Color?,
        media: W3C_CSS_MediaQueries.Media? = nil,
        pre: String? = nil,
        pseudo: Pseudo? = nil
    ) -> HTMLInlineStyle<Self> {
        self.inlineStyle(color, media: media, pre: pre, pseudo: pseudo)
    }
}
```

The perfect test for this integration focussess just on the integration: did the element get created with the correct attributes and styling. 

A snapshot test works well here:

```swift
@Test("HTML element with attributes and styles")
func anchorElementWithStyling() {
    assertInlineSnapshot(
        of: HTMLDocument {
            Anchor(href: "#") {
                "Click here!"
            }
            .color(.red)
        },
        as: .html
    ) {
        """
        <!doctype html>
        <html>
          <head>
            <style>
        .color-dMYaj4{color:red}

            </style>
          </head>
          <body><a class="color-dMYaj4" href="#">Click here!</a>
          </body>
        </html>
        """
    }
}
```

> **What's a snapshot test?**
> 
> It captures your component's output and saves it. Next time you run tests, it compares the new output to the saved snapshot. If they differ, the test fails. It's like taking a photo of your component and checking if it still looks the same later.

### When snapshots shine (and when they don't)

**Use snapshots when:**
- Testing complex layouts where structure matters
- Verifying integration between multiple libraries
- Documenting what your component actually produces

**Skip snapshots when:**
- A simple assertion would be clearer
- The output changes frequently for valid reasons
- You're testing logic, not structure

## What NOT to test (this will save you time)

### Don't test PointFreeHTML's core features

```swift
// ❌ BAD: Testing that div creates a div tag
@Test("Div element renders as div tag")
func testDivRendering() {
    let html = div { "content" }
    let output = try String(html)
    #expect(output.contains("<div>"))
    #expect(output.contains("</div>"))
}

// ❌ BAD: Testing that PointFreeHTML generates CSS classes
@Test("Inline styles generate CSS classes")
func testStyleGeneration() {
    let html = div { "content" }.inlineStyle("color", "red")
    let output = try String(html)
    #expect(output.contains("class="))
    #expect(output.contains("color:red"))
}
```

Why are these bad? You're testing PointFreeHTML's features, not your code. It's like testing that electricity flows through wires.

### Don't test implementation details

```swift
// ❌ BAD: Testing the exact CSS class name (fragile!)
@Test("Button has specific CSS class name")
func testButtonClassName() {
    let button = PrimaryButton(title: "Save")
    let html = try String(button)
    #expect(html.contains("class=\"color-xyz123\""))  // This will break!
}

// ✅ GOOD: Testing that the right color is applied
@Test("Primary button uses brand color")
func testPrimaryButtonColor() {
    let button = PrimaryButton(title: "Save")
    let html = try String(button)
    #expect(html.contains("color:#007bff"))  // Testing the outcome
}
```

The good test will survive internal changes to how PointFreeHTML generates class names. The bad test breaks every time the wind blows.

### Don't test every possible combination

```swift
// ❌ BAD: Testing all 50 combinations is overkill
@Test("All button variants with all sizes")
func testAllButtonCombinations() {
    for variant in ButtonVariant.allCases {  // 5 variants
        for size in ButtonSize.allCases {     // 10 sizes
            let button = Button(title: "Test", variant: variant, size: size)
            let html = try String(button)
            // 50 different tests for one button!
        }
    }
}

// ✅ GOOD: Test key behaviors separately
@Test("Button variants apply correct colors")
func testButtonVariants() {
    // Test just the color behavior
    #expect(Button(title: "Test", variant: .primary).html.contains("background-color:#007bff"))
    #expect(Button(title: "Test", variant: .danger).html.contains("background-color:#dc3545"))
}

@Test("Button sizes apply correct padding")
func testButtonSizes() {
    // Test just the sizing behavior
    #expect(Button(title: "Test", size: .small).html.contains("padding:4px 8px"))
    #expect(Button(title: "Test", size: .large).html.contains("padding:12px 24px"))
}
```

Testing key behaviors separately makes failures more meaningful. When the "button colors" test fails, you know exactly what to fix.

## Your testing checklist

### ✅ DO test these things

- **Component logic**: "Shows error message when validation fails"
- **Conditional rendering**: "Hides private content for logged-out users"
- **Data transformations**: "Formats currency with proper decimal places"
- **Edge cases**: "Handles empty product list gracefully"

### ❌ DON'T test these things

- **HTML generation**: "div function creates div tags"
- **CSS behavior**: "red text appears red in browsers"
- **Internal details**: "Uses class name 'xyz-123'"
- **Exhaustive combinations**: "All 500 possible button states"

### 🎯 Focus on what matters

Ask yourself: "If this test fails, is it because MY code broke, or because something I depend on changed?"

If it's the latter, delete the test. Your time is too valuable to maintain tests for other people's code.

## The payoff

When you follow this approach, something magical happens:

- Your tests run in seconds, not minutes
- They catch actual bugs in your logic
- They don't break when you upgrade PointFreeHTML
- They serve as living documentation
- You actually enjoy writing them (okay, maybe "enjoy" is strong, but at least you won't dread it)

The best test suite isn't the one with the most tests—it's the one that gives you confidence to ship without wasting your time on maintenance.

Remember: Test your code, trust your tools, and spend the time you save building great features.
