//
//  EventDetailsView.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/15/25.
//

import SwiftUI
import Combine

struct EventDetailsView: View {
    let event: Event
    @State var attendingProfiles: [Profile] = []

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            Text(event.description)
            
            Text("Attending")
                .onAppear(perform: getAttending)
            List {
                ForEach(attendingProfiles) { profile in
                    Text(profile.name)
                }
            }
        }.navigationTitle(event.title)
    }

    func getAttending() {
        Provide.getProfilesOfAttending(userIDs: event.attending)
            .sinkValue($attendingProfiles, logPrefix: "Get Attending Profiles")
            .store(in: &cancellables)
    }
}
