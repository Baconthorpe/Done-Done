//
//  SignInView.swift
//  Registrar
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
        Provide.signInWithGoogle().sink { completion in
            if case let .failure(error) = completion {
                log("Sign In Failed: \(error)")
            }
        } receiveValue: { profile in
            log("Sign In Succeeded", level: .verbose)
            flow.location = .signedIn(withProfile: profile != nil)
        }.store(in: &cancellables)
    }

    func signUpWithEmail() {
        Provide.signUp(email: email, password: password).sink { completion in
            if case let .failure(error) = completion {
                log("Email/Password Sign Up Failed: \(error)")
            }
        } receiveValue: { profile in
            log("Email/Password Sign Up Succeeded", level: .verbose)
            flow.location = .signedIn(withProfile: profile != nil)
        }.store(in: &cancellables)
    }

    func signInWithEmail() {
        Provide.signIn(email: email, password: password).sink { completion in
            if case let .failure(error) = completion {
                log("Email/Password Sign In Failed: \(error)")
            }
        } receiveValue: { profile in
            log("Email/Password Sign In Succeeded", level: .verbose)
            flow.location = .signedIn(withProfile: profile != nil)
        }.store(in: &cancellables)
    }

    func signInAnonymously() {
        Provide.signInAnonymously().sink { completion in
            if case let .failure(error) = completion {
                log("Anonymous Sign In Failed: \(error)")
            }
        } receiveValue: { profile in
            log("Anonymous Sign In Succeeded", level: .verbose)
            flow.location = .signedIn(withProfile: profile != nil)
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
