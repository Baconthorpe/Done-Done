//
//  EventListView.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/7/25.
//

import SwiftUI
import Combine

struct EventListView: View {
    @EnvironmentObject var navigation: Navigation

    @State var events: [Event] = []

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        NavigationView {
            Text("EVENTS")

            List {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailsView(event: event)) {
                        Text(event.title)
                    }
                }
            }.onAppear(perform: getEvents)

            Button {
                navigation.location = .createEvent
            } label: {
                Text("Create Event")
            }

            Button {
                navigation.location = .createGroup
            } label: {
                Text("Create Group")
            }
        }
    }

    func getEvents() {
        Provide.getMyEvents().sink { completion in
            if case let .failure(error) = completion {
                log("Get Events Failed: \(error)")
            }
        } receiveValue: { events in
            log("Get Events Succeeded - count: \(events.count)", level: .verbose)
            self.events = events
        }.store(in: &cancellables)
    }
}
