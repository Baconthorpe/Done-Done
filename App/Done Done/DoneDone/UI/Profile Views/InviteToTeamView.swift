//
//  InvitePersonView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/21/25.
//

import SwiftUI
import Combine

struct InviteToTeamView: View {
    @EnvironmentObject var flow: Flow

    let team: Team

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

            List(selection: $selectedProfile) {
                ForEach(profiles) { profile in
                    Text(profile.name)
                }
            }
            .environment(\.editMode, .constant(.active))

            Button {
                sendInvitation()
            } label: {
                Text("Send Invitation")
            }
            .disabled(selectedProfile == nil)
        }
    }

    func search() {
        selectedProfile = nil
        Provide.searchForProfiles(name: nameSearch)
            .sinkValue($profiles, logPrefix: "Search Profiles")
            .store(in: &cancellables)
    }

    func sendInvitation() {
        guard let teamID = team.id, let selectedProfile else { return }
        Provide.sendTeamInvitation(team: teamID, teamName: team.name, recipient: selectedProfile.id)
            .sinkCompletion(logPrefix: "Invite To Group") { _ in
                flow.path.removeLast()
            }.store(in: &cancellables)
    }
}
