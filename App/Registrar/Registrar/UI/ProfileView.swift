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

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        Text(profile?.name ?? "")

        Text("Groups")
        List {
            ForEach(groups) { group in
                Text(group.name)
            }
        }
        .onAppear(perform: getGroups)
    }

    func getGroups() {
        Provide.getGroups().sink { completion in
            if case let .failure(error) = completion {
                log("Get Groups Failed: \(error)")
            }
        } receiveValue: { groups in
            log("Get Groups Succeeded - count: \(groups.count)", level: .verbose)
            self.groups = groups
        }.store(in: &cancellables)
    }
}
