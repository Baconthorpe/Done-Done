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
        Provide.getGroupOrganizers(group).sink { completion in
            if case let .failure(error) = completion {
                log("Get Group Organizers Failed: \(error)")
            }
        } receiveValue: { profiles in
            log("Search Profiles Succeeded - count: \(profiles.count)", level: .verbose)
            self.organizers = profiles
        }.store(in: &cancellables)
    }

    func getMembers() {
        Provide.getGroupMembers(group).sink { completion in
            if case let .failure(error) = completion {
                log("Get Group Organizers Failed: \(error)")
            }
        } receiveValue: { profiles in
            log("Search Profiles Succeeded - count: \(profiles.count)", level: .verbose)
            self.members = profiles
        }.store(in: &cancellables)
    }
}
