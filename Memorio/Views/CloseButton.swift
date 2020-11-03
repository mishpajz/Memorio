//
//  CloseButton.swift
//  Memorio
//
//  Created by Michal Dobes on 14/08/2020.
//

import SwiftUI

struct CloseButton: View {
    @Binding var close: Bool
    @Binding var urlToRemove: URL?
    let withAAnimation: Bool
    
    init(close: Binding<Bool>, withAAnimation: Bool, urlToRemove: Binding<URL?>? = Binding.constant(nil)) {
        self._close = close
        self._urlToRemove = urlToRemove ?? Binding.constant(nil)
        self.withAAnimation = withAAnimation
    }
    
    var body: some View {
        Button {
            if withAAnimation {
                withAnimation {
                    close = false
                }
            } else {
                close = false
            }
            
            if let url = urlToRemove {
                try? FileManager.default.removeItem(at: url)
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(Font.system(size: 25, weight: .bold))
                .foregroundColor(Constants.secondaryColor)
        }
        .hoverEffect()
    }
}
