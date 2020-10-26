//
//  PrivacyView.swift
//  Memorio
//
//  Created by Michal Dobes on 26/08/2020.
//

import SwiftUI

struct PrivacyView: View {
    @State var presentingFullPrivacyPolicy = false
    var body: some View {
        VStack {
            TitleView(text: "Privacy")
            VStack {
                Text("Privacy is very important. All your data is stored safely only on this device. Nobody (except you) has any access to your data.")
                    .font(Font.system(size: 17, weight: .regular))
                    .padding(.horizontal)
                Divider()
                Button {
                    presentingFullPrivacyPolicy = true
                } label: {
                    Text("Full privacy policy")
                        .font(Font.system(size: 17, weight: .bold))
                        .foregroundColor(Constants.tetriaryColor)
                        .padding(.vertical, 5)
                }
                .hoverEffect()
            }
            .tableBackground()
            .padding(.top, 10)
            .restrictedWidth()
            Spacer()
        }
        .sheet(isPresented: $presentingFullPrivacyPolicy) {
            SafariView(isShowing: $presentingFullPrivacyPolicy, url: Constants.privacyPolicy)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}
