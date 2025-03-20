# swift-html

A Swift DSL for HTML based on [pointfreeco/swift-html](https://www.github.com/pointfreeco/swift-html) and updated to the version on [pointfreeco/pointfreeco](https://github.com/pointfreeco/pointfreeco).

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

## Examples

You can create HTML documents using a declarative, SwiftUI-like syntax, with support for type-safe CSS:

```swift
import HTML
// Assuming an HTMLPreview: HTMLDocument type
let document = HTMLPreview {
  h1 { "Type-safe HTML" }
}
```

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
* [coenttb-com-server](https://www.github.com/coenttb/coenttb-com-server): The backend server for coenttb.com, written entirely in Swift and powered by [Vapor](https://www.github.com/vapor/vapor) and [coenttb-web](https://www.github.com/coenttb/coenttb-web).
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

