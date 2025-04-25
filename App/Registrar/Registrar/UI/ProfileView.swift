//
//  ProfileView.swift
//  Registrar
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
    @State var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {

            Text(profile?.name ?? "PROFILE")

            Text("Groups")
            List {
                ForEach(groups) { group in
                    NavigationLink(value: group) {
                        Text(group.name)
                    }
                }.onAppear(perform: getGroups)

                ForEach(groupInvitationsWithGroups) { invitationInfo in
                    Text(invitationInfo.invitation.sender)
                    Text(invitationInfo.group.name)
                }.onAppear(perform: getGroupInvitations)
            }

            .navigationDestination(for: Group.self) { group in
                GroupView(group: group)
            }

//            Text("Invitations")
//            List {
//                ForEach(groupInvitations) { invitation in
//                    Text(invitation.sender)
//                }
//            }
        }
    }

    func getGroups() {
        Provide.getMyGroups().sink { completion in
            if case let .failure(error) = completion {
                log("Get Groups Failed: \(error)")
            }
        } receiveValue: { groups in
            log("Get Groups Succeeded - count: \(groups.count)", level: .verbose)
            self.groups = groups
        }.store(in: &cancellables)
    }

    func getGroupInvitations() {
        Provide.getMyGroupInvitations().sink { completion in
            if case let .failure(error) = completion {
                log("Get Group Invitations Failed: \(error)")
            }
        } receiveValue: { invitations in
            log("Get Group Invitations Succeeded - count: \(invitations.count)", level: .verbose)
            self.groupInvitationsWithGroups = invitations
        }.store(in: &cancellables)
    }
}
