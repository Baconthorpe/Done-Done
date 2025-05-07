//
//  InvitePersonView.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/21/25.
//

import SwiftUI
import Combine

struct InvitePersonView: View {
    @EnvironmentObject var flow: Flow

    @State private var nameSearch: String = ""
    @State private var profiles: [Profile] = []
    @State private var selectedProfile: Profile? = nil

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            Text("Invite a Friend")

            HStack {
                Text("Search by Name: ")
                TextField("Shaggy", text: $nameSearch)
                    .onSubmit(search)
            }

            List {
                ForEach(profiles) { profile in
                    Text(profile.name)
                }
            }

            Button {
                sendInvitation()
            } label: {
                Text("Send Invitation")
            }
        }
    }

    func search() {
        Provide.searchForProfiles(name: nameSearch)
            .sinkValue($profiles, logPrefix: "Search Profiles")
            .store(in: &cancellables)
    }

    func sendInvitation() {
//        Provide.sendGroupInvitation(group: <#T##String#>, recipient: <#T##String#>)
    }
}
