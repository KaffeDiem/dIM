
# Decentralized Instant Messenger (dIM) 
dIM is an open-source instant messenger built first and foremost for iOS. It will also run on iPad but support is limited.
It works without an internet connection and messages are sent and received through Bluetooth. For it to work optimally it will require other dIM users nearby. More information [can be found here](https://www.dimchat.org). 

![icon](./images/icon.png "dIM")

### Platform support
- iOS 16.0*
- iPadOS 16.0* (not supported very well)
- MacOS (through Catalyst)

### Feature overview
- Send and receive messages to contacts
- Add contacts by scanning their QR-code with the camera or in the app
- Encrypt all messages sent with private-key encryption
- Delete messages and message threads
- Change username

### Future ideas 
- [ ] Android version 
- [ ] Groups chats
- [ ] Deep links
- [ ] In-app notifications
- [ ] Automate the documentation on PR approval

### Getting started
Clone the project and deploy it to an iPhone. Please note that the Bluetooth capabilities does not work in the simulator, therefore a physical device is necessary to test sending and receiving messages.

If the username is set to `APPLEDEMO` a conversation will show up. This can be used to test the UI in a simulator (and is also used in the Apple App Store review process).

#### Generating assets
This project makes use of [SwiftGen](https://github.com/SwiftGen/SwiftGen#configuration-file). If you are not familiar with SwiftGen it is a tool that allows for type-safe assets. 

To add new assets simply add them in the `assets.xcassets` file and run `> swiftgen`. Type-safe assets will now be located in `Assets+Generated.swift`.

### Build documentation 
Open the project, navigate to `Product -> Build Documentation`. This will create a DocC archive for you to explore. 
