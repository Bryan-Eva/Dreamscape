//
//  CombineImageView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//

import SwiftUI

// MARK: CombineImageView
struct CombineImageView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()
            VStack {
                Text("Combine Image")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

            }
        }
    }
}