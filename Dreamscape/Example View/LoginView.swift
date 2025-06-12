//
//  LoginView.swift
//  Dreamscape
//
//  Created by Vivian Chen on 2025/6/12.
//

import SwiftUI

struct LoginView: View {
    @State var mail = ""
    @State var password = ""
    @State var message = "Message"
    @State var isLogin = FirebaseService.isUserLoggedIn()
    var body: some View {
        VStack(spacing: 16) {
            TextField("Mail", text: $mail)
                .textFieldStyle(.roundedBorder)
            TextField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            Button(action: {
                FirebaseService.userLogin(
                    mail: mail,
                    password: password,
                    completion: { success, error in
                        if success {
                            message = "login success"
                        } else {
                            if error != nil {
                                message = error?.localizedDescription ?? "未知錯誤"
                            }
                        }
                        isLogin = FirebaseService.isUserLoggedIn()
                    }
                )
            }) {
                Text("Login")
                    .padding(12)
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                    .cornerRadius(999)
            }
            if isLogin {
                Button(action: {
                    FirebaseService.userLogout(completion: { success, error in
                        if success {
                            message = "logout success"
                        }else{
                            if error != nil {
                                message = error?.localizedDescription ?? "未知錯誤"
                            }
                        }
                    })
                    isLogin = FirebaseService.isUserLoggedIn()
                }) {
                    Text("Logout")
                        .padding(12)
                        .foregroundStyle(Color.white)
                        .background(Color.red)
                        .cornerRadius(999)
                }
            }
            Text(message)
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
