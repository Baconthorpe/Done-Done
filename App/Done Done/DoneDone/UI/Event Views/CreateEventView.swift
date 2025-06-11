//
//  CreateEventView.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/7/25.
//

import SwiftUI
import Combine

struct CreateEventView: View {
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
                TextField("My Party", text: $title)
                    .onChange(of: title) { invalid = false }
            }
            HStack{
                Text("Description: ")
                TextField("Cry if I want to", text: $description)
            }
            Button {
                createEvent()
            } label: {
                Text("Create Event")
            }
        }
    }

    func createEvent() {
        guard !title.isEmpty else {
            invalid = true
            return
        }

        Provide.createEvent(
            title: title,
            description: description
        ).sinkCompletion(logPrefix: "Create Event") { _ in
            flow.path.removeLast()
        }.store(in: &cancellables)
    }
}
