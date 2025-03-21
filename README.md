# pointfree-html

A Swift DSL for HTML forked from [pointfreeco/swift-html](https://www.github.com/pointfreeco/swift-html) and updated to the version on [pointfreeco/pointfreeco](https://github.com/pointfreeco/pointfreeco).

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

## Overview

HTML is the format of documents. Classic examples of this are web pages and work documents like Microsoft Word and PDF. 

You use `pointfree-html` to create HTML documents using a declarative, SwiftUI-like syntax:

```swift
import HTML
struct Document: HTMLDocument {
  var head: some HTML {
    title { "Hello World" }
  }
  
  var body: some HTML {
    h1 { "Type-safe HTML" }
  }
}
```

The way you generate HTML significantly impacts the quality and maintainability of your documents. Without prioritizing readability and scalability, complexity quickly becomes overwhelming:

  * Generating HTML using raw strings or basic templates **provides no safeguards against syntax errors**, leaving your code vulnerable to mistakes and difficult-to-debug typos.
  
  * Without specialized tools, you **can't easily preview your HTML**, hindering rapid iteration and efficient design adjustments.

These challenges strongly advocate for adopting an abstraction layer for HTML creation—precisely what **PointFreeHTML** provides.

But abstraction is just the start. Once you adopt a library-based approach, you face new questions:

  * How can you **ergonomically generate attributes** without cumbersome raw HTML?

  * How can you **efficiently handle styling**? Traditional style sheets have limitations, and ideally, styling should be intuitive and inline—much like SwiftUI.

PointFreeHTML addresses these concerns comprehensively:

  * It offers a **declarative, type-safe syntax**, similar to SwiftUI, enabling compile-time error checking and drastically reducing tedious formatting mistakes.
  
  * Components are inherently **composable and reusable**, significantly improving code maintainability and scalability.

  * Styles are conveniently applied inline within components, yet are efficiently compiled into optimized CSS with automatically generated unique classes, ensuring high performance without sacrificing ease-of-use.

## Documentation

The latest documentation for the Dependencies APIs is available [here](https://swiftpackageindex.com/coenttb/pointfree-html/main/documentation/pointfreehtml).

## Examples

I built my website [coenttb.com](https://coenttb.com) using `pointfree-html`. The open source repository can be found [here](https://github.com/coenttb/coenttb-com-server).

## Acknowledgements

This project builds upon the foundational work by the Point-Free team, particularly Brandon Williams and Stephen Celis. This library is a fork and adaptation of their open-source projects, with the goal of making these ideas more accessible and customizable for various use cases. Thank you, Point-Free!

## Installation

You can add `pointfree-html` to an Xcode project by including it as a package dependency:

Repository URL: https://github.com/coenttb/pointfree-html

For a Swift Package Manager project, add the dependency in your Package.swift file:
```
dependencies: [
  .package(url: "https://github.com/coenttb/pointfree-html", branch: "main")
]
```

## Related projects

* [swift-css](https://www.github.com/coenttb/swift-css): A Swift DSL for type-safe CSS.
* [swift-html](https://www.github.com/coenttb/swift-html): A Swift DSL for type-safe HTML & CSS, integrating [swift-css](https://www.github.com/coenttb/swift-css) and [pointfree-html](https://www.github.com/coenttb/pointfree-html).
* [coenttb-html](https://www.github.com/coenttb/coenttb-html): Extends [swift-html](https://www.github.com/coenttb/swift-html) with additional functionality and integrations for HTML, Markdown, Email, and printing HTML to PDF.
* [swift-web](https://www.github.com/coenttb/swift-web): Modular tools to simplify web development in Swift forked from  [pointfreeco/swift-web](https://www.github.com/pointfreeco/swift-web), and updated for use in [coenttb-web](https://www.github.com/coenttb/coenttb-web).
* [coenttb-web](https://www.github.com/coenttb/coenttb-web): A collection of features for your Swift server, with integrations for Vapor.
* [coenttb-server](https://www.github.com/coenttb/coenttb-server): Build fast, modern, and safe servers that are a joy to write.
* [coenttb-server-vapor](https://www.github.com/coenttb/coenttb-server-vapor): Vapor & Fluent integration for coenttb-server.
* [coenttb-com-server](https://www.github.com/coenttb/coenttb-com-server): The backend server for coenttb.com, written entirely in Swift and powered by [coenttb-server-vapor](https://www.github.com/coenttb/coenttb-server-vapor).
* [swift-languages](https://www.github.com/coenttb/swift-languages): A cross-platform translation library written in Swift.

## Feedback is much appreciated!

If you’re working on your own Swift project, feel free to learn, fork, and contribute.

Got thoughts? Found something you love? Something you hate? Let me know! Your feedback helps make this project better for everyone. Open an issue or start a discussion—I’m all ears.

> [Subscribe to my newsletter](http://coenttb.com/en/newsletter/subscribe)
>
> [Follow me on X](http://x.com/coenttb)
> 
> [Link on Linkedin](https://www.linkedin.com/in/tenthijeboonkkamp)

## License

PointFreeHtml is licensed under the MIT License. See [MIT POINTFREE LICENSE](MIT%20POINTFREE%20LICENSE) for details.

