//
//  ProfileView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/22/25.
//

import SwiftUI
import Combine

struct ProfileView: View {
    @EnvironmentObject var flow: Flow

    @State var profile: Profile? = { Local.profile }()
    @State var groups: [Group] = []
    @State var groupInvitationsWithGroups = [GroupInvitation.WithGroup]()

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        NavigationStack(path: $flow.path) {

            Text(profile?.name ?? "PROFILE")

            Text("Groups")
            List {
                ForEach(groups) { group in
                    NavigationLink(value: group) {
                        Text(group.name)
                    }
                }.onAppear(perform: getGroups)

                ForEach(groupInvitationsWithGroups) { invitationInfo in
                    HStack {
                        VStack {
                            Text("You've been invited to \(invitationInfo.group.name)")
                            Text("by \(invitationInfo.invitation.sender)")
                        }
                        Button("Accept") { accept(invitation: invitationInfo.invitation) }
                        Button("Decline") { decline(invitation: invitationInfo.invitation) }
                    }
                    Text(invitationInfo.invitation.sender)
                    Text(invitationInfo.group.name)
                }.onAppear(perform: getGroupInvitations)
            }

            .navigationDestination(for: Group.self) { group in
                GroupView(group: group)
            }
        }
    }

    func getGroups() {
        Provide.getMyGroups()
            .sinkValue($groups, logPrefix: "Get Groups")
            .store(in: &cancellables)
    }

    func getGroupInvitations() {
        Provide.getMyGroupInvitations()
            .sinkValue($groupInvitationsWithGroups, logPrefix: "Get Group Invitations")
            .store(in: &cancellables)
    }

    func accept(invitation: GroupInvitation) {
        Provide.acceptGroupInvitation(invitation)
            .sinkCompletion(logPrefix: "Accept Invitation") { getGroups(); getGroupInvitations() }
            .store(in: &cancellables)
    }

    func decline(invitation: GroupInvitation) {
        Provide.declineGroupInvitation(invitation)
            .sinkCompletion(logPrefix: "Decline Invitation") { getGroupInvitations() }
            .store(in: &cancellables)
    }
}
