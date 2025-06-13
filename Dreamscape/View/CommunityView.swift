//
//  CommunityView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//

import SwiftUI

// MARK: CommunityView
struct CommunityView: View {
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            Text("Community")
                .font(.largeTitle)
                .foregroundColor(.primary)
                .padding()
        }
    }
}