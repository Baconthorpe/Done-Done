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
        Text("EVENTS")

        List {
            ForEach(events) { event in
                Text(event.title)
            }
        }.onAppear(perform: getEvents)

        Button {
            navigation.current = .createEvent
        } label: {
            Text("Create Event")
        }
    }

    func getEvents() {
        Provide.getEvents().sink { completion in
            if case let .failure(error) = completion {
                log("Get Events Failed: \(error)")
            }
        } receiveValue: { events in
            log("Get Events Succeeded - count: \(events.count)", level: .verbose)
            self.events = events
        }.store(in: &cancellables)
    }
}
