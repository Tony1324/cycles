//
//  TimerRowView.swift
//  cycles
//
//  Created by Tony Zhang on 11/12/20.
//

import SwiftUI
import UserNotifications

struct TimerRowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key:"order",ascending:true)],
        animation: .default)
    var items:FetchedResults<TimerItem>
    var item:FetchedResults<TimerItem>.Element

    @State var currentTime:Int64 = Int64(Date().timeIntervalSince1970)
    @State var timer:Timer? = nil
    @State var showPopover:Bool = false
    let colors = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.pink]
    var body: some View {
        HStack(spacing:10){
            ZStack{
                CircleProgressView(progress:Double(item.duration - item.timeLeft)/Double(item.duration))
                Button(action: item.paused ? startTimer : stopTimer) {
                    Image(systemName: item.paused ? "play.fill" : "pause.fill")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .onAppear{
                if(!item.paused){startTimer()}
            }
            .foregroundColor(.white)
            .padding(.trailing, 10)
            VStack(alignment: .leading){
                Text(item.name ?? "Untitled")
                    .font(.title)
                    .fontWeight(.bold)
                Text("\(max(item.timeLeft,0)/3600) : \(max(item.timeLeft,0)%3600/60) : \(max(item.timeLeft,0)%60)")
            }
            .foregroundColor(.white)
            Spacer()
            Button(action: resetTimer) {
                Image(systemName:"backward.fill")
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.white)
            Button(action:{showPopover.toggle()}) {
                Image(systemName: "info.circle.fill")
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.white)
            Button(action:deleteItem) {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80, idealHeight: 80, maxHeight: 80)
        .popover(isPresented: $showPopover, arrowEdge: .trailing){
            PopoverView(item:item)
        }
        .background(colors[Int(item.color)])
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(nil)
    }
    
    private func startTimer(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        if(item.paused){item.endTime = Int64(Date().timeIntervalSince1970) + item.timeLeft}
        item.paused = false
        if(item.timeLeft <= 0){
            sendNotification()
            if(item.cycle){resetTimer()}
            else{
                stopTimer();
                item.timeLeft = 0
            }
        }
        else{
            DispatchQueue.main.async {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
                    currentTime = Int64(Date().timeIntervalSince1970)
                    item.timeLeft = item.endTime - currentTime
                    if(item.timeLeft <= 0){
                        sendNotification()
                        if(item.cycle){resetTimer()}
                        else{stopTimer()}
                    }
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
            }
        }
    }
    
    private func stopTimer(){
        item.paused = true
        timer?.invalidate()
        timer = nil
        do {
            try viewContext.save()
        } catch {

            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func resetTimer(){
        item.timeLeft = item.duration
        item.endTime = Int64(Date().timeIntervalSince1970) + item.timeLeft
    }
    
    private func sendNotification(){
        let content = UNMutableNotificationContent()
        content.title = item.name ?? "Untitled Timer"
        content.subtitle = "\(max(item.duration,0)/3600) : \(max(item.duration,0)%3600/60) : \(max(item.duration,0)%60)"
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
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
