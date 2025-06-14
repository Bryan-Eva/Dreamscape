//
//  Article.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/14.
//

import FirebaseFirestore

struct Article: Identifiable {
    var id: String
    var authorUid: String
    var emotions: [String]
    var image: String
    var likedCount: Int
    var savedCount: Int
    var text: String
    var time: Timestamp
    var title: String
    var topics: [String]
    var visible: Bool

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "authorUid": authorUid,
            "emotions": emotions,
            "image": image,
            "likedCount": likedCount,
            "savedCount": savedCount,
            "text": text,
            "time": time,
            "title": title,
            "topics": topics,
            "visible": visible,
        ]
    }
}
