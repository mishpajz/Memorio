//
//  LoginView.swift
//  Memorio
//
//  Created by Michal Dobes on 24/08/2020.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Enter passcode")
                    .font(Font.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            HStack {
                Spacer()
                HStack {
                    ForEach(0..<4) { i in
                        dot(for: i)
                    }
                }
                Spacer()
            }
            .padding(.vertical)
            .padding(.top, 30)
            PinGrid(viewModel: loginViewModel)
                .padding(.top, 30)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 60)
            if loginViewModel.canUseBiometrics() {
                Button {
                    loginViewModel.authenticationCancelledByUser = false
                    loginViewModel.authUsingBiometrics()
                } label: {
                    Image(systemName: "faceid")
                        .font(Font.system(size: 26, weight: .semibold))
                        .padding(.top, 40)
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .ignoresSafeArea())
    }
    
    private func dot(for number: Int) -> some View {
        Image(systemName: dotImageName(for: number))
            .font(Font.system(size: 17, weight: .black))
            .foregroundColor(loginViewModel.failedLogin ? Constants.deleteColor : Color.primary)
    }
    
    private func dotImageName(for number: Int) -> String {
        if number < loginViewModel.enteredPin.count || loginViewModel.failedLogin {
            return "circle.fill"
        }
        return "circle"
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
        }
    }
}
