import CryptoKit
import Foundation
import SwiftKeychainWrapper

struct EncryptionManager {
    private let keyIdentifier = "encryptionKey"
    private let encryptionKey: SymmetricKey
   
    init() {
        if let savedKeyData = KeychainWrapper.standard.data(forKey: keyIdentifier) {
            encryptionKey = SymmetricKey(data: savedKeyData)
            //print(" Key successfully retrieved from Keychain")
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            KeychainWrapper.standard.set(keyData, forKey: keyIdentifier)
            encryptionKey = newKey
            //print("New symmetric key generated and stored in Keychain")
        }
    }

   
    func encrypt(plainText: String) -> String? {
        guard let data = plainText.data(using: .utf8) else { return nil }
    
        do {
            let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
            return sealedBox.combined?.base64EncodedString()
        } catch {
            print("Encryption error: \(error.localizedDescription)")
            return nil
        }
    }

   
    func decrypt(encryptedText: String) -> String? {
        guard let data = Data(base64Encoded: encryptedText) else { return nil }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption error: \(error.localizedDescription)")
            return nil
        }
    }
}


/*
 // Function to encrypt a message
 func encryptMessage(_ message: String, using key: SymmetricKey) throws -> Data {
     let messageData = message.data(using: .utf8)!
     let sealedBox = try AES.GCM.seal(messageData, using: key)
     return sealedBox.combined!
 }

 // Function to decrypt a message
 func decryptMessage(_ encryptedData: Data, using key: SymmetricKey) throws -> String {
     let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
     let decryptedData = try AES.GCM.open(sealedBox, using: key)
     return String(data: decryptedData, encoding: .utf8)!
 }
 */
