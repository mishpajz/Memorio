//
//  StorageView.swift
//  Memorio
//
//  Created by Michal Dobes on 25/08/2020.
//

import SwiftUI

struct StorageView: View {
    @ObservedObject var storageViewModel = StorageViewModel()
    @State var deleteAllMemoriesAlert = false
    
    var body: some View {
        VStack {
            ScrollView {
                TitleView(text: "Storage")
                VStack {
                    StorageBar()
                        .padding(.horizontal)
                }
                .tableBackground()
                .padding(.top, 10)
                .restrictedWidth()
                VStack {
                    Text("Higher quality videos take more space.")
                        .font(Font.system(size: 17, weight: .regular))
                        .padding(.horizontal)
                        .padding(.top, 3)
                    HStack {
                        Text("New videos quality")
                        Spacer()
                        Picker(textForVideoQuality(storageViewModel.currentExportSettings), selection: $storageViewModel.currentExportSettings.onChange({ _ in
                            storageViewModel.saveQuality()
                        })) {
                            ForEach(VideoQualitySettings.allCases) { setting in
                                Text(textForVideoQuality(setting)).tag(setting)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .hoverEffect()
                    }
                    .padding(.bottom, 3)
                    .padding(.horizontal)
                }
                .tableBackground()
                .padding(.top, 10)
                .restrictedWidth()
                VStack {
                    Button {
                        DispatchQueue.global(qos: .userInitiated).async {
                            storageViewModel.clearCache()
                        }
                    } label: {
                        Text("Clear cache")
                            .font(Font.system(size: 17, weight: .bold))
                            .foregroundColor(Constants.tetriaryColor)
                            .padding(.vertical, 5)
                    }
                    .hoverEffect()
                    Divider()
                    Button {
                        deleteAllMemoriesAlert = true
                    } label: {
                        Text("Delete all Memories")
                            .font(Font.system(size: 17, weight: .bold))
                            .foregroundColor(Constants.deleteColor)
                            .padding(.vertical, 5)
                    }
                    .hoverEffect()
                    .alert(isPresented: $deleteAllMemoriesAlert) {
                        Alert(title: Text("Are you sure?"), message: Text("All Memories will be deleted permanently."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Delete"), action: {
                            storageViewModel.deleteAllMemories()
                        }))
                    }
                }
                .tableBackground()
                .padding(.top, 10)
                .restrictedWidth()
                Spacer()
            }
        }.environmentObject(storageViewModel)
        .accentColor(Constants.accentColor)
    }
    
    private func textForVideoQuality(_ quality: VideoQualitySettings) -> String {
        switch quality {
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}

struct StorageBar: View {
    @EnvironmentObject var storageViewModel: StorageViewModel
    var body: some View {
        HStack {
            Text("My device")
                .font(Font.system(size: 20, weight: .bold))
            Spacer()
            Text(storageViewModel.format(bytes: storageViewModel.totalDiskSpaceInBytes))
                .font(Font.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
        bar
            .cornerRadius(6)
            .frame(maxHeight: 20)
        HStack {
            Text("Used \(storageViewModel.format(bytes: storageViewModel.usedDiskSpaceInBytes))")
            Spacer()
            Text("Memorio \(storageViewModel.format(bytes: storageViewModel.appDiskSpaceInBytes))")
            Spacer()
            Text("Free \(storageViewModel.format(bytes: storageViewModel.freeDiskSpaceInBytes))")
        }
        .font(Font.system(size: 12, weight: .regular))
        .foregroundColor(.secondary)
    }
    
    private var bar: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(#colorLiteral(red: 0.2528664568, green: 0.2528664568, blue: 0.2528664568, alpha: 1)))
                    .frame(width: sizeOfOccupiedSpaceRectangle(totalWidth: geometry.size.width), height: geometry.size.height)
                Rectangle()
                    .fill(Constants.tetriaryColor)
                    .frame(width: sizeOfAppSpaceRectangle(totalWidth: geometry.size.width), height: geometry.size.height)
                Rectangle()
                    .fill(Color(#colorLiteral(red: 0.9774686802, green: 0.9774686802, blue: 0.9774686802, alpha: 1)))
            }
        }
    }
    
    private func sizeOfOccupiedSpaceRectangle(totalWidth: CGFloat) -> CGFloat {
        return totalWidth / CGFloat(storageViewModel.totalDiskSpaceInBytes) * (CGFloat(storageViewModel.usedDiskSpaceInBytes) - CGFloat(storageViewModel.appDiskSpaceInBytes))
    }
    
    private func sizeOfAppSpaceRectangle(totalWidth: CGFloat) -> CGFloat {
        return totalWidth / CGFloat(storageViewModel.totalDiskSpaceInBytes) * CGFloat(storageViewModel.appDiskSpaceInBytes)
    }
}

struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        StorageView()
    }
}
