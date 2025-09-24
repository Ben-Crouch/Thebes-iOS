//
//  TopNavBarView.swift
//  Thebes
//
//  Created by Ben on 07/05/2025.
//

import SwiftUI

struct TopNavBarView: View {
    @Binding var showSideMenu: Bool
    // Removed invalid @Environment(\.safeAreaInsets)

    var body: some View {
        HStack {
            Button(action: {}) {}
                .padding(.trailing, 58)

            Spacer()

            Image("ThebesLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 60)

            Spacer()

            HStack {
                Button(action: {
                    // Handle notifications tap
                }) {
                    Image(systemName: "bell")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }
                Button(action: {
                    withAnimation {
                        showSideMenu.toggle()
                    }
                }) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 5)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}
