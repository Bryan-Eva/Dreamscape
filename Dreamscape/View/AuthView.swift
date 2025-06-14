//
//  AuthView.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//

import SwiftUI

// MARK: - Main View
struct AuthView: View {
    @State private var isLoginMode: Bool = true

    var body: some View {
        ZStack {
            // Background
            // call Static Background
            //GeometryReader { geo in
            //    StarfieldBackground(width: geo.size.width, height: geo.size.height)
            //}
            // call Dynamic Background
            AnimatedStarfieldBackground(starCount: 72)
                .ignoresSafeArea()
            
            VStack {
                // Title
                Text("Welcome to Dreamscape")
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .padding(.top, 80)
                
                Spacer()

                // Main Content
                ZStack {
                    if isLoginMode {
                        LogInView {
                            withAnimation(.easeInOut) {
                                isLoginMode = false
                            }
                        }
                        .transition(.move(edge: .trailing))
                    } else {
                        SignUpView {
                            withAnimation(.easeInOut) {
                                isLoginMode = true
                            }
                        }
                        .transition(.move(edge: .leading))
                    }
                }
                .frame(maxWidth: 400)
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .padding()
        }
    }
}


// MARK: - Login Sub View
struct LogInView: View {
    var switchToSignup: () -> Void

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 24) {
            // Email Input
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                .foregroundColor(.white)

            // Password Input
            SecureField("Password", text: $password)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                .foregroundColor(.white)

            // Login Button
            Button(action: {
                // TODO: Handle login action
            }) {
                Text("Log In")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [Color.purple.opacity(0.8), Color.purple], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }

            // Switch to Signup
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.white.opacity(0.7))
                Button(action: switchToSignup) {
                    Text("Sign Up")
                        .foregroundColor(.purple)
                        .fontWeight(.bold)
                }
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 32)
        .animation(nil, value: UUID())
    }
}

// MARK: - Signup Sub View
struct SignUpView: View  {
    var switchToLogin: () -> Void

    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Email Input
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                .foregroundColor(.white)

            // Password Input
            SecureField("Password", text: $password)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                .foregroundColor(.white)

            // Signup Button
            Button(action: {
                // TODO: Handle signup action
            }) {
                Text("Sign Up")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [Color.purple.opacity(0.8), Color.purple], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }

            // Switch to Login
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.white.opacity(0.7))
                Button(action: switchToLogin) {
                    Text("Log In")
                        .foregroundColor(.purple)
                        .fontWeight(.bold)
                }
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 32)
        .animation(nil, value: UUID())
    }
}

// MARK: - Starfield Background(Static)
struct StarfieldBackground: View {
    let starCount: Int
    let width: CGFloat
    let height: CGFloat

    // Precompute star data to avoid changing every redraw
    private let stars: [Star]

    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let radius: CGFloat
        let opacity: Double
    }

    init(starCount: Int = 60, width: CGFloat = 400, height: CGFloat = 800) {
        self.starCount = starCount
        self.width = width
        self.height = height
        self.stars = (0..<starCount).map { _ in
            Star(
                x: CGFloat.random(in: 0...width),
                y: CGFloat.random(in: 0...height),
                radius: CGFloat.random(in: 0.8...2.2),
                opacity: Double.random(in: 0.5...1.0)
            )
        }
    }

    var body: some View {
        ZStack {
            // Background Colors can be adjusted for aesthetic preference
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.9), Color.black]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Stars
            ForEach(stars) { star in
                Circle()
                    .fill(Color.white.opacity(star.opacity))
                    .frame(width: star.radius * 2, height: star.radius * 2)
                    .position(x: star.x, y: star.y)
            }
        }
    }
}


// MARK: - Preview
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .preferredColorScheme(.dark)
    }
}