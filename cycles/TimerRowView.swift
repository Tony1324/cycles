//
//  TimerRowView.swift
//  cycles
//
//  Created by Tony Zhang on 11/12/20.
//

import SwiftUI
import UserNotifications
import Combine

struct TimerRowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key:"order",ascending:true)],
        animation: .default)
    var items:FetchedResults<TimerItem>
    var item:TimerItem

    @State var currentTime = Date()
    @State var showPopover:Bool = false
    @State var isHovering = false

    var timer:Publishers.Autoconnect<Timer.TimerPublisher>

    var elapsedTime: Double {
        min((item.pauseTime?.timeIntervalSinceReferenceDate ?? currentTime.timeIntervalSinceReferenceDate) - item.wrappedStartTime.timeIntervalSinceReferenceDate , Double(item.duration))
    }

    var timeLeft: Double {
        min(Double(item.duration) - elapsedTime, Double(item.duration))
    }

    let colors = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.pink]
    var color:Color {
        colors[Int(item.color)]
    }
    var body: some View {

        HStack(spacing:10){
            ZStack{
                CircleProgressView(progress: elapsedTime.rounded(.towardZero)/Double(item.duration))
                Button(action: item.pauseTime != nil ? startTimer : stopTimer) {
                    Image(systemName: item.pauseTime != nil ? "play.fill" : "pause.fill")
                        .shadow(radius: 10)
                }
                .buttonStyle(PlainButtonStyle())
                .font(.title2)

            }
            .onReceive(timer, perform: { _ in
                currentTime = Date()
                if(timeLeft <= 0){
                    if(item.cycle) {
                        while item.wrappedStartTime <= Date().addingTimeInterval(-Double(item.duration)) {
                            item.startTime = item.wrappedStartTime.addingTimeInterval(Double(item.duration))
                        }
                    } else {
                        stopTimer()
                    }
                }
            })
            .padding(.trailing, 10)
            ZStack{
                HStack{
                VStack(alignment: .leading){
                    Text(item.wrappedName)
                        .fontWeight(.bold)
                        .font(.system(.title, design: .rounded))

                    Text(formatTime(timeLeft.rounded(.awayFromZero)))
                        .fontWeight(.bold)
                        .font(.system(.body, design: .rounded))
                        .opacity(0.8)
                }
                    Spacer()
                }
                    HStack(spacing:20){
                        Spacer()
                        Button(action: resetTimer) {
                            Image(systemName:"backward.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button(action:{showPopover.toggle()}) {
                            Image(systemName: "info.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        Button(action:deleteItem) {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .shadow(radius: 10)
                    .padding([.top,.bottom])
                    .background(LinearGradient(colors: [color.opacity(0.3), color], startPoint: .leading, endPoint: .trailing))
                    .font(.title)
                    .animation(.default, value: isHovering)
                    .opacity(isHovering ? 1 : 0)

            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80, idealHeight: 80, maxHeight: 80)
        .foregroundColor(.white)
        .popover(isPresented: $showPopover, arrowEdge: .top){
            PopoverView(item:item)
        }
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onHover(perform: { hovering in
            isHovering = hovering
        })
        .animation(.default, value: isHovering)
    }

    private func formatTime(_ time:Double) -> String {
        var string = ""
        let hours = Int(max(time,0))/3600
        let minutes = Int(max(time,0))%3600/60
        let seconds = Int(max(time,0))%60

        if(hours != 0){
            string.append(contentsOf: String(hours) + ":")
        }

        string.append("\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))")


        return string
    }
    
    private func startTimer(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        if(timeLeft <= 0){
            resetTimer()
        }

        if(item.pauseTime != nil){
            item.startTime = currentTime.addingTimeInterval(-elapsedTime)
            item.pauseTime = nil
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func stopTimer(){
        item.pauseTime = Date()
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func resetTimer(){
        item.startTime = Date()
    }
    
    private func sendNotification(){
        let content = UNMutableNotificationContent()
        content.title = item.wrappedName
        content.subtitle = formatTime(Double(item.duration))
        if(item.sound){content.sound = UNNotificationSound.default}
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func deleteItem() {
        viewContext.delete(item)
        items.forEach{ _item in
            if (_item.order > item.order){
                _item.order-=1
            }
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
