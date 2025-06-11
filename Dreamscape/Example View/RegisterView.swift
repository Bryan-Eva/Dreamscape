//
//  RegisterView.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/11.
//

import SwiftUI

struct RegisterView: View {
    @State var mail = ""
    @State var password = ""
    @State var message = "Message"
    var body: some View {
        VStack(spacing: 16) {
            TextField("Mail", text: $mail)
                .textFieldStyle(.roundedBorder)
            TextField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            Button(action: {
                FirebaseService.userRegister(
                    mail: mail,
                    password: password,
                    completion: { success, error in
                        if success {
                            message = "register success"
                        } else {
                            if let _ = error {
                                message = error?.localizedDescription ?? "未知錯誤"
                            }
                        }
                    }
                )
            }) {
                Text("Register")
                    .padding(12)
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                    .cornerRadius(999)
            }
            Text(message)
        }
        .padding()
    }
}

#Preview {
    RegisterView()
}
