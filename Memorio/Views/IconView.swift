//
//  IconView.swift
//  Memorio
//
//  Created by Michal Dobes on 11/09/2020.
//

import SwiftUI

struct IconView: View {
    @ObservedObject private var iconViewModel = IconViewModel()
    @Binding var presentSubscriptionOptions: Bool
    
    var body: some View {
        VStack {
            ScrollView {
                TitleView(text: "Icon")
                VStack {
                    Group {
                        iconButton(imageName: "Icon", name: "Normal", setDefaultIcon: true)
                        Divider()
                        iconButton(imageName: "InsideOut", name: "Inverted inside")
                        Divider()
                        iconButton(imageName: "Flat", name: "Flat")
                        Divider()
                        iconButton(imageName: "Depth", name: "Depth")
                        Divider()
                        iconButton(imageName: "BlackAndWhite", name: "Black and White")
                        Divider()
                    }
                    Group {
                        iconButton(imageName: "WhiteAndBlack", name: "White and Black")
                        Divider()
                        iconButton(imageName: "Neon", name: "Neon")
                        Divider()
                        iconButton(imageName: "Neumorphism", name: "Neumorphism")
                        Divider()
                        iconButton(imageName: "RainbowDark", name: "Rainbow dark")
                        Divider()
                        iconButton(imageName: "RainbowLight", name: "Rainbow light")
                        Divider()
                    }
                    Group {
                        iconButton(imageName: "PlusDark", name: "Plus dark")
                        Divider()
                        iconButton(imageName: "PlusLight", name: "Plus light")
                    }
                }
                .tableBackground()
                .padding(.top, 10)
                .restrictedWidth()
            }
        }
    }
    
    private func iconButton(imageName: String, name: String, setDefaultIcon: Bool = false) -> some View {
        Button {
            if iconViewModel.isPlus() {
                if setDefaultIcon {
                    iconViewModel.setNewIcon(with: nil)
                } else {
                    iconViewModel.setNewIcon(with: imageName)
                }
            } else {
                withAnimation {
                    presentSubscriptionOptions = true
                }
            }
        } label: {
            HStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 60, maxWidth: 60)
                    .cornerRadius(10)
                Text(name)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
    }
}
