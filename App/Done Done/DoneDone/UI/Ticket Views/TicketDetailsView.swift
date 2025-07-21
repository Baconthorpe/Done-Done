//
//  TicketDetailsView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 7/14/25.
//

import SwiftUI
import Combine

struct TicketDetailsView: View {
    let ticket: Ticket
//    var userCanInvite: Bool {
//        let profile = Local.profile!
//        if event.creator == profile.userID || event.attending.contains(profile.userID) {
//            return true
//        }
//        return false
//    }

    @State var attendingProfiles: [Profile] = []

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            Text(ticket.description)

            Text("Attending")
                .onAppear(perform: getAttending)
            List {
                ForEach(attendingProfiles) { profile in
                    Text(profile.name)
                }
            }

//            if userCanInvite {
//                NavigationLink("Invite Others", value: Flow.Go.invitingToEvent)
//            }
        }
        .navigationTitle(ticket.title)
        .navigationDestination(for: Flow.Go.self) { _ in
//            if flow == .invitingToEvent {
//                InviteToEventView(event: event)
//            }
        }
    }

    func getAttending() {
//        Provide.getProfilesOfAttending(userIDs: event.attending)
//            .sinkValue($attendingProfiles, logPrefix: "Get Attending Profiles")
//            .store(in: &cancellables)
    }
}
