//
//  ContentView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import SwiftUI

struct ContentView: View {
    
    // Create a new Bluetooth Manager which handles the central and peripheral role.
    @ObservedObject var bluetoothManager = BluetoothManager()
    
    // THIS IS A TEST ON BRANCHES
    
    var body: some View {
        NavigationView {
//
//            List( bluetoothManager.threads ) { thread in
//                ContactView(thread: thread)
//            }
            List(bluetoothManager.messages) {message in
                ContactView(message: message, BM: bluetoothManager)
            }
//
//            List() {
//                ContactView(thread: Thread(id: 10, author: "Kasper", lastMessage: "Fun night", messages: []))
//            }
            
            .navigationTitle("Chat")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    NavigationLink(
                        destination: Text("Settings: Work in progress."),
                        label: {
                            Image(systemName: "gearshape.fill")
                        })
                    Button("Count", action: {print(bluetoothManager.getConnectedDevices())})
                    Button("Send", action: {
                            print(bluetoothManager.sendData(message: "Here is data!"))
                    })
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: Text("Add user: Work in progress."),
                        label: {
                            Image(systemName: "person.fill.badge.plus")
                        })
                    NavigationLink(
                        destination: ConnectionView(connectedDevices: bluetoothManager.getConnectedDevices()),
                        label: {
                            Image(systemName: "bolt.horizontal.circle.fill")
                        })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
