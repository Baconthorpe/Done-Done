//
//  EventInviteView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 5/14/25.
//

import SwiftUI
import Combine

struct InviteToEventView: View {
    @EnvironmentObject var flow: Flow

    let event: Event

    @State private var potentialInvites: [Profile] = []
    @State private var selectedProfiles: Set<Profile> = []

    @State private var cancellables: Set<AnyCancellable> = []

    var body: some View {
        List(potentialInvites, selection: $selectedProfiles) { profile in
            Text(profile.name)
        }
        .environment(\.editMode, .constant(.active))
        .onAppear(perform: getPotentialInvites)

        Button("Invite") { sendInvites() }
    }

    func getPotentialInvites() {
        Provide.getProfilesForMembersOfMyGroups()
            .sinkValue($potentialInvites, logPrefix: "Get Profiles Of User's Groups")
            .store(in: &cancellables)
    }

    func sendInvites() {
        Provide.sendEventInvitations(
            event: event,
            recipients: Array(selectedProfiles)
        ).sinkCompletion(logPrefix: "Send Event Invitations") { _ in
            flow.path.removeLast()
        }.store(in: &cancellables)
    }
}

