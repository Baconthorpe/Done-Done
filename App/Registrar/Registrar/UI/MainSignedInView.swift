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
            Tab("Events", image: "") { EventListView() }
            Tab("Profile", image: "") { ProfileView() }
        }
    }
}
