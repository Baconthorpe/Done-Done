//
//  EventDetailsView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/15/25.
//

import SwiftUI
import Combine

struct EventDetailsView: View {
    let event: Event
    var userCanInvite: Bool {
        let profile = Local.profile!
        if event.creator == profile.userID || event.attending.contains(profile.userID) {
            return true
        }
        return false
    }

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

            if userCanInvite {
                NavigationLink("Invite Others", value: Flow.Go.invitingToEvent)
            }
        }
        .navigationTitle(event.title)
        .navigationDestination(for: Flow.Go.self) { flow in
            if flow == .invitingToEvent {
                InviteToEventView(event: event)
            }
        }
    }

    func getAttending() {
        Provide.getProfilesOfAttending(userIDs: event.attending)
            .sinkValue($attendingProfiles, logPrefix: "Get Attending Profiles")
            .store(in: &cancellables)
    }
}
