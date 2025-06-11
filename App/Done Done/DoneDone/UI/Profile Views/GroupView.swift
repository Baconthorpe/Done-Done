//
//  GroupView.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/21/25.
//

import SwiftUI
import Combine

struct GroupView: View {
    @EnvironmentObject var flow: Flow

    let group: Group

    @State var organizers: [Profile] = []
    @State var members: [Profile] = []

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            Text(group.name)

            Text("Members")
            List {
                ForEach(members) { member in
                    HStack {
                        Text(member.name)
                        if group.organizers.contains(member.id) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }.onAppear(perform: getMembers)

            NavigationLink(value: group) {
                Text("Invite A New Member")
            }
        }

        .navigationDestination(for: Group.self) { group in
            InviteToGroupView(group: group)
        }
    }

    func getMembers() {
        Provide.getGroupMembers(group)
            .sinkValue($members, logPrefix: "Get Group Members")
            .store(in: &cancellables)
    }
}
