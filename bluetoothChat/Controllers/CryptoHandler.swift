//
//  CryptoHandler.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 30/08/2021.
//

import Foundation
import CryptoKit


/*
 Get the public key or generate one if it does not exist.
 */
func getPublicKey() -> String {
    let defaults = UserDefaults.standard
    
    // If key is set already return the existing one.
    if let publicKey = defaults.string(forKey: "PublicKey") {
        return publicKey
    }
    
    /*
     Generate new keys and add them to UserDefaults.
     */
    
    let privateKey = Curve25519.KeyAgreement.PrivateKey()
    let publicKey = privateKey.publicKey
    
    let privateKeyString = privateKey.rawRepresentation.base64EncodedString()
    let publicKeyString = publicKey.rawRepresentation.base64EncodedString()
    
    defaults.setValue(privateKeyString, forKey: "PrivateKey")
    defaults.setValue(publicKeyString, forKey: "PublicKey")
    
    return publicKey.rawRepresentation.base64EncodedString()
}
