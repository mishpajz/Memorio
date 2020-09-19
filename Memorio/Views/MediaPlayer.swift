//
//  MediaPlayer.swift
//  Memorio
//
//  Created by Michal Dobes on 23/08/2020.
//

import SwiftUI
import UIKit
import AVKit

struct MediaPlayer: View {
    @State var player: AVPlayer?
    @State var paused = false
    @State var currentTimePlaying: String = "00:00"
    @State var totalTime: String = "00:00"
    @State var timePosition: TimePosition = .topLeading
    var backgroundColor: UIColor = UIColor.systemBackground
    
    public enum TimePosition {
        case topLeading
        case middleBottom
    }
    
    let timer = Timer.publish(every: 0.2, on: .current, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            if player != nil {
                Player(player: player!, backgroundColor: backgroundColor)
                    .onAppear {
                        player!.volume = 1.0
                        player!.play()
                        
                        totalTime = timeTotal
                        
                        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem, queue: .main) { (_) in
                            if player != nil {
                                player!.seek(to: .zero)
                                player!.play()
                                currentTimePlaying = timeLapsed
                            }
                        }
                    }
                    .onTapGesture {
                        playOrPause()
                    }
                    .onDisappear {
                        player?.pause()
                        player = nil
                    }
                VStack {
                    if timePosition == .topLeading {
                        HStack {
                            Text(currentTimePlaying + " / " + totalTime)
                                .onReceive(timer) { _ in
                                    totalTime = timeTotal
                                    currentTimePlaying = timeLapsed
                                }
                                .font(Font.system(size: 17, weight: .light))
                                .foregroundColor(.white)
                                .padding(12)
                                .blurredBackground()
                                .padding()
                            Spacer()
                        }
                        .onTapGesture {
                            playOrPause()
                        }
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        if paused {
                            Image(systemName: "play.circle.fill")
                                .font(Font.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .blurredBackground()
                                .aspectRatio(1, contentMode: .fill)
                                .onTapGesture {
                                    playOrPause()
                                }
                        }
                        Spacer()
                    }
                    Spacer()
                    if timePosition == .middleBottom {
                        HStack {
                            Spacer()
                            Text(currentTimePlaying + " / " + totalTime)
                                .onReceive(timer) { _ in
                                    totalTime = timeTotal
                                    currentTimePlaying = timeLapsed
                                }
                                .font(Font.system(size: 17, weight: .light))
                                .foregroundColor(.white)
                                .padding(12)
                                .blurredBackground()
                                .padding()
                            Spacer()
                        }
                        .padding(.bottom, 20)
                        .onTapGesture {
                            playOrPause()
                        }
                    }
                }
            }
        }
    }
    
    private func playOrPause() {
        if player != nil {
            if player!.timeControlStatus == .playing {
                player!.pause()
                paused = true
            } else {
                player!.play()
                paused = false
            }
        }
    }
    
    private var timeLapsed: String {
        var lapsed = "00:00"
        if player != nil {
            lapsed = Int(player!.currentItem?.currentTime().seconds ?? 0).secondsToTime()
        }
        return lapsed
    }
    
    private var timeTotal: String {
        var total = "00:00"
        if player != nil, player!.currentItem?.status == .readyToPlay {
            total = Int(player!.currentItem?.duration.seconds ?? 0).secondsToTime()
        }
        return total
    }
}
