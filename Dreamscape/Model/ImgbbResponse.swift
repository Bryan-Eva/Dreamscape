//
//  ImgbbResponse.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/14.
//

struct ImgbbResponse: Codable {
    struct Data: Codable {
        let url: String
    }
    let data: Data
    let success: Bool
    let status: Int
}
