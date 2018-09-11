// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Atlas",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/jakeheis/SwiftCLI", .exact("4.0.3")),
        .package(url: "https://github.com/powderhouse/AtlasCore.git", from: "1.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "1.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "7.0.0"),
        ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AtlasCommands",
            dependencies: ["SwiftCLI", "AtlasCore"]),
        .target(
            name: "Atlas",
            dependencies: ["SwiftCLI", "AtlasCore", "AtlasCommands"]),
        .testTarget(
            name: "AtlasTests",
            dependencies: ["AtlasCommands", "SwiftCLI", "AtlasCore", "Quick", "Nimble"]),
        ]
)



//xcodebuild \
//-workspace Atlas.xcodeproj/project.xcworkspace \
//-scheme AtlasAppUITests \
//-destination 'platform=OS X,arch=x86_64' \
//test


// GENERATE: swift package generate-xcodeproj --xcconfig-overrides settings.xcconfig
// BUILD: swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"
// RUN: swift run -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13" Atlas
// BUILD FOR DISTRIBUTION: swift build -c release -Xswiftc -static-stdlib -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"
// S3 LOCALSTACK: SERVICES=s3 /Users/administrator/Library/Python/2.7/bin/localstack start >> /dev/null 2>&1


// Rebuilding
// swift package update
// swift package generate-xcodeproj --xcconfig-overrides settings.xcconfig
// Add Target: AtlasApp
// In AtlasApp Target find "Swift Language Version" and set to "Swift 4"
// In AtlasApp Target find "Import Paths" and add:
//  ${SRCROOT}/Atlas.xcodeproj/GeneratedModuleMap/CLibreSSL
//  ${SRCROOT}/Atlas.xcodeproj/GeneratedModuleMap/CHTTPParser
// Move all files from AtlasApp (old) to AtlasApp (new)
// Move all files from AtlasAppUITests (old) to AtlasAppUITests (new)
// git status
// git checkout AtlasApp
// rm AtlasApp/ViewController.swift
// rm AtlasAppUITests/AtlasAppUITests.swift
// Delete old and "Remove Reference" for app and ui tests
// Delete red files
// Add AtlasCore as Embedded Binary to AtlasApp
// Assign all lib file (within AtlasApp) to AtlasApp
// In AtlasCore target add a "Copy Bundle Resources" item to "Build Phases" and select "git"
// Set Swift to 4.0
// Embed SwiftAWSIAM
// Embed AWSSDKSwiftCore
// Embed HypertextApplicationLanguage
