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
    @EnvironmentObject var navigation: Navigation

    @State var email: String = ""

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            Text("Sign In")
            GoogleSignInButton().onTapGesture {
                signInWithGoogle()

            }
            Button("Skip For Now") {
                signInAnonymously()
            }
        }
    }

    func signInWithGoogle() {
        Provide.signInWithGoogle().sink { completion in
            if case let .failure(error) = completion {
                log("Sign In Failed: \(error)")
            }
        } receiveValue: { profile in
            log("Sign In Succeeded", level: .verbose)
            navigation.location = .signedIn(withProfile: profile != nil)
        }.store(in: &cancellables)
    }

    func signInAnonymously() {
        Provide.signInAnonymously().sink { completion in
            if case let .failure(error) = completion {
                log("Sign In Failed: \(error)")
            }
        } receiveValue: { profile in
            log("Sign In Succeeded", level: .verbose)
            navigation.location = .signedIn(withProfile: profile != nil)
        }.store(in: &cancellables)
    }

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
}

#Preview {
    SignInView()
}
