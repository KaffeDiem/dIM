//
//  CryptoHandler.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 30/08/2021.
//

import UIKit
import CryptoKit

/// Handles all encryption of messages as well as public and private keys.
class CryptoHandler {
    /// Gets your public key for generation of the QR code.
    ///
    /// Gets the saved public key from `UserDefaults` if there is one.
    /// Otherwise it will generate a new public key.
    ///
    /// - Returns: Your public key as a string.
    static func getPublicKey() -> String {
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


    /// Returns your private key which is saved as a string in `UserDefaults`.
    /// - Returns: Your private key as a private key object.
    static func getPrivateKey() -> P256.KeyAgreement.PrivateKey {
        return try! importPrivateKey(UserDefaults.standard.string(forKey: "settings.privatekey")!)
    }

    /// Generate a new private key for you.
    ///
    /// This is only used when a username has been set.
    /// This private key also holds your public key.
    /// It can be accessed with `privatekey.publickey`
    /// - Returns: Your new private key.
    static func generatePrivateKey() -> P256.KeyAgreement.PrivateKey {
        let privateKey = P256.KeyAgreement.PrivateKey()
        return privateKey
    }

    /// Converts a private key object into a string since objects cannot be
    /// saved to storage.
    /// - Parameter privateKey: The private key to convert.
    /// - Returns: The private key as a string.
    static func exportPrivateKey(_ privateKey: P256.KeyAgreement.PrivateKey) -> String {
        let rawPrivateKey = privateKey.rawRepresentation
        let privateKeyBase64 = rawPrivateKey.base64EncodedString()
        let percentEncodedPrivateKey = privateKeyBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        return percentEncodedPrivateKey
    }

    /// Converts a public key object into a string since objects cannot be
    /// saved to storage.
    /// - Parameter publicKey: The public key to convert.
    /// - Returns: The public key as a string.
    static func exportPublicKey(_ publicKey: P256.KeyAgreement.PublicKey) -> String {
        let rawPublicKey = publicKey.rawRepresentation
        let base64PublicKey = rawPublicKey.base64EncodedString()
        let encodedPublicKey = base64PublicKey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        return encodedPublicKey
    }

    /// Convert a private key string into a private key object.
    /// - Parameter privateKey: The private key as a string to convert.
    /// - Throws: Throws if the private key string cannot be converted to an object due to wrong formatting.
    /// - Returns: The private key as an object.
    static func importPrivateKey(_ privateKey: String) throws -> P256.KeyAgreement.PrivateKey {
        let privateKeyBase64 = privateKey.removingPercentEncoding!
        let rawPrivateKey = Data(base64Encoded: privateKeyBase64)!
        return try P256.KeyAgreement.PrivateKey(rawRepresentation: rawPrivateKey)
    }

    /// Convert a public key string into a public key object.
    /// - Parameter publicKey: The public key as a string to convert.
    /// - Throws: Throws if the public key string cannot be converted to an object due to wrong formatting.
    /// - Returns: The public key as an object.
    static func importPublicKey(_ publicKey: String) throws -> P256.KeyAgreement.PublicKey {
        let base64PublicKey = publicKey.removingPercentEncoding!
        let rawPublicKey = Data(base64Encoded: base64PublicKey)!
        let publicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: rawPublicKey)
        return publicKey
    }


    /// Derive the symmetric key to use for encryption.
    /// - Parameters:
    ///   - privateKey: The private key to use (yours)
    ///   - publicKey: The public key to use (the receiver of the message)
    /// - Throws: If the shared secret cannot be derived. Most likely due to wrong formatting.
    /// - Returns: The symmetric key to use for encryption.
    static func deriveSymmetricKey(privateKey: P256.KeyAgreement.PrivateKey, publicKey: P256.KeyAgreement.PublicKey) throws -> SymmetricKey {
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "My Key Agreement Salt".data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        return symmetricKey
    }

    /// Encrypt a string given a symmetric key.
    /// - Parameters:
    ///   - text: The string to encrypt.
    ///   - symmetricKey: The symmetric key to use.
    /// - Throws: If the encryption failed for some reason.
    /// - Returns: An encrypted string which is unreadable.
    static func encryptMessage(text: String, symmetricKey: SymmetricKey) throws -> String {
        let textData = text.data(using: .utf8)!
        let encrypted = try AES.GCM.seal(textData, using: symmetricKey)
        return encrypted.combined!.base64EncodedString()
    }

    /// Decrypt a message that you have received.
    /// - Parameters:
    ///   - text: The string to decrypt.
    ///   - symmetricKey: The symmetric key to use.
    /// - Returns: A human-readable string.
    static func decryptMessage(text: String, symmetricKey: SymmetricKey) -> String {
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
        
}
