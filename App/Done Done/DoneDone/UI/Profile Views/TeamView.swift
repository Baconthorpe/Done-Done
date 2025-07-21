//
//  TeamView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 7/17/25.
//

import SwiftUI
import Combine

struct TeamView: View {
    @EnvironmentObject var flow: Flow

    let team: Team

    @State var organizers: [Profile] = []
    @State var members: [Profile] = []

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            Text(team.name)

            Text("Members")
            List {
                ForEach(members) { member in
                    HStack {
                        Text(member.name)
                        if team.leaders.contains(member.id) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }.onAppear(perform: getMembers)

            NavigationLink(value: team) {
                Text("Invite A New Member")
            }
        }

        .navigationDestination(for: Team.self) { team in
            InviteToTeamView(team: team)
        }
    }

    func getMembers() {
        Provide.getTeamMembers(team)
            .sinkValue($members, logPrefix: "Get Team Members")
            .store(in: &cancellables)
    }
}
