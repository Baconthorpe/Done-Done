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
    @State var teamInvitations = [TeamInvitation]()

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
                }.onAppear(perform: getTeams)

                ForEach(teamInvitations) { invitation in
                    HStack {
                        VStack {
                            Text("You've been invited to \(invitation.info.teamName)")
                            Text("by \(invitation.info.senderName)")
                        }
                        Button("Accept") { accept(invitation: invitation) }
                        Button("Decline") { decline(invitation: invitation) }
                    }
                    Text(invitation.info.senderName)
                    Text(invitation.info.teamName)
                }.onAppear(perform: getTeamInvitations)
            }

            .navigationDestination(for: Team.self) { team in
                TeamView(team: team)
            }
        }
    }

    func getTeams() {
        Provide.getMyTeams()
            .sinkValue($groups, logPrefix: "Get Teams")
            .store(in: &cancellables)
    }

    func getTeamInvitations() {
        Provide.getMyTeamInvitations()
            .sinkValue($teamInvitations, logPrefix: "Get Team Invitations")
            .store(in: &cancellables)
    }

    func accept(invitation: TeamInvitation) {
        Provide.acceptTeamInvitation(invitation)
            .sinkCompletion(logPrefix: "Accept Invitation") { getTeams(); getTeamInvitations() }
            .store(in: &cancellables)
    }

    func decline(invitation: TeamInvitation) {
        Provide.declineTeamInvitation(invitation)
            .sinkCompletion(logPrefix: "Decline Invitation") { getTeamInvitations() }
            .store(in: &cancellables)
    }
}
