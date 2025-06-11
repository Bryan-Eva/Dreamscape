//
//  FirebaseService.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/11.
//
import FirebaseAuth

class FirebaseService {
    static func userRegister(
        mail: String,
        password: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        Auth.auth().createUser(withEmail: mail, password: password) {
            result,
            error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    static func userLogin(
        mail: String,
        password: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        Auth.auth().signIn(withEmail: mail, password: password) {
            result,
            error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    static func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
