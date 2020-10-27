//
//  RewindView.swift
//  Memorio
//
//  Created by Michal Dobes on 27/08/2020.
//

import SwiftUI

struct RewindView: View {
    @Binding var presenting: Bool
    @EnvironmentObject var rewindViewModel: RewindViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    presenting = false
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(Font.system(size: 26, weight: .semibold))
                }
                .hoverEffect()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 3)
            HStack {
                Text(getToday())
                    .font(Font.system(size: 17, weight: .bold))
                    .foregroundColor(Constants.secondaryColor)
                Spacer()
            }
                .padding(.horizontal, 20)
            TitleView(text: "Rewind")
            ScrollView {
                ForEach(rewindViewModel.rewinds) { rewind in
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.fixed(100))], content: {
                        Text(rewind.rewind)
                            .font(Font.system(size: 24, weight: .black))
                        Button {
                            rewindViewModel.selectRewind(rewind: rewind)
                            rewindViewModel.presentingMemory = true
                        } label: {
                            VStack {
                                Text(getDay(from: rewind.memory.date))
                                    .font(Font.system(size: 13, weight: .heavy))
                                Spacer()
                                Text(getDate(from: rewind.memory.date))
                                    .font(Font.system(size: 16, weight: .black))
                                    .multilineTextAlignment(.center)
                                Spacer()
                                Text("\(rewind.memory.memories.count)")
                                    .font(Font.system(size: 16, weight: .medium))
                                Text(rewind.memory.memories.count > 1 ? "memories" : "memory")
                                    .font(Font.system(size: 16, weight: .medium))
                            }
                            .aspectRatio(0.8, contentMode: .fill)
                            .frame(maxWidth: 100, maxHeight: 140)
                            .padding(2)
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 8)
                                            .fill(Constants.mainGradient)
                                            .shadow(color: Constants.mainColor, radius: 2, x: 0, y: 2))
                        }
                    }).padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer()
        }
        .fullScreenCover(isPresented: $rewindViewModel.presentingMemory, onDismiss: {
            PersistentStore.shared.save()
            rewindViewModel.refetchFromCoreData()
        }, content: {
            MemoryView(memoryViewModel: MemoryViewModel(memories: rewindViewModel.selectedMemories, isPresented: $rewindViewModel.presentingMemory))
        })
        .background(Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .edgesIgnoringSafeArea(.top)
                        .frame(maxWidth: .infinity, maxHeight: .infinity))
    }
    
    private func getDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    private func getDay(from date: Date) -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        return dayFormatter.string(from: date)
    }
    
    private func getToday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        return dateFormatter.string(from: Date())
    }
}

struct RewindView_Previews: PreviewProvider {
    static var previews: some View {
        RewindView(presenting: .constant(true))
    }
}
