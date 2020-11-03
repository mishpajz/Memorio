//
//  CalendarView.swift
//  Memorio
//
//  Created by Michal Dobes on 08/08/2020.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    @Environment(\.presentationMode) var presentation
    @State var presentingBigRewind = true
    @ObservedObject var rewindViewModel = RewindViewModel()
    @State var presentingRewind = false
    
    @State var rewindGesturePosition: CGSize = .zero
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CalendarTopBarView(rewindViewModel: rewindViewModel, presentingBigRewind: $presentingBigRewind, presentingRewind: $presentingRewind)
                    .onAppear {
                        if let lastRewindDate = UserDefaults.standard.object(forKey: Constants.bigRewindDate) as? Date {
                            if Calendar.current.isDate(lastRewindDate, inSameDayAs: Date()) {
                                presentingBigRewind = false
                            }
                        }
                    }
                ZStack {
                    CalendarContentView()
                        .restrictedWidth()
                    if presentingBigRewind && rewindViewModel.isRewindAvailable {
                        VStack {
                            Button {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    presentingRewind = true
                                }
                            } label: {
                                HStack {
                                    Text("Rewind")
                                        .font(Font.system(size: 28, weight: .heavy))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "tray.full.fill")
                                        .font(Font.system(size: 28, weight: .heavy))
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .padding(.vertical, 25)
                                .background(RoundedRectangle(cornerRadius: 15)
                                                .fill(Constants.tetriaryGradient)
                                                .shadow(color: Constants.tetriaryColor, radius: 10, x: 0, y: 0))
                                .padding()
                                .offset(x: rewindGesturePosition.width, y: rewindGesturePosition.height)
                                .gesture(DragGesture()
                                            .onChanged({ value in
                                                rewindGesturePosition = CGSize(width: value.translation.width, height: value.translation.height)
                                            })
                                            .onEnded({ (value) in
                                                if abs(value.translation.width) > 10 || abs(value.translation.height) > 20 {
                                                    withAnimation(.easeOut(duration: 0.1)) {
                                                        presentingBigRewind = false
                                                    }
                                                    UserDefaults.standard.set(Date(), forKey: Constants.bigRewindDate)
                                                }
                                                rewindGesturePosition = .zero
                                            }))
                            }
                            Spacer()
                        }
                        .transition(.opacity)
                    }
                }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        calendarViewModel.fetchFromCoreData()
                        rewindViewModel.refetchFromCoreData()
                    }
                    .fullScreenCover(isPresented: $calendarViewModel.presentingMemory, onDismiss: {
                        PersistentStore.shared.save()
                    }, content: {
                        MemoryView(memoryViewModel: MemoryViewModel(memories: calendarViewModel.selectedMemories, isPresented: $calendarViewModel.presentingMemory))
                    })
            }
                .environmentObject(calendarViewModel)
            .environmentObject(rewindViewModel)
            if presentingRewind {
                RewindView(presenting: $presentingRewind)
                    .environmentObject(rewindViewModel)
                    .transition(.scale(scale: 0.5, anchor: .top))
            }
        }
    }
}

struct CalendarTopBarView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @ObservedObject var rewindViewModel: RewindViewModel
    
    @State var startPos : CGPoint = .zero
    @State var isSwipping = true
    @Binding var presentingBigRewind: Bool
    @Binding var presentingRewind: Bool
    
    private var nextYearName: String {
        guard let nextYear = calendarViewModel.nextYear else { return "" }
        return String(nextYear)
    }
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 14)
            HStack(alignment: .lastTextBaseline) {
                Spacer()
                Text(String(calendarViewModel.previousYear))
                    .transition(.identity)
                    .frame(maxWidth: 80)
                    .onTapGesture {
                        withAnimation(.easeIn(duration: animationDuration)) {
                            calendarViewModel.setPreviousYear()
                        }
                    }
                    .hoverEffect()
                Spacer()
                Text(String(calendarViewModel.currentYear))
                    .transition(.identity)
                    .font(Font.system(size: 24, weight: .heavy))
                Spacer()
                if calendarViewModel.nextYear == nil, !presentingBigRewind && rewindViewModel.isRewindAvailable {
                    Button {
                        withAnimation(.easeOut(duration: 0.25)) {
                            presentingRewind = true
                        }
                    } label: {
                        Text("Rewind")
                            .font(Font.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .transition(.opacity)
                            .padding(3)
                            .frame(maxWidth: 80)
                            .background(RoundedRectangle(cornerRadius: 5).fill(Constants.tetriaryColor))
                    }
                    .hoverEffect()
                } else {
                    Text(nextYearName)
                        .transition(.identity)
                        .frame(maxWidth: 80)
                        .onTapGesture {
                            withAnimation(.easeIn(duration: animationDuration)) {
                                calendarViewModel.setNextYear()
                            }
                        }
                        .hoverEffect()
                }
                Spacer()
            }
                .font(Font.system(size: 18, weight: .heavy))
                .lineLimit(1)
                .restrictedWidth()
            Spacer()
                .frame(height: 14)
            HStack(spacing: 0) {
                Group {
                    Text("sun")
                        .frame(maxWidth: .infinity)
                    Spacer()
                    Text("mon")
                        .frame(maxWidth: .infinity)
                    Spacer()
                    Text("tue")
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
                Group {
                    Text("wed")
                        .frame(maxWidth: .infinity)
                    Spacer()
                    Text("thu")
                        .frame(maxWidth: .infinity)
                    Spacer()
                    Text("fri")
                        .frame(maxWidth: .infinity)
                    Spacer()
                    Text("sat")
                        .frame(maxWidth: .infinity)
                }
            }
                .font(Font.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .restrictedWidth()
            Divider()
        }
        .contentShape(Rectangle())
        .gesture(DragGesture()
                .onChanged { gesture in
                    self.startPos = gesture.location
                    self.isSwipping.toggle()
                }
                .onEnded { gesture in
                    let xDist =  abs(gesture.location.x - self.startPos.x)
                    let yDist =  abs(gesture.location.y - self.startPos.y)
                    if self.startPos.x > gesture.location.x && yDist < xDist {
                        withAnimation(.easeIn(duration: animationDuration)) {
                            calendarViewModel.setNextYear()
                        }
                    }
                    else if self.startPos.x < gesture.location.x && yDist < xDist {
                        withAnimation(.easeIn(duration: animationDuration)) {
                            calendarViewModel.setPreviousYear()
                        }
                    }
                    self.isSwipping.toggle()
                }
             )
    }
    
    private let animationDuration = 0.15
}

struct CalendarContentView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(calendarViewModel.calendarYear.months.reversed()) { month in
                    CalendarMonthView(month: month)
                }
            }
            .padding(.bottom, 25)
            .id("scrollView")
        }
    }
}

struct CalendarMonthView: View {
    var month: CalendarMonth
    
    private var monthName: String {
        DateFormatter().monthSymbols[month.id-1]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(monthName)
                    .font(Font.system(size: 28, weight: .black))
                Spacer()
            }
                .padding(.leading, 10)
                .padding(.bottom, 15)
                .padding(.top, 25)
            VStack(spacing: 15) {
                ForEach(month.weeks.reversed()) { week in
                    CalendarWeekView(week: week)
                }
            }
        }
    }
}

struct CalendarWeekView: View {
    var week: CalendarWeek
    
    var body: some View {
        HStack {
            ForEach(1..<8) { i in
                if let dayToDisplay = week.days.first(where: { day -> Bool in
                    day.weekday == i
                }) {
                    CalendarDayView(day: dayToDisplay)
                } else {
                    CalendarDayView(day: nil)
                        .opacity(0)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct CalendarDayView: View {
    var day: CalendarDay?
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject var rewindViewModel: RewindViewModel
    @Environment(\.presentationMode) var presentation
    @State var showingDeletionAlert = false
    @Environment(\.colorScheme) var colorScheme
    
    var dayToDisplay: String {
        guard let day = day else { return "0" }
        return String(day.day)
    }
    
    var body: some View {
        if (day?.memories.count ?? 0) > 0 {
            dayEntry
                .contextMenu {
                Button {
                    calendarViewModel.selectMemories(memories: day?.memories ?? [])
                    calendarViewModel.presentingMemory = true
                } label: {
                    HStack {
                        Text("Show Memory")
                        Image(systemName: "bolt.fill")
                    }
                }
                Button {
                    showingDeletionAlert = true
                } label: {
                    HStack {
                        Text("Delete all Memories")
                        Image(systemName: "trash.fill")
                    }

                }
            }
            .alert(isPresented: $showingDeletionAlert) { () -> Alert in
                Alert(title: Text("Are you sure?"), message: Text("Memories in this day will be deleted permanently."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Delete"), action: {
                    calendarViewModel.selectMemories(memories: day?.memories ?? [])
                    calendarViewModel.removeInDay()
                    rewindViewModel.refetchFromCoreData()
                }))
            }
        } else {
            dayEntry
        }
    }
    
    private var dayEntry: some View {
        ZStack {
            backgroundRectangle
            Text(dayToDisplay)
                .foregroundColor(labelColor)
        }
        .foregroundColor(Constants.secondaryColor)
        .aspectRatio(4/5, contentMode: .fit)
    }
    
    @ViewBuilder
    private var backgroundRectangle: some View {
        if (day?.memories.count ?? 0) > 0 {
            Button {
                calendarViewModel.selectMemories(memories: day?.memories ?? [])
                calendarViewModel.presentingMemory = true
            } label: {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Constants.mainGradient)
            }
            .hoverEffect()
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(colorScheme == .dark ? Constants.quaternaryColor : Color(UIColor.systemBackground))
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color(UIColor.systemBackground), lineWidth: 1)
                .shadow(color: Constants.shadowBackground, radius: 5)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
    
    private var labelColor: Color {
        if (day?.memories.count ?? 0) > 0 {
            return Color.white
        }
        return Constants.secondaryColor
        
    }
    private let cornerRadius: CGFloat = 8
    private let lineWidth: CGFloat = 3
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(calendarViewModel: CalendarViewModel())
    }
}
