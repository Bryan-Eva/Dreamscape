//
//  User.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/14.
//

import FirebaseFirestore

struct User {
    var uid: String
    var name: String
    var avatar: String
    var createdAt: Timestamp
    var likedArticles: [String]
    var savedArticles: [String]
}

extension User {
    func toDictionary() -> [String: Any] {
        return [
            "uid": uid,
            "name": name,
            "avatar": avatar,
            "createdAt": createdAt,
            "likedArticles": likedArticles,
            "savedArticles": savedArticles
        ]
    }
}
