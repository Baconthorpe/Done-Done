//
//  SignInView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 1/6/25.
//

import SwiftUI
import GoogleSignIn
import Combine

struct SignInView: View {
    @EnvironmentObject var flow: Flow

    @State var email: String = ""
    @State var password: String = ""

    @State var presentingSignUpView: Bool = false
    @State var presentingSignInView: Bool = false

    @State var cancellables = Set<AnyCancellable>()

    // MARK: - UI
    var body: some View {
        ZStack {
            VStack {
                Text("Sign In")
                GoogleSignInButton().onTapGesture {
                    signInWithGoogle()
                }

                Button("Sign Up") { presentingSignUpView = true }
                Button("Sign In With Email") { presentingSignInView = true }
                Button("Skip For Now") { signInAnonymously() }
            }
            signUpSlideMenu
            signInSlideMenu
        }
    }

    // MARK: - Sign In Methods
    func signInWithGoogle() {
        Provide.signInWithGoogle()
            .sinkCompletion(logPrefix: "Sign In With Google") {
                flow.location = .signedIn(withProfile: $0 != nil)
            }.store(in: &cancellables)
    }

    func signUpWithEmail() {
        Provide.signUp(email: email, password: password)
            .sinkCompletion(logPrefix: "Email/Password Sign Up") {
                flow.location = .signedIn(withProfile: $0 != nil)
            }.store(in: &cancellables)
    }

    func signInWithEmail() {
        Provide.signIn(email: email, password: password)
            .sinkCompletion(logPrefix: "Email/Password Sign In") {
                flow.location = .signedIn(withProfile: $0 != nil)
            }.store(in: &cancellables)
    }

    func signInAnonymously() {
        Provide.signInAnonymously().sinkCompletion(logPrefix: "Anonymous Sign In") {
            flow.location = .signedIn(withProfile: $0 != nil)
        }.store(in: &cancellables)
    }

    // MARK: - Additional Views
    struct GoogleSignInButton: UIViewRepresentable {
        @Environment(\.colorScheme) var colorScheme

        private var button = GIDSignInButton()

        func makeUIView(context: Context) -> GIDSignInButton {
            button.colorScheme = colorScheme == .dark ? .dark : .light
            return button
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {
            button.colorScheme = colorScheme == .dark ? .dark : .light
        }
    }

    var signUpSlideMenu: some View {
        SlideMenu(isShowing: $presentingSignUpView,
                  content: AnyView(
                    VStack {
                        Text("Sign Up With Email")
                        HStack {
                            Text("Email: ")
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                        }
                        HStack {
                            Text("Password: ")
                            TextField("Password", text: $password)
                                .textContentType(.newPassword)
                        }
                        Button("Sign Up") {
                            signUpWithEmail()
                        }
                    }
                        .background(.white)
                        .safeAreaPadding(.bottom, 50)
                  ),
                  edgeTransition: .move(edge: .bottom)
        )
    }

    var signInSlideMenu: some View {
        SlideMenu(isShowing: $presentingSignInView,
                  content: AnyView(
                    VStack {
                        Text("Sign In With Email")
                        HStack {
                            Text("Email: ")
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                        }
                        HStack {
                            Text("Password: ")
                            TextField("Password", text: $password)
                                .textContentType(.password)
                        }
                        Button("Sign In") {
                            signInWithEmail()
                        }
                    }
                        .background(.white)
                        .safeAreaPadding(.bottom, 50)
                  ),
                  edgeTransition: .move(edge: .bottom)
        )
    }
}

#Preview {
    SignInView()
}
