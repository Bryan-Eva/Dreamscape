//
//  Article.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/14.
//

import FirebaseFirestore

struct Article: Identifiable {
    var id: String
    var title: String
    var authorUid: String
    var content: String
    var photo: String
    var createdAt: Timestamp
}
