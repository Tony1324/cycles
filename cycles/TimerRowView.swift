//
//  TimerRowView.swift
//  cycles
//
//  Created by Tony Zhang on 11/12/20.
//

import SwiftUI

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
        HStack(spacing:20){
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
            VStack(alignment: .leading){
                Text(item.name ?? "Untitled")
                    .font(.title)
                    .fontWeight(.bold)
                Text("\(max(item.timeLeft,0)/3600) : \(max(item.timeLeft,0)%3600/60) : \(max(item.timeLeft,0)%60)")
            }
            Spacer()
            Button(action: resetTimer) {
                Image(systemName:"backward.fill")
            }
            .buttonStyle(PlainButtonStyle())
            Button(action:deleteItem) {
                Image(systemName: "xmark.circle.fill")
                    .opacity(0.5)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80, idealHeight: 80, maxHeight: 80)
        .popover(isPresented: $showPopover, arrowEdge: .trailing){
            PopoverView(item:item)
        }
        .foregroundColor(.white)
        .background(colors[Int(item.color)])
        
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onLongPressGesture {
            showPopover = true
        }
        .animation(nil)
    }
    
    private func startTimer(){
        if(item.paused){item.endTime = Int64(Date().timeIntervalSince1970) + item.timeLeft}
        item.paused = false
        if(item.timeLeft <= 0){
            stopTimer();
            item.timeLeft = 0
        }
        else{
            DispatchQueue.main.async {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
                    currentTime = Int64(Date().timeIntervalSince1970)
                    item.timeLeft = item.endTime - currentTime
                    if(item.timeLeft <= 0){stopTimer()}
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
