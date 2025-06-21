//
//  LaunchView.swift
//  BumperPick
//
//  Created by tauseef hussain on 20/05/25.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        VStack {
                Image("theme2") // Use your actual background image
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            }
    }
}

#Preview {
    LaunchView()
}
