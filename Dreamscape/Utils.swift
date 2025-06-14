//
//  Utils.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/14.
//

import FirebaseFirestore

class Utils {
    static func docToUser(doc: DocumentSnapshot) -> User? {
        guard let data = doc.data(),
            let name = data["name"] as? String,
            let avatar = data["avatar"] as? String,
            let likedArticles = data["likedArticles"] as? [String],
            let savedArticles = data["savedArticles"] as? [String],
            let createdAt = data["createdAt"] as? Timestamp

        else {
            return nil
        }
        return User(
            uid: doc.documentID,
            name: name,
            avatar: avatar,
            createdAt: createdAt,
            likedArticles: likedArticles,
            savedArticles: savedArticles
        )
    }

    static func docToArticle(doc: DocumentSnapshot) -> Article? {
        guard let data = doc.data(),
            let title = data["title"] as? String,
            let content = data["content"] as? String,
            let authorUid = data["authorUid"] as? String,
            let createdAt = data["createdAt"] as? Timestamp,
            let photo = data["photo"] as? String
        else {
            return nil
        }
        return Article(
            id: doc.documentID,
            title: title,
            authorUid: authorUid,
            content: content,
            photo: photo,
            createdAt: createdAt
        )
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
