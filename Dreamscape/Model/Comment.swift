//
//  Comment.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/15.
//

import FirebaseFirestore

struct Comment: Identifiable {
    var id: String  // Firebase 文件 ID
    var articleId: String
    var text: String
    var time: Timestamp
    var uid: String

    // 用來上傳到 Firestore
    func toDictionary() -> [String: Any] {
        return [
            "articleId": articleId,
            "text": text,
            "time": time,
            "uid": uid,
        ]
    }
}
