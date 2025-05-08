//
//  MainSignedInView.swift
//  Registrar
//
//  Created by Ezekiel Abuhoff on 4/22/25.
//

import SwiftUI
import Combine

struct MainSignedInView: View {
    @EnvironmentObject var flow: Flow

    @State var cancellables = Set<AnyCancellable>()

    var body: some View {
        TabView {
            Tab("Events", image: "calendar_icon") { EventListView() }
            Tab("Profile", image: "profile_icon") { ProfileView() }
        }
    }
}
