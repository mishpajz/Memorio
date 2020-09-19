//
//  TitleView.swift
//  Memorio
//
//  Created by Michal Dobes on 24/08/2020.
//

import SwiftUI

struct TitleView: View {
    var text: String
    
    var body: some View {
        HStack {
            Text(text)
                .titleText()
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

extension View {
    func titleText() -> some View {
        self.font(Font.system(size: 32, weight: .black))
    }
}
