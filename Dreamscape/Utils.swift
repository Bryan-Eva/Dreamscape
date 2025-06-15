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
        guard let data = doc.data() else { return nil }

        // 從 Dictionary 取出欄位，注意型別轉換和預設值
        guard
            let authorUid = data["authorUid"] as? String,
            let emotions = data["emotions"] as? [String],
            let image = data["image"] as? String,
            let likedCount = data["likedCount"] as? Int,
            let savedCount = data["savedCount"] as? Int,
            let text = data["text"] as? String,
            let time = data["time"] as? Timestamp,
            let title = data["title"] as? String,
            let topics = data["topics"] as? [String],
            let visible = data["visible"] as? Bool
        else {
            return nil
        }

        // id 從 doc.documentID 取得
        let id = doc.documentID

        return Article(
            id: id,
            authorUid: authorUid,
            emotions: emotions,
            image: image,
            likedCount: likedCount,
            savedCount: savedCount,
            text: text,
            time: time,
            title: title,
            topics: topics,
            visible: visible
        )
    }

    static func docToComment(doc: DocumentSnapshot) -> Comment? {
        guard let data = doc.data() else { return nil }

        guard
            let text = data["text"] as? String,
            let articleId = data["articleId"] as? String,
            let time = data["time"] as? Timestamp,
            let uid = data["uid"] as? String
        else {
            return nil
        }

        let id = doc.documentID

        return Comment(
            id: id,
            articleId: articleId,
            text: text,
            time: time,
            uid: uid
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
