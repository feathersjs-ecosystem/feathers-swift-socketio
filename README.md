# FeathersSwiftSocketIO

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](#carthage) [![CocoaPods compatible](https://img.shields.io/cocoapods/v/FeathersSwiftSocketIO.svg)](#cocoapods) [![GitHub release](https://img.shields.io/github/release/startupthekid/feathers-swift-socketio.svg)](https://github.com/startupthekid/feathers-ios/releases) ![Swift 3.0.x](https://img.shields.io/badge/Swift-3.0.x-orange.svg) ![platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS-lightgrey.svg) [![Build Status](https://travis-ci.org/startupthekid/feathers-swift-socketio.svg?branch=master)](https://travis-ci.org/startupthekid/feathers-swift-socketio)

## What is FeathersSwiftSocketIO?

FeathersSwiftRest is a SocketIO provider for [FeathersSwift](https://github.com/startupthekid/feathers-swift).

## Installation

### Cocoapods
```
pod `FeathersSwiftSocketIO`
```
### Carthage

Add the following line to your Cartfile:

```
github "startupthekid/feathers-swift-socketio"
```

## Usage

To use FeathersSwiftSocket, create an instance of `SocketProvider` and initialize your FeathersSwift application:

```swift
let feathersRestApp = Feathers(provider: SocketProvider(baseURL: URL(string: "https://myawesomefeathersapi.com")!, configuration: [], timeout: 5))
```

Configuration options can be found on [SocketIO's github](https://github.com/socketio/socket.io-client-swift).

That's it! Your feathers application will now support a real-time socketio api.

**NOTE:** This framework does not support watchOS due to limitations with the internal SocketIO library.
