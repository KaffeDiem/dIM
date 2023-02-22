
> dIM is under a major refactor project, you can see the WIP PR [here #32](https://github.com/KaffeDiem/dIM/pull/32)

# Decentralized Instant Messenger (dIM) 
dIM is an open-source instant messenger built first and foremost for iOS. It will also run on iPad but support is limited.
It works without an internet connection and messages are sent and received through Bluetooth. For it to work optimally it will require other dIM users nearby. More information [can be found here](https://www.dimchat.org). 

![icon](./images/icon.png "dIM")

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

### Build documentation 
Open the project, navigate to `Product -> Build Documentation`. This will create a DocC archive for you to explore. 
