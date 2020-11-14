//
//  PopoverView.swift
//  cycles
//
//  Created by Tony Zhang on 11/13/20.
//

import SwiftUI

struct PopoverView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    var item:FetchedResults<TimerItem>.Element
    @State var text:String = ""
    @State var hours:Int64 = 0
    @State var minutes:Int64 = 0
    @State var seconds:Int64 = 0
    @State var cycle = false
    let colors = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple, Color.pink]
    var body: some View {
        VStack{
            TextField("Title",text:$text, onCommit:{
                if(self.text != ""){
                    text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    item.name = self.text
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
            })
            .onAppear{text = item.name ?? ""}
            .textFieldStyle(PlainTextFieldStyle())
            .font(.title2)
            Divider()
            HStack{
                Stepper(value:$hours, in: 0...Int64.max,onEditingChanged:saveDuration){
                    Text("\(max(hours,0))")
                }
                Stepper(value:$minutes,in: -1...60,onEditingChanged:saveDuration){
                    Text("\(max(min(minutes,59),0))")
                }
                Stepper(value:$seconds,in: -1...60,onEditingChanged:saveDuration){
                    Text("\(max(min(seconds,59),0))")
                }
            }
            .onAppear{
                hours = item.duration/3600
                minutes = item.duration%3600/60
                seconds = item.duration%60
            }
            ScrollView(.horizontal,showsIndicators: false){
                HStack{
                    ForEach(0..<colors.count, id: \.self){index in
                        Button(action:{
                            item.color = Int64(index)
                        }){
                            ZStack{
                                Circle()
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .frame(width:25,height: 25)
                                Circle()
                                    .foregroundColor(colors[index])
                                    .frame(width:22,height:22)
                            }
                        }
                        .frame(height:30)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            HStack{
                Button(action:{
                    cycle.toggle()
                    item.cycle = cycle
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }){
                    Image(systemName: "repeat")
                        .opacity(cycle ? 1 : 0.2)
                }
                .buttonStyle(PlainButtonStyle())
                .onAppear{cycle = item.cycle}
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 160, height: 200)
    }
    
    private func saveDuration(_:Bool){
        item.timeLeft = max(item.timeLeft,0)
        if(self.seconds>59){self.seconds=0;self.minutes+=1}
        if(self.minutes>59){self.minutes=0;self.hours+=1}
        if(self.seconds<0 && (minutes+hours)>0){self.seconds=59;self.minutes-=1}
        if(self.minutes<0 && hours>0){self.minutes=59;self.hours-=1}
        seconds = max(seconds, 0)
        minutes = max(minutes, 0)
        hours = max(hours, 0)
        let _duration = item.duration
        item.duration = hours*3600+minutes*60+seconds
        item.endTime += item.duration-_duration
        item.timeLeft += item.duration-_duration
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

