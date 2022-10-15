# dIM Chat

dIM stands for Decentralized Instant Messenger. 
It is a chat app built for iOS devices first and foremost. It will also run on iPad. 
It works by relaying messages through the Bluetooth connections of other dIM users. 

![icon](./images/icon.png "dIM")

*Get started* by cloning the project and deploy it to an iPhone.
**Help is also wanted to build an Android version**

![local](./images/local.png)

Messages sent through dIM is sent through the peer-to-peer network that all dIM users are maintaining. The network is set up as soon as dIM has been opened for the first time, and is running is long as the app has not been force-closed and Bluetooth is enabled. 

If the user is not available dIM will try to route the message trough other users until the message is received. This also uses a smart algorithm that minimizes sent messages on the network.

![local](./images/relay.png)

## Build and run
Clone the project and open `dIM.xcodeproj` in Xcode. Build and run on
a simulator running iOS >15.0. Notice that Bluetooth only work on physical devices.

## Documentation
Documentation can be found on [dimchat.org](https://www.dimchat.org).

### Build documentation 
Open the project, navigate to `Product -> Build Documentation`. 
The `build-docs.sh` script can also be run.
