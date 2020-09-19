//
//  SettingsView.swift
//  Memorio
//
//  Created by Michal Dobes on 09/08/2020.
//

import SwiftUI

struct SettingsView: View {
    @Binding var presentingPlus: Bool
    
    var body: some View {
        content
    }
    
    private var content: some View {
        NavigationView {
            VStack {
                TitleView(text: "Settings")
                    .padding(.top, 25)
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        withAnimation {
                            presentingPlus = true
                        }
                    } label: {
                        HStack {
                            Text("Memorio")
                                .foregroundColor(Color.primary)
                                .font(Font.system(size: 24, weight: .black))
                                .multilineTextAlignment(.trailing)
                            Text("+")
                                .foregroundColor(Constants.mainColor)
                                .font(Font.system(size: 28, weight: .black))
                                .offset(x: -8, y: -2)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 17)
                        .padding(.vertical, 5)
                    }
                }
                .tableBackground()
                .restrictedWidth()
                .padding(.bottom, 10)
                VStack(alignment: .leading) {
                    settingsRow(title: "About", imageName: "person.crop.square.fill", destination: AboutView())
                    Divider()
                    settingsRow(title: "Security", imageName: "lock.fill", destination: SecurityView())
                    Divider()
                    settingsRow(title: "Icon", imageName: "app.fill", destination: IconView(presentSubscriptionOptions: $presentingPlus))
                    Divider()
                    settingsRow(title: "Storage", imageName: "briefcase.fill", destination: StorageView())
                    Divider()
                    settingsRow(title: "Privacy", imageName: "hand.raised.fill", destination: PrivacyView())
                }
                .tableBackground()
                .restrictedWidth()
                Spacer()
                    .frame(maxHeight: .infinity)
            }
            .navigationBarTitle("", displayMode: .inline)
            .background(NavigationConfigurator { nc in
                nc.navigationBar.setBackgroundImage(UIImage(), for: .default)
                nc.navigationBar.backItem?.title = "Back"
                nc.navigationBar.shadowImage = UIImage()
            })
            .navigationBarHidden(true)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private func settingsRow<Destination>(title: String, imageName: String, destination: Destination) -> some View where Destination: View {
        NavigationLink(
            destination: destination,
            label: {
                HStack {
                    Image(systemName: imageName)
                        .font(Font.system(size: 17, weight: .bold))
                        .foregroundColor(Constants.tetriaryColor)
                        .frame(width: 20, height: 20, alignment: .center)
                    Text(title)
                        .foregroundColor(Color.primary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 17)
                .padding(.vertical, 5)
            })
    }
}

struct TableBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 9)
            .font(Font.system(size: 17, weight: .bold))
            .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
            .padding(.horizontal, 20)
            .padding(.top, 36)
    }
}

extension View {
    func tableBackground() -> some View {
        self.modifier(TableBackground())
    }
}
