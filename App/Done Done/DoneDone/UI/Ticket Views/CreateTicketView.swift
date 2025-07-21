//
//  CreateTicketView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 7/15/25.
//

import SwiftUI
import Combine

struct CreateTicketView: View {
    @EnvironmentObject var flow: Flow

    @State var title: String = ""
    @State var description: String = ""
    @State var invalid: Bool = false

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            HStack{
                Text("Title: ")
                    .foregroundStyle(invalid ? .red : .primary)
                TextField("Do That Thing", text: $title)
                    .onChange(of: title) { invalid = false }
            }
            HStack{
                Text("Description: ")
                TextField("Get it done!", text: $description)
            }
            Button {
                createEvent()
            } label: {
                Text("Create Ticket")
            }
        }
    }

    func createEvent() {
        guard !title.isEmpty else {
            invalid = true
            return
        }

        Provide.createTicket(
            team: "",
            title: title,
            description: description
        ).sinkCompletion(logPrefix: "Create Ticket") { _ in
            flow.path.removeLast()
        }.store(in: &cancellables)
    }
}
