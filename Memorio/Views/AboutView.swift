//
//  AboutView.swift
//  Memorio
//
//  Created by Michal Dobes on 24/08/2020.
//

import SwiftUI
import MessageUI
import SafariServices

struct AboutView: View {
    @Environment(\.openURL) var openURL
    @State var presentingSheet = false
    @State private var activeSheet = ActiveSheet.safari
    @State var presentingShare = false
    @State var safariURL = Constants.devWebsite
    @State var recipient = Constants.appEmail
    @State var subject = ""
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    TitleView(text: "About")
                    Image("icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100, alignment: .center)
                    Text("Memorio")
                        .font(Font.system(size: 17, weight: .bold))
                    Text(version)
                        .font(Font.system(size: 14, weight: .light))
                    Text("by Michal Dobes")
                        .font(Font.system(size: 14, weight: .light))
                    VStack(alignment: .leading) {
                        GeometryReader { geometry in
                            Menu {
                                Button("App website") {
                                    safariURL = Constants.appWebsite
                                    activeSheet = .safari
                                    presentingSheet = true
                                }
                                Button("Developer website") {
                                    safariURL = Constants.devWebsite
                                    activeSheet = .safari
                                    presentingSheet = true
                                }
                            } label: {
                                aboutRow(title: "Website", imageName: "globe")
                                    .frame(idealWidth: geometry.size.width)
                                    .contentShape(Rectangle(), eoFill: true)
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
                            }
                            .hoverEffect()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 30)
                        Divider()
                        GeometryReader { geometry in
                            Menu {
                                Button("Report a bug") {
                                    if MFMailComposeViewController.canSendMail() {
                                        subject = "Bug report"
                                        recipient = Constants.appEmail
                                        activeSheet = .mail
                                        presentingSheet = true
                                    } else {
                                        safariURL = Constants.appWebsite
                                        activeSheet = .safari
                                        presentingSheet = true
                                    }
                                }
                                Button("Feature request") {
                                    if MFMailComposeViewController.canSendMail() {
                                        subject = "Feature request"
                                        recipient = Constants.appEmail
                                        activeSheet = .mail
                                        presentingSheet = true
                                    } else {
                                        safariURL = Constants.appWebsite
                                        activeSheet = .safari
                                        presentingSheet = true
                                    }
                                }
                                Button("Contact developer") {
                                    if MFMailComposeViewController.canSendMail() {
                                        subject = "Memorio"
                                        recipient = Constants.devEmail
                                        activeSheet = .mail
                                        presentingSheet = true
                                    } else {
                                        safariURL = Constants.devWebsite
                                        activeSheet = .safari
                                        presentingSheet = true
                                    }
                                }
                            } label: {
                                aboutRow(title: "Contact", imageName: "envelope")
                                    .frame(idealWidth: geometry.size.width)
                                    .contentShape(Rectangle(), eoFill: true)
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
                            }
                            .hoverEffect()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 30)
                        Divider()
                        Button {
                            openURL(URL(string: "itms-apps://itunes.apple.com/app/id\(Constants.appId)")!)
                        } label: {
                            aboutRow(title: "Rate", imageName: "heart")
                                .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
                        }
                        .hoverEffect()
                        .frame(maxWidth: .infinity, maxHeight: 30)
                        Divider()
                        Button {
                            presentingShare = true
                        } label: {
                            aboutRow(title: "Share", imageName: "square.and.arrow.up")
                                .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
                        }
                        .hoverEffect()
                        .frame(maxWidth: .infinity, maxHeight: 30)
                    }
                    .tableBackground()
                    .restrictedWidth()
                    .ignoresSafeArea(.all, edges: .bottom)
                    .frame(height: 300)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $presentingSheet) {
            switch activeSheet {
            case .safari:
                SafariView(isShowing: $presentingSheet, url: safariURL)
                    .edgesIgnoringSafeArea(.bottom)
            case .mail:
                MailView(isShowing: $presentingSheet, recipient: recipient, subject: subject)
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
        if presentingShare {
            ActivityView(activityItems: [shareURL], isPresented: $presentingShare)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private func aboutRow(title: String, imageName: String) -> some View {
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
    }
    
    private var version: String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return appVersion ?? "1.0"
    }
    
    private let shareURL = Constants.appInAppStoreWebsite
    
    private enum ActiveSheet {
        case safari
        case mail
    }
}
