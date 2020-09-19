//
//  PinGridView.swift
//  Memorio
//
//  Created by Michal Dobes on 25/08/2020.
//

import SwiftUI

struct PinGrid<Model>: View where Model: ObservableObject, Model: GridPin {
    @ObservedObject var viewModel: Model
    private let gridModel = PinGridViewModel()
    
    var body: some View {
        VStack(alignment: .center) {
            LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))], spacing: 40) {
                ForEach(1..<10) { i in
                    numberButton(for: i)
                }
                Spacer()
                numberButton(for: 0)
                Button {
                    viewModel.removeFromPin()
                } label: {
                    Image(systemName: "delete.left.fill")
                        .font(Font.system(size: 25, weight: .light))
                        .foregroundColor(Color.primary)
                }
            }
        }
    }
    
    private func numberButton(for number: Int) -> some View {
        Button {
            viewModel.appendToPin(number: number)
            gridModel.hapticFeedback()
        } label: {
            Text("\(number)")
                .multilineTextAlignment(.center)
                .font(Font.system(size: 50, weight: .light))
                .foregroundColor(Color.primary)
        }
    }
}
