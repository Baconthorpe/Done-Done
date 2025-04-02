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
    @State var email: String = ""

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            Text("Sign In")
            GoogleSignInButton().onTapGesture {
                // Sign In With Google
                signInWithGoogle()

            }
            Button("Skip For Now") {
                // Sign In Anonymously
                signInAnonymously()
            }
        }
    }

    func signInWithGoogle() {
        Provide.signInWithGoogle().sink { error in
            print("Sign In Failed")
        } receiveValue: { signedIn in
            print("Sign In Succeeded")
        }.store(in: &cancellables)
    }

    func signInAnonymously() {
        Provide.signInAnonymously().sink { error in
            print("Sign In Failed")
        } receiveValue: { signedIn in
            print("Sign In Succeeded")
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
