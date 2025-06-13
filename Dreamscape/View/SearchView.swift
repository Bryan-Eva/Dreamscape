//
//  SearchView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//

import SwiftUI

// MARK: SearchView
struct SearchView: View {
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            Text("Search")
                .font(.largeTitle)
                .foregroundColor(.primary)
                .padding()
        }
    }
}