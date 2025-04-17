//
//  CreateProfileView.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/14/25.
//

import SwiftUI
import Combine

struct CreateProfileView: View {
    @EnvironmentObject var navigation: Navigation

    @State private var name: String = ""
    @State var invalid: Bool = false

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        Text("Create Profile")

        Text("To get started, let's just take down some basic information about you.")

        HStack{
            Text("Name: ")
                .foregroundStyle(invalid ? .red : .primary)
            TextField("Marmalade", text: $name)
                .onChange(of: name) { invalid = false }
        }

        Button {
            createProfile()
        } label: {
            Text("Create Profile")
        }
    }

    func createProfile() {
        guard !name.isEmpty else {
            invalid = true
            return
        }

        Provide.createProfile(name: name).sink { completion in
            if case let .failure(error) = completion {
                log("Create Profile Failed: \(error)")
            }
        } receiveValue: { newProfile in
            log("Created Profile: \(newProfile)", level: .verbose)
            navigation.location = .signedIn(withProfile: true)
        }.store(in: &cancellables)
    }
}
