# dIM (Decentralised Instant Messenger)

### (Help wanted to build an Android version)

A chat app for iOS which uses Bluetooth to send, receive and route messages.

![icon](./images/icon.png "dIM")


dIM works by sending messages to nearby users using Bluetooth.

![local](./images/local.png)

If the user is not available dIM will try to route the message trough other users until the message is received.

![local](./images/relay.png)

## Build and run
Clone the project and open `dIM.xcodeproj` in Xcode. Build and run on
a simulator running iOS >15.0. Notice that Bluetooth capabilities do not work
on simulator devices.

## Documentation
Documentation can be found on [dimchat.org](https://www.dimchat.org).

### Generate docs
Documentation is generated with [Jazzy](https://github.com/realm/jazzy). Use
the command-line argument `jazzy --build-tool-arguments
-scheme,bluetoothChat,-sdk,iphonesimulator15.2 --min-acl internal` to build the
documentation.
