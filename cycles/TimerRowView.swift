//
//  TimerRowView.swift
//  cycles
//
//  Created by Tony Zhang on 11/12/20.
//

import SwiftUI

struct TimerRowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var item:FetchedResults<TimerItem>.Element

    @State var currentTime:Int64 = Int64(Date().timeIntervalSince1970)
    @State var timer: Timer? = nil
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key:"order",ascending:true)],
        animation: .default)
    var items: FetchedResults<TimerItem>

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
                Text("\(item.timeLeft/3600) : \(item.timeLeft%3600/60) : \(item.timeLeft%60)")
            }
            Spacer()
            Button(action: resetTimer) {
                Image(systemName:"backward.fill")
            }
            .buttonStyle(PlainButtonStyle())
            Button(action:deleteItem) {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(PlainButtonStyle())
            
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80, idealHeight: 80, maxHeight: 80)
        .foregroundColor(.white)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(nil)
    }
    
    private func startTimer(){
        if(item.paused){item.endTime = Int64(Date().timeIntervalSince1970) + item.timeLeft}
        item.paused = false

        if(item.timeLeft <= 0){stopTimer()}
        else{
            DispatchQueue.main.async {
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
                    currentTime = Int64(Date().timeIntervalSince1970)
                    item.timeLeft = item.endTime - currentTime
                    if(item.timeLeft <= 0){stopTimer()}
                    do {
                        try viewContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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
