//
//  RegistrarApp.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 10/11/24.
//

import SwiftUI
import SwiftData

@main
struct RegistrarApp: App {
    @StateObject var navigation = Navigation()

    init() {
        FirebaseHandler.startUp()
        Logging.mode = .silent
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            switch navigation.location {
            case .signIn: SignInView()
            case .createProfile: CreateProfileView()
            case .listEvents: EventListView()
            case .createEvent: CreateEventView()
            case .createGroup: CreateGroupView()
            }
        }
        .environmentObject(navigation)
        .modelContainer(sharedModelContainer)
    }
}
