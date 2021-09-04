//
//  CryptoHandler.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 30/08/2021.
//

import UIKit
import CryptoKit


func getPublicKey() -> String {
    let defaults = UserDefaults.standard
    
    /*
     Return the public key if it exists.
     */
    if let privateKey = defaults.string(forKey: "settings.privatekey") {
        let privateKey = try! importPrivateKey(privateKey)
        
        let publicKeyExport = exportPublicKey(privateKey.publicKey)
        return publicKeyExport
    }
    
    /*
     Create a new key pair if none are found.
     */
    let privateKey = generatePrivateKey()
    
    let privateKeyExport = exportPrivateKey(privateKey)
    let publicKeyExport = exportPublicKey(privateKey.publicKey)
    
    /*
     Save the private key to persistent memory as a string.
     */
    defaults.setValue(privateKeyExport, forKey: "settings.privatekey")
    
    return publicKeyExport
}


/*
 Get the private key of the client.
 */
func getPrivateKey() -> P256.KeyAgreement.PrivateKey {
    let defaults = UserDefaults.standard
    
    return try! importPrivateKey(defaults.string(forKey: "settings.privatekey")!)
}


/*
 Generate a simple private / public keypair.
 (Publickey can be accessed with privateKey.publicKey)
 */
func generatePrivateKey() -> P256.KeyAgreement.PrivateKey {
    let privateKey = P256.KeyAgreement.PrivateKey()
    return privateKey
}


/*
 Convert a private key to a string type for storage.
 */
func exportPrivateKey(_ privateKey: P256.KeyAgreement.PrivateKey) -> String {
    let rawPrivateKey = privateKey.rawRepresentation
    let privateKeyBase64 = rawPrivateKey.base64EncodedString()
    let percentEncodedPrivateKey = privateKeyBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    return percentEncodedPrivateKey
}


/*
 Convert a public key to a string type for sharing.
 This is used to generate the QR code.
 */
func exportPublicKey(_ publicKey: P256.KeyAgreement.PublicKey) -> String {
    let rawPublicKey = publicKey.rawRepresentation
    let base64PublicKey = rawPublicKey.base64EncodedString()
    let encodedPublicKey = base64PublicKey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    return encodedPublicKey
}


/*
 Convert a private key string into an object type.
 */
func importPrivateKey(_ privateKey: String) throws -> P256.KeyAgreement.PrivateKey {
    let privateKeyBase64 = privateKey.removingPercentEncoding!
    let rawPrivateKey = Data(base64Encoded: privateKeyBase64)!
    return try P256.KeyAgreement.PrivateKey(rawRepresentation: rawPrivateKey)
}


/*
 Convert a public key string into an object type.
 */
func importPublicKey(_ publicKey: String) throws -> P256.KeyAgreement.PublicKey {
    let base64PublicKey = publicKey.removingPercentEncoding!
    let rawPublicKey = Data(base64Encoded: base64PublicKey)!
    let publicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: rawPublicKey)
    return publicKey
}


/*
 Derive the symmetric key for encryption / decryption.
 */
func deriveSymmetricKey(privateKey: P256.KeyAgreement.PrivateKey, publicKey: P256.KeyAgreement.PublicKey) throws -> SymmetricKey {
    let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
    
    let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
        using: SHA256.self,
        salt: "My Key Agreement Salt".data(using: .utf8)!,
        sharedInfo: Data(),
        outputByteCount: 32
    )
    
    return symmetricKey
}


/*
 Encrypt a string based on a symmetric key.
 */
func encryptMessage(text: String, symmetricKey: SymmetricKey) throws -> String {
    let textData = text.data(using: .utf8)!
    let encrypted = try AES.GCM.seal(textData, using: symmetricKey)
    return encrypted.combined!.base64EncodedString()
}


/*
 Decrypt a string based on a symmetric key.
 */
func decryptMessage(text: String, symmetricKey: SymmetricKey) -> String {
    do {
        guard let data = Data(base64Encoded: text) else {
            return "Could not decode text: \(text)"
        }
        
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
        
        guard let text = String(data: decryptedData, encoding: .utf8) else {
            return "Could not decode data: \(decryptedData)"
        }
        
        return text
    } catch let error {
        return "Error decrypting message: \(error.localizedDescription)"
    }
}
