# FeathersSwiftSocketIO

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](#carthage) [![CocoaPods compatible](https://img.shields.io/cocoapods/v/FeathersSwiftSocketIO.svg)](#cocoapods) [![GitHub release](https://img.shields.io/github/release/feathersjs-ecosystem/feathers-swift-socketio.svg)](https://github.com/feathersjs-ecosystem/feathers-swift-socketio/releases) ![Swift 4.0.x](https://img.shields.io/badge/Swift-4.0.x-orange.svg) ![platforms](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg) [![Build Status](https://travis-ci.org/feathersjs-ecosystem/feathers-swift-socketio.svg?branch=master)](https://travis-ci.org/feathersjs-ecosystem/feathers-swift-socketio)

## What is FeathersSwiftSocketIO?

FeathersSwiftRest is a SocketIO provider for [FeathersSwift](https://github.com/feathersjs-ecosystem/feathers-swift).

## Installation

### Cocoapods
```
pod `FeathersSwiftSocketIO`
```
### Carthage

Add the following line to your Cartfile:

```
github "feathersjs-ecosystem/feathers-swift-socketio"
```

## Usage

To use FeathersSwiftSocket, create an instance of `SocketProvider` and initialize your FeathersSwift application:

```swift
let manager = SocketManager(socketURL: URL(string: "https://myawesomefeathersapi.com")!, config: [.log(true), .compress])
let provider = SocketProvider(manager: manager, timeout: 5)
let feathersRestApp = Feathers(provider: provider)
```

Configuration options can be found on [SocketIO's github](https://github.com/socketio/socket.io-client-swift).

That's it! Your feathers application will now support a real-time socketio api.
