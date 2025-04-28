//
//  FirebaseSignIn.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/28/25.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

// MARK: - Sign In Methods
extension FirebaseHandler {
    static func signInWithGoogle() -> Future<Void, Error> {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            return refreshSignInWithGoogle()
        } else {
            return initiateFreshSignInWithGoogle()
        }
    }

    private static func refreshSignInWithGoogle() -> Future<Void, Error> {
        Future { promise in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if let error = error {
                    promise(Result.failure(Failure.firebase(error)))
                    return
                }
                guard user != nil else {
                    promise(Result.failure(Failure.unknown))
                    return
                }

                promise(Result.success(()))
            }
        }
    }

    private static func initiateFreshSignInWithGoogle() -> Future<Void, Error> {
        Future { promise in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController,
                  let clientID = FirebaseApp.app()?.options.clientID
            else {
                promise(Result.failure(Failure.unknown))
                return
            }

            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                guard error == nil,
                      let user = result?.user,
                      let idToken = user.idToken?.tokenString
                else {
                    promise(Result.failure(Failure.unknown))
                    return
                }

                let signInCredential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                 accessToken: user.accessToken.tokenString)
                completeSignIn(with: signInCredential, promise: promise)
            }
        }
    }

    private static func completeSignIn(with credential: AuthCredential,
                                       promise: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                promise(Result.failure(Failure.firebase(error)))
                return
            }
            promise(Result.success(()))
        }
    }

    static func createUser(email: String, password: String) -> Future<Void, Error> {
        Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    promise(Result.failure(Failure.firebase(error)))
                    return
                }
                promise(Result.success(()))
            }
        }
    }

    static func signIn(email: String, password: String) -> Future<Void, Error> {
        Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    promise(Result.failure(error))
                    return
                }
                guard let _ = authResult?.user.uid else {
                    promise(Result.failure(Failure.unknown))
                    return
                }
                promise(Result.success(()))
            }
        }
    }

    static func signInAnonymously() -> Future<Void, Error> {
        Future { promise in
            Auth.auth().signInAnonymously() { authResult, error in
                if let error = error {
                    promise(Result.failure(error))
                    return
                }
                promise(Result.success(()))
            }
        }
    }
}
