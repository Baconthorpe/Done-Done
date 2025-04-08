//
//  CreateEventView.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/7/25.
//

import SwiftUI
import Combine

struct CreateEventView: View {
    @EnvironmentObject var navigation: Navigation

    @State var title: String = ""
    @State var description: String = ""

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            HStack{
                Text("Title: ")
                TextField("My Party", text: $title)
            }
            HStack{
                Text("Description: ")
                TextField("Cry if I want to", text: $description)
            }
            Button {
                print("BURP")
                createEvent()
            } label: {
                Text("Create Event")
            }
        }
    }

    func createEvent() {
        Provide.createEvent(
            title: title,
            description: description
        ).sink { completion in
            if case let .failure(error) = completion {
                print("Create Event Failed: \(error)")
            }
        } receiveValue: { created in
            print("Event created")
            navigation.current = .listEvents
        }.store(in: &cancellables)
    }
}
