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

            Text("Organizers")
            List {
                ForEach(organizers) {
                    Text($0.name)
                }
            }.onAppear(perform: getOrganizers)

            Text("Members")
            List {
                ForEach(members) {
                    Text($0.name)
                }
            }.onAppear(perform: getMembers)
        }
    }

    func getOrganizers() {
        Provide.getGroupOrganizers(group)
            .sinkValue($organizers, logPrefix: "Get Group Organizers")
            .store(in: &cancellables)
    }

    func getMembers() {
        Provide.getGroupMembers(group)
            .sinkValue($members, logPrefix: "Get Group Members")
            .store(in: &cancellables)
    }
}
