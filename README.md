# goats-python-demo
A demonstration of how to integrate a python library into a goats script.

# Creating a goats script utilising a python library.
GOATS is able to pull git repos to generate test-script. Currently this is only supported with swift packages. This will guide you through how to create a swift package with a python library that is ready to be run.

## Dependencies
In order to create the swift package you will need to have swift installed. There are a few ways to install swift:
- [swift.org](https://swift.org/download/)
- [swiftly](https://github.com/swift-server/swiftly)
- [swiftenv](https://github.com/kylef/swiftenv)

It is best to install the latest version as it is capable of compiling older versions of swift. Only in rare cases would you need to install an older version of swift.

## Creating a swift package
For all future references replace `GoatsPythonDemo` with your own package name.

### Making swift package
1. Create the swift package
```bash
mkdir GoatsPythonDemo
cd GoatsPythonDemo
swift package init
```
2. Check everything is working correctly
```bash
swift test
```
3. Push the repo to a remote of your choice

### Setting up swift package
Your directory should look like this:
```
.
├── .gitignore
├── Package.swift
├── Sources
│   └── GoatsPythonDemo
│       └── GoatsPythonDemo.swift
└── Tests
    └── GoatsPythonDemoTests
        └── GoatsPythonDemoTests.swift
```

#### Package.swift
The package will need to import PythonKit in order to use python libraries. To import PythonKit you will need to add it as a dependency to your package. You will also need to add it as a dependency to your target.
1. Add the Python Kit dependency to the package
```swift
.package(url: "https://github.com/pvieito/PythonKit.git", branch: "master"),
```
2. Add PythonKit as a dependency to your target
```swift
.target(name: "GoatsPythonDemo", dependencies: ["PythonKit"])
```
The resulting `Package.swift` should look like this:
```swift
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
	name: "GoatsPythonDemo",
	products: [
	// Products define the executables and libraries produced by a package, and make them visible to other packages.
		.library(name: "GoatsPythonDemo", targets: ["GoatsPythonDemo"])
	],
	dependencies: [
	// Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/pvieito/PythonKit.git", branch: "master"),
	],
	targets: [
	// Targets are the basic building blocks of a package, defining a module or a test suite.
	// Targets can depend on other targets in this package and products from dependencies.
		.target(name: "GoatsPythonDemo", dependencies: ["PythonKit"])
	]

)
```

### GoatsPythonDemo.swift
GOATS scripts require a globally available run function. This function will be called when the script is run. This function must exist in a public struct of the same name as the package.

1. Import PythonKit
2. Create a public struct with the same name as the package
3. Create a public static function called run
4. Add the code you want to run in the run function
The resulting `GoatsPythonDemo.swift` should look something like this:
```swift
import PythonKit

public struct GoatsPythonDemo {

	public static func run() {
		let sys = Python.import("sys")
		print("Python \(sys.version_info.major).\(sys.version_info.minor)")
		print("Python Version: \(sys.version)")
		print("Python Encoding: \(sys.getdefaultencoding().upper())")
	}

}
```

## Making script reference
In order for GOATS to be able to run the script it will need to be able to reference it. This is done by including a url to the git repo in the script where you would typically include the script code in the GUI. The url can be prepended with some components to specify the product and release to use. The format is as follows:
```
<product>:<release>|<url>
```
Example:
```
GoatsPythonDemo:v1.2.0|https://github.com/gilmourspace/goats-python-demo.git
```
If no product or release is specified the default product and main branch will be used. For example:
```
https://github.com/gilmourspace/goats-python-demo.git
```
Would be equivilent to:
```
GoatsPythonDemo:main|https://github.com/gilmourspace/goats-python-demo.git
```
## Installing your python library
In order for swift to access the library the client will need to have it installed. This can be done by adding a step before the script is run to install the library.

### Using pip
Here is an example of a step that will install a library using pip.:
```swift
// Enter your install command
let command = "pip install library"

// Runs the command
let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
task.arguments = command.components(separatedBy: " ")
try task.run()
task.waitUntilExit()
let status = task.terminationStatus
print(status == 0 ? "Success" : "Failure. Exit code: \(status)")
```
**Single line:**
```swift
let command = "pip install library"; let task = Process(); task.executableURL = URL(fileURLWithPath: "/usr/bin/env"); task.arguments = command.components(separatedBy: " "); try task.run(); task.waitUntilExit(); let status = task.terminationStatus;  print(status == 0 ? "Success" : "Failure. Exit code: \(status)");
```

## Creating an executable for testing locally
In order to test the script locally you will need to create an executable.
1. Add the following to the `Package.swift` file:

**products:**
```swift
.executable(name: "goats-python-demo", targets: ["goats-python-demo"]),
```
**targets:**
```swift
.executableTarget(name: "goats-python-demo", dependencies: ["GoatsPythonDemo"])
```

The resulting Package.swift should look like this:
```swift
// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoatsPythonDemo",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "GoatsPythonDemo", targets: ["GoatsPythonDemo"]),
        .executable(name: "goats-python-demo", targets: ["goats-python-demo"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/pvieito/PythonKit.git", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "GoatsPythonDemo", dependencies: ["PythonKit"]),
        .executableTarget(name: "goats-python-demo", dependencies: ["GoatsPythonDemo"]),
    ]
)
```
2. Create a new file `Sources/goats-python-demo/main.swift`
```
.
├── Package.resolved
├── Package.swift
├── README.md
├── Sources
│   ├── goats-python-demo
│   │   └── main.swift
│   └── GoatsPythonDemo
│       └── GoatsPythonDemo.swift
└── Tests
    └── GoatsPythonDemoTests
        └── GoatsPythonDemoTests.swift
```

3. Add the following code to the `Sources/goats-python-demo/main.swift`:
```swift
import GoatsPythonDemo
GoatsPythonDemo.run()
```

4. That's it! You can now run the package locally by running:
```bash
swift run
```