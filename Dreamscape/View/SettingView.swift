//
//  SettingView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//

import SwiftUI

// MARK: SettingView
struct SettingView: View {
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            Text("Settings")
                .font(.largeTitle)
                .foregroundColor(.primary)
                .padding()
        }
    }
}