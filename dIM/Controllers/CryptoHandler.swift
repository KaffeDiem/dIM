//
//  CryptoHandler.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 30/08/2021.
//

import UIKit
import CryptoKit

/// Largely a helper class with functions related to encryption keys
/// and handling of private/public key pairs for the user.
///
/// - Note: Could use a major refactor in the future, there is no reason for all these functions
/// to be publicly available.
class CryptoHandler {
    enum CryptoHandlerError: Error, LocalizedError {
        case conversationKeyNotFound
        case keyInWrongFormat
        case textCannotBeUtf8Converted
        case textCannotBeEncrypted
        case userPrivateKeyNotFound
            
        public var errorDescription: String? {
            switch self {
            case .conversationKeyNotFound:
                return NSLocalizedString("No cryptography key found for this conversation.", comment: "No key found")
            case .keyInWrongFormat:
                return NSLocalizedString("Public/Private key is in wrong format.", comment: "Wrong key format")
            case .textCannotBeEncrypted:
                return NSLocalizedString("The message text cannot be encrypted.", comment: "Not able to encrypt message text")
            case .textCannotBeUtf8Converted:
                return NSLocalizedString("Cannot convert text to UTF8 format.", comment: "UTF8 conversion failure")
            case .userPrivateKeyNotFound:
                return NSLocalizedString("Your private key could not be found.", comment: "Private key not found")
            }
        }
    }
    
    /// Gets your public key for generation of the QR code.
    ///
    /// - Note: Always returns a public key as a string. If one has never been
    /// generated this function will take care of that.
    ///
    /// - Returns: Your public key as a string.
    static func fetchPublicKeyString() -> String {
        let defaults = UserDefaults.standard
        
        /// Return already existing key
        if let privateKeyText = defaults.string(forKey: UserDefaultsKey.privateKey.rawValue),
            let privateKey = try? convertPrivateKeyStringToKey(privateKeyText) {
            let publicKeyText = convertPublicKeyToString(privateKey.publicKey)
            return publicKeyText
        }
        
        /// Generate and save a new key pair
        let privateKey = generatePrivateKey()
        let privateKeyText = convertPrivateKeyToString(privateKey)
        let publicKeyText = convertPublicKeyToString(privateKey.publicKey)
        defaults.setValue(privateKeyText, forKey: UserDefaultsKey.privateKey.rawValue)
        return publicKeyText
    }


    /// Returns the current users private key which is saved as a string in `UserDefaults`.
    /// - Returns: Your private key as a private key object.
    static func fetchPrivateKey() throws -> P256.KeyAgreement.PrivateKey {
        guard let privateKey = UserDefaults.standard.string(forKey: UserDefaultsKey.privateKey.rawValue) else {
            throw CryptoHandlerError.userPrivateKeyNotFound
        }
        return try convertPrivateKeyStringToKey(privateKey)
    }

    /// Generate a new private key for you.
    ///
    /// This is only used when a username has been set.
    /// This private key also holds your public key.
    /// It can be accessed with `privatekey.publickey`
    /// - Returns: Your new private key.
    static func generatePrivateKey() -> P256.KeyAgreement.PrivateKey {
        P256.KeyAgreement.PrivateKey()
    }

    /// Converts a private key object into a string since objects cannot be
    /// saved to storage.
    /// - Parameter privateKey: The private key to convert.
    /// - Returns: The private key as a string.
    static func convertPrivateKeyToString(_ privateKey: P256.KeyAgreement.PrivateKey) -> String {
        let rawPrivateKey = privateKey.rawRepresentation
        let privateKeyBase64 = rawPrivateKey.base64EncodedString()
        let percentEncodedPrivateKey = privateKeyBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        return percentEncodedPrivateKey
    }

    /// Converts a public key object into a string since objects cannot be
    /// saved to storage.
    /// - Parameter publicKey: The public key to convert.
    /// - Returns: The public key as a string.
    static func convertPublicKeyToString(_ publicKey: P256.KeyAgreement.PublicKey) -> String {
        let rawPublicKey = publicKey.rawRepresentation
        let base64PublicKey = rawPublicKey.base64EncodedString()
        let encodedPublicKey = base64PublicKey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        return encodedPublicKey
    }

    /// Convert a private key string into a private key object.
    /// - Parameter privateKey: The private key as a string to convert.
    /// - Throws: Throws if the private key string cannot be converted to an object due to wrong formatting.
    /// - Returns: The private key as an object.
    static func convertPrivateKeyStringToKey(_ privateKey: String) throws -> P256.KeyAgreement.PrivateKey {
        guard let privateKeyBase64 = privateKey.removingPercentEncoding else { throw CryptoHandlerError.keyInWrongFormat }
        guard let rawPrivateKey = Data(base64Encoded: privateKeyBase64) else { throw CryptoHandlerError.keyInWrongFormat }
        return try P256.KeyAgreement.PrivateKey(rawRepresentation: rawPrivateKey)
    }

    /// Convert a public key string into a public key object.
    /// - Parameter publicKey: The public key as a string to convert.
    /// - Throws: Throws if the public key string cannot be converted to an object due to wrong formatting.
    /// - Returns: The public key as an object.
    static func convertPublicKeyStringToKey(_ publicKey: String?) throws -> P256.KeyAgreement.PublicKey {
        guard let publicKey else { throw CryptoHandlerError.conversationKeyNotFound }
        guard let publicKeyBase64 = publicKey.removingPercentEncoding else { throw CryptoHandlerError.keyInWrongFormat }
        guard let rawPublicKey = Data(base64Encoded: publicKeyBase64) else { throw CryptoHandlerError.keyInWrongFormat }
        return try P256.KeyAgreement.PublicKey(rawRepresentation: rawPublicKey)
    }


    /// Derive the symmetric key to use for encryption.
    /// - Parameters:
    ///   - privateKey: The private key to use (yours)
    ///   - publicKey: The public key to use (the receiver of the message)
    /// - Throws: If the shared secret cannot be derived. Most likely due to wrong formatting.
    /// - Returns: The symmetric key to use for encryption.
    static func deriveSymmetricKey(privateKey: P256.KeyAgreement.PrivateKey, publicKey: P256.KeyAgreement.PublicKey) throws -> SymmetricKey {
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        return sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "My Key Agreement Salt".data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
    }

    /// Encrypt a string given a symmetric key.
    /// - Parameters:
    ///   - text: The string to encrypt.
    ///   - symmetricKey: The symmetric key to use.
    /// - Throws: If the encryption failed for some reason.
    /// - Returns: An encrypted string which is unreadable.
    static func encryptMessage(text: String, symmetricKey: SymmetricKey) throws -> String {
        guard let textData = text.data(using: .utf8) else { throw CryptoHandlerError.textCannotBeUtf8Converted }
        let encrypted = try AES.GCM.seal(textData, using: symmetricKey)
        guard let encryptedData = encrypted.combined else { throw CryptoHandlerError.textCannotBeEncrypted}
        return encryptedData.base64EncodedString()
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
    
    /// Reset public and private keys
    /// - Warning: Calling this function is disruptive and users will no longer be able to send and receive messages.
    static func resetKeys() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.privateKey.rawValue)
        let _ = fetchPublicKeyString()
    }
}
