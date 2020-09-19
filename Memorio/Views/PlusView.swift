//
//  PlusView.swift
//  Memorio
//
//  Created by Michal Dobes on 29/08/2020.
//

import SwiftUI

struct PlusView: View {
    @Binding var isPresented: Bool
    @ObservedObject var plusViewModel = PlusViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State var presentingAlert = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                content()
            }
            .restrictedWidth()
            if plusViewModel.loading {
                LoadingHudAlert(isShowing: $plusViewModel.loading)
            }
        }
    }
    
    private func content() -> some View {
        VStack {
            HStack(spacing: 0) {
                Text("Memorio")
                    .font(Font.system(size: 28, weight: .black))
                Text("+")
                    .font(Font.system(size: 28, weight: .black))
                    .foregroundColor(Constants.mainColor)
                Spacer()
                CloseButton(close: $isPresented, withAAnimation: true)
            }
            .padding(.horizontal, 30)
            .padding(.top, 30)
            .padding(.bottom)
            VStack {
                featureText(for: "add unlimited Memories in a week")
                featureText(for: "remove watermark")
                featureText(for: "unlock more icons")
                featureText(for: "all future features and updates")
                featureText(for: "support development of the app")
            }
            .padding(.horizontal, 30)
            VStack {
                if plusViewModel.isPurchased(id: MemorioPlusProducts.plusLifetime) {
                    iapButton(duration: "Lifetime", productID: MemorioPlusProducts.plusLifetime)
                } else {
                    iapButton(duration: "Monthly", productID: MemorioPlusProducts.plusMonthly)
                    iapButton(duration: "Yearly", productID: MemorioPlusProducts.plusYearly, greatDeal: true)
                    iapButton(duration: "Lifetime", productID: MemorioPlusProducts.plusLifetime)
                        .alert(isPresented: $presentingAlert, content: {
                            Alert(
                                title: Text("Lifetime"),
                                message: Text("Thank you for supporting Memorio. As you ale already a Memorio Plus subscriber, you need to cancel/expire your subscription, so you don't get charged twice."),
                                primaryButton: .default(Text("Manage subscriptions")) { UIApplication.shared.open(unsubURL) },
                                secondaryButton: .cancel(Text("Ok")))
                        })
                }
            }
                .padding(.vertical)
            Button {
                plusViewModel.restore()
            } label: {
                Text("Restore purchases")
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
        }
        .background(RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        .fill(Constants.popupBackground)
                        .edgesIgnoringSafeArea(.bottom)
                        .transition(.identity)
                        .edgesIgnoringSafeArea(.bottom))
    }
    
    private func featureText(for text: String) -> some View {
        HStack {
            Text("+")
                .font(Font.system(size: 17, weight: .black))
            Text(text)
                .font(Font.system(size: 17, weight: .medium))
                .foregroundColor(Constants.secondaryColor)
            Spacer()
        }
    }
    
    private func iapButton(duration: String, productID: String, greatDeal: Bool = false) -> some View {
        Group {
            if plusViewModel.isPurchased(id: productID) && productID != MemorioPlusProducts.plusLifetime {
                realIapButton(duration: duration, productID: productID, greatDeal: greatDeal)
                    .contextMenu {
                        Button {
                            UIApplication.shared.open(unsubURL)
                        } label: {
                            Text("Manage subscriptions")
                        }

                    }
            } else {
                realIapButton(duration: duration, productID: productID, greatDeal: greatDeal)
            }
        }
    }
    
    private func realIapButton(duration: String, productID: String, greatDeal: Bool = false) -> some View {
        Button {
            if plusViewModel.isPurchased(id: productID) {
                plusViewModel.hapticFeedback()
            } else {
                if plusViewModel.subscribing(), productID == MemorioPlusProducts.plusLifetime {
                    presentingAlert = true
                } else {
                    plusViewModel.purchase(id: productID)
                }
            }
        } label: {
            if plusViewModel.isPurchased(id: productID) {
                purchasedButtonLabel(duration: duration)
            } else {
                ZStack {
                    Rectangle()
                        .fill(colorScheme == .dark ? Constants.quaternaryColor : Constants.popupBackground)
                        .frame(height: 58)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    HStack {
                        Text(duration)
                            .font(Font.system(size: 17, weight: .regular))
                            .foregroundColor(.secondary)
                        Spacer()
                        if greatDeal {
                            Text("great deal")
                                .font(Font.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(RoundedRectangle(cornerRadius: 7)
                                                .fill(Constants.mainGradient))
                                .padding(.horizontal)
                        }
                        Text(plusViewModel.price(for: productID))
                            .font(Font.system(size: 21, weight: .bold))
                            .foregroundColor(Constants.mainColor)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func purchasedButtonLabel(duration: String) -> some View {
        ZStack {
            Rectangle()
                .fill(Constants.quaternaryColor)
                .frame(height: 58)
                .frame(maxWidth: .infinity)
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(Constants.mainGradient, lineWidth: 5))
            HStack {
                Text(duration)
                    .font(Font.system(size: 17, weight: .regular))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Thank you! 🎉")
                    .font(Font.system(size: 21, weight: .light))
                    .foregroundColor(Constants.secondaryColor)
            }
            .padding(.horizontal)
        }
    }
    
    private let unsubURL = URL(string: "https://apps.apple.com/account/subscriptions")!
}

struct LoadingHudAlert: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .prominent))
                .cornerRadius(15)
            ProgressView()
        }
            .frame(width: 150, height: 150, alignment: .center)
    }
}

struct PlusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlusView(isPresented: Binding.constant(true))
        }
    }
}
