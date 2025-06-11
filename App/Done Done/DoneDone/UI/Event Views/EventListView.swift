//
//  EventListView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/7/25.
//

import SwiftUI
import Combine

struct EventListView: View {
    @EnvironmentObject var flow: Flow

    @State var eventInvitations: [EventInvitation] = []
    @State var events: [Event] = []

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        NavigationStack(path: $flow.path) {
            VStack {
                if !events.isEmpty { Text("INVITATIONS") }
                List {
                    ForEach(eventInvitations) { eventInvitation in
                        HStack {
                            VStack {
                                Text("You're invited to \(eventInvitation.eventName)")
                                Text("by \(eventInvitation.senderName)")
                            }
                            VStack {
                                Button("Accept") { accept(invitation: eventInvitation) }
                                Button("Decline") { decline(invitation: eventInvitation) }
                            }
                        }
                    }
                }

                Text("EVENTS")
                List {
                    ForEach(events) { event in
                        NavigationLink(value: event) { Text(event.title) }
                    }
                }.onAppear(perform: getData)
                    .navigationDestination(for: Event.self) { event in
                        EventDetailsView(event: event)
                    }

                NavigationLink("Create Event", value: Flow.Go.creatingEvent)

                NavigationLink("Create Group", value: Flow.Go.creatingGroup)
            }
            .navigationDestination(for: Flow.Go.self) { flow in
                if flow == .creatingEvent { CreateEventView() }
                if flow == .creatingGroup { CreateGroupView() }
            }
        }
    }

    func getData() {
        Provide.getEventInvitations()
            .sinkValue($eventInvitations, logPrefix: "Get Event Invitations")
            .store(in: &cancellables)

        Provide.getMyEvents()
            .sinkValue($events, logPrefix: "Get Events")
            .store(in: &cancellables)
    }

    func accept(invitation: EventInvitation) {
        Provide.acceptEventInvitation(invitation)
            .sinkCompletion(logPrefix: "Accept Event Invitation \(invitation.eventName)") { getData() }
            .store(in: &cancellables)
    }

    func decline(invitation: EventInvitation) {
        Provide.declineEventInvitation(invitation)
            .sinkCompletion(logPrefix: "Decline Event Invitation \(invitation.eventName)") { getData() }
            .store(in: &cancellables)
    }
}
