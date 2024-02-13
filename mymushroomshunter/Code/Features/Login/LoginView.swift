//
//  LoginView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            Color.black
            
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.green, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 1000, height: 400)
                .rotationEffect(.degrees(135))
                .offset(y: -350)
            
            VStack(spacing: 20) {
                Text("Welcome")
                    .foregroundStyle(.white)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .offset(x: -100, y: -100)
                
                TextField("Email", text: $email)
                    .foregroundStyle(.white)
                    .autocapitalization(.none)
                    .textFieldStyle(.plain)
                    .placeholder(when: email.isEmpty) {
                        Text("Email").foregroundStyle(.white)
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundStyle(.white)
                
                SecureField("Password", text: $password)
                    .foregroundStyle(.white)
                    .textFieldStyle(.plain)
                    .placeholder(when: password.isEmpty) {
                        Text("Password").foregroundStyle(.white)
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundStyle(.white)
                
                Button {
                    // sign in
                } label: {
                    Text("Sign In")
                        .bold()
                        .frame(width: 200, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.green)
                        )
                        .foregroundStyle(.white)
                }
                .padding(.top)
                .offset(y: 100)
                
                Button {
                    signUp()
                } label: {
                    Text("Don't have an account? Sign up!")
                        .bold()
                        .foregroundStyle(.white)
                }
                .offset(y: 110)
            }
            .frame(width: 350)
            .padding()
        }
        .ignoresSafeArea()
    }
   
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                // TODO - add alert
                print(error!.localizedDescription)
            }
        }
    }
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                // TODO - add alert
                print(error!.localizedDescription)
            }
            
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    LoginView()
}
