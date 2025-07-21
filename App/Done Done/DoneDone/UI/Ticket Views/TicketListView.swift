//
//  TicketListView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 7/11/25.
//

import SwiftUI
import Combine

struct TicketListView: View {
    @EnvironmentObject var flow: Flow

//    @State var eventInvitations: [EventInvitation] = []
    @State var tickets: [Ticket] = []

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        NavigationStack(path: $flow.path) {
            VStack {
                Text("TICKETS")
                List {
                    ForEach(tickets) { ticket in
                        NavigationLink(value: ticket) { Text(ticket.title) }
                    }
                }.onAppear(perform: getData)
                    .navigationDestination(for: Ticket.self) { ticket in
                        TicketDetailsView(ticket: ticket)
                    }

                NavigationLink("Create Ticket", value: Flow.Go.creatingTicket)

                NavigationLink("Create Team", value: Flow.Go.creatingTeam)
            }
            .navigationDestination(for: Flow.Go.self) { flow in
                if flow == .creatingTicket { CreateTicketView() }
                if flow == .creatingTeam { CreateTeamView() }
            }
        }
    }

    func getData() {
        Provide.getMyTickets()
            .sinkValue($tickets, logPrefix: "Get Tickets")
            .store(in: &cancellables)
    }
}
