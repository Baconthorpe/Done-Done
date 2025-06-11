//
//  CreateProfileView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/14/25.
//

import SwiftUI
import Combine

struct CreateProfileView: View {
    @EnvironmentObject var flow: Flow

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

        Provide.createProfile(name: name)
            .sinkCompletion(logPrefix: "Create Profile") { _ in
                flow.location = .signedIn(withProfile: true)
            }.store(in: &cancellables)
    }
}
