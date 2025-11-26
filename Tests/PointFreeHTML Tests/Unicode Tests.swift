//
//  Unicode Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//
//  Cross-cutting tests for Unicode handling, internationalization, and encoding.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("Unicode Tests")
struct UnicodeTests {

    // MARK: - Basic Unicode Text

    @Test("ASCII text renders correctly")
    func asciiText() throws {
        let html = tag("p") { HTMLText("Hello, World!") }
        let rendered = try String(html)
        #expect(rendered == "<p>Hello, World!</p>")
    }

    @Test("Latin extended characters")
    func latinExtended() throws {
        let html = tag("p") { HTMLText("Héllo, Wörld! Señor, naïve, café") }
        let rendered = try String(html)
        #expect(rendered.contains("Héllo"))
        #expect(rendered.contains("Wörld"))
        #expect(rendered.contains("Señor"))
        #expect(rendered.contains("naïve"))
        #expect(rendered.contains("café"))
    }

    @Test("German umlauts and eszett")
    func germanCharacters() throws {
        let html = tag("p") { HTMLText("Größe, Äpfel, Übung, öffentlich") }
        let rendered = try String(html)
        #expect(rendered.contains("Größe"))
        #expect(rendered.contains("Äpfel"))
        #expect(rendered.contains("Übung"))
    }

    @Test("French accents")
    func frenchAccents() throws {
        let html = tag("p") { HTMLText("français, élève, où, ça, garçon") }
        let rendered = try String(html)
        #expect(rendered.contains("français"))
        #expect(rendered.contains("élève"))
    }

    // MARK: - CJK Characters

    @Test("Japanese characters - Hiragana")
    func japaneseHiragana() throws {
        let html = tag("p") { HTMLText("こんにちは") }
        let rendered = try String(html)
        #expect(rendered.contains("こんにちは"))
    }

    @Test("Japanese characters - Katakana")
    func japaneseKatakana() throws {
        let html = tag("p") { HTMLText("コンニチハ") }
        let rendered = try String(html)
        #expect(rendered.contains("コンニチハ"))
    }

    @Test("Japanese characters - Kanji")
    func japaneseKanji() throws {
        let html = tag("p") { HTMLText("日本語、漢字、東京") }
        let rendered = try String(html)
        #expect(rendered.contains("日本語"))
        #expect(rendered.contains("漢字"))
    }

    @Test("Chinese characters - Simplified")
    func chineseSimplified() throws {
        let html = tag("p") { HTMLText("你好世界，中文简体") }
        let rendered = try String(html)
        #expect(rendered.contains("你好世界"))
    }

    @Test("Chinese characters - Traditional")
    func chineseTraditional() throws {
        let html = tag("p") { HTMLText("繁體中文，臺灣") }
        let rendered = try String(html)
        #expect(rendered.contains("繁體中文"))
    }

    @Test("Korean characters")
    func koreanCharacters() throws {
        let html = tag("p") { HTMLText("안녕하세요, 한국어") }
        let rendered = try String(html)
        #expect(rendered.contains("안녕하세요"))
        #expect(rendered.contains("한국어"))
    }

    // MARK: - Other Scripts

    @Test("Arabic text")
    func arabicText() throws {
        let html = tag("p") { HTMLText("مرحبا بالعالم") }
        let rendered = try String(html)
        #expect(rendered.contains("مرحبا"))
    }

    @Test("Hebrew text")
    func hebrewText() throws {
        let html = tag("p") { HTMLText("שלום עולם") }
        let rendered = try String(html)
        #expect(rendered.contains("שלום"))
    }

    @Test("Thai text")
    func thaiText() throws {
        let html = tag("p") { HTMLText("สวัสดีครับ") }
        let rendered = try String(html)
        #expect(rendered.contains("สวัสดีครับ"))
    }

    @Test("Hindi text (Devanagari)")
    func hindiText() throws {
        let html = tag("p") { HTMLText("नमस्ते दुनिया") }
        let rendered = try String(html)
        #expect(rendered.contains("नमस्ते"))
    }

    @Test("Russian Cyrillic")
    func russianCyrillic() throws {
        let html = tag("p") { HTMLText("Привет мир") }
        let rendered = try String(html)
        #expect(rendered.contains("Привет"))
    }

    @Test("Greek text")
    func greekText() throws {
        let html = tag("p") { HTMLText("Γειά σου Κόσμε") }
        let rendered = try String(html)
        #expect(rendered.contains("Γειά"))
    }

    // MARK: - Emoji

    @Test("Basic emoji")
    func basicEmoji() throws {
        let html = tag("p") { HTMLText("Hello 👋 World 🌍") }
        let rendered = try String(html)
        #expect(rendered.contains("👋"))
        #expect(rendered.contains("🌍"))
    }

    @Test("Complex emoji - skin tones")
    func emojiSkinTones() throws {
        let html = tag("p") { HTMLText("👋🏻 👋🏼 👋🏽 👋🏾 👋🏿") }
        let rendered = try String(html)
        #expect(rendered.contains("👋🏻"))
        #expect(rendered.contains("👋🏿"))
    }

    @Test("Complex emoji - ZWJ sequences")
    func emojiZWJSequences() throws {
        let html = tag("p") { HTMLText("👨‍👩‍👧‍👦 👩‍💻 🏳️‍🌈") }
        let rendered = try String(html)
        #expect(rendered.contains("👨‍👩‍👧‍👦"))
    }

    @Test("Flag emoji")
    func flagEmoji() throws {
        let html = tag("p") { HTMLText("🇺🇸 🇬🇧 🇯🇵 🇩🇪 🇫🇷") }
        let rendered = try String(html)
        #expect(rendered.contains("🇺🇸"))
        #expect(rendered.contains("🇯🇵"))
    }

    // MARK: - Special Unicode Characters

    @Test("Mathematical symbols")
    func mathematicalSymbols() throws {
        let html = tag("p") { HTMLText("∑ ∏ ∫ ∂ ∆ √ ∞ ≠ ≈ ≤ ≥") }
        let rendered = try String(html)
        #expect(rendered.contains("∑"))
        #expect(rendered.contains("∞"))
        #expect(rendered.contains("≠"))
    }

    @Test("Currency symbols")
    func currencySymbols() throws {
        let html = tag("p") { HTMLText("$ € £ ¥ ₹ ₽ ฿ ₿") }
        let rendered = try String(html)
        #expect(rendered.contains("€"))
        #expect(rendered.contains("£"))
        #expect(rendered.contains("¥"))
    }

    @Test("Arrows and symbols")
    func arrowsAndSymbols() throws {
        let html = tag("p") { HTMLText("← → ↑ ↓ ↔ ⇒ ⇐ • ° © ® ™") }
        let rendered = try String(html)
        #expect(rendered.contains("→"))
        #expect(rendered.contains("©"))
    }

    // MARK: - Unicode in Attributes

    @Test("Unicode in attribute values")
    func unicodeInAttributes() throws {
        let html = tag("div")
            .attribute("title", "日本語のタイトル")
            .attribute("data-greeting", "こんにちは")
        let rendered = try String(html)
        #expect(rendered.contains("日本語のタイトル"))
    }

    @Test("Emoji in attribute values")
    func emojiInAttributes() throws {
        let html = tag("button")
            .attribute("title", "Click me 🎉")
            .attribute("aria-label", "Celebrate 🎊")
        let rendered = try String(html)
        #expect(rendered.contains("🎉"))
    }

    // MARK: - Mixed Content

    @Test("Mixed scripts in single text")
    func mixedScripts() throws {
        let html = tag("p") {
            HTMLText("Hello 你好 مرحبا Привет こんにちは")
        }
        let rendered = try String(html)
        #expect(rendered.contains("Hello"))
        #expect(rendered.contains("你好"))
        #expect(rendered.contains("مرحبا"))
        #expect(rendered.contains("Привет"))
        #expect(rendered.contains("こんにちは"))
    }

    @Test("Multiple elements with different scripts")
    func multipleScriptElements() throws {
        let html = tag("div") {
            tag("p") { HTMLText("English") }.attribute("lang", "en")
            tag("p") { HTMLText("日本語") }.attribute("lang", "ja")
            tag("p") { HTMLText("العربية") }.attribute("lang", "ar")
        }
        let rendered = try String(html)
        #expect(rendered.contains("English"))
        #expect(rendered.contains("日本語"))
        #expect(rendered.contains("العربية"))
    }

    // MARK: - Edge Cases

    @Test("Combining characters")
    func combiningCharacters() throws {
        // é can be represented as e + combining acute accent
        let html = tag("p") { HTMLText("cafe\u{0301}") }  // café with combining accent
        let rendered = try String(html)
        #expect(rendered.contains("é") || rendered.contains("e\u{0301}"))
    }

    @Test("Zero-width characters")
    func zeroWidthCharacters() throws {
        let html = tag("p") { HTMLText("zero\u{200B}width\u{200B}space") }
        let rendered = try String(html)
        // Zero-width space should be preserved
        #expect(rendered.contains("\u{200B}"))
    }

    @Test("Right-to-left override")
    func rtlOverride() throws {
        let html = tag("p") { HTMLText("Hello \u{202E}dlroW") }  // RLO character
        let rendered = try String(html)
        #expect(rendered.contains("\u{202E}"))
    }

    @Test("Byte order mark (BOM)")
    func byteOrderMark() throws {
        let html = tag("p") { HTMLText("\u{FEFF}Content with BOM") }
        let rendered = try String(html)
        // BOM should be preserved
        #expect(rendered.contains("Content with BOM"))
    }

    // MARK: - Unicode Normalization

    @Test("NFC normalized content")
    func nfcNormalized() throws {
        // Precomposed form
        let html = tag("p") { HTMLText("é") }  // U+00E9
        let rendered = try String(html)
        #expect(rendered.contains("é"))
    }

    @Test("NFD normalized content")
    func nfdNormalized() throws {
        // Decomposed form
        let html = tag("p") { HTMLText("e\u{0301}") }  // e + combining acute
        let rendered = try String(html)
        #expect(rendered.count > 0)
    }

    // MARK: - Large Unicode Content

    @Test("Large multilingual content")
    func largeMultilingualContent() throws {
        var content = ""
        for _ in 0..<100 {
            content += "Hello 你好 مرحبا Привет こんにちは 안녕하세요 "
        }
        let html = tag("div") { HTMLText(content) }
        let rendered = try String(html)
        #expect(rendered.contains("你好"))
        #expect(rendered.contains("こんにちは"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct UnicodeSnapshotTests {
        @Test("Multilingual page snapshot")
        func multilingualPageSnapshot() {
            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("article") {
                        tag("h1") { HTMLText("Welcome 欢迎 مرحبا") }
                        tag("p") { HTMLText("This is English.") }
                        tag("p") { HTMLText("これは日本語です。") }
                        tag("p") { HTMLText("هذه اللغة العربية.") }
                    }
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>

                    </style>
                  </head>
                  <body>
                <article>
                  <h1>Welcome 欢迎 مرحبا
                  </h1>
                  <p>This is English.
                  </p>
                  <p>これは日本語です。
                  </p>
                  <p>هذه اللغة العربية.
                  </p>
                </article>
                  </body>
                </html>
                """
            }
        }
    }
}
