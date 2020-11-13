//
//  TimerRowView.swift
//  cycles
//
//  Created by Tony Zhang on 11/12/20.
//

import SwiftUI

struct TimerRowView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var item:FetchedResults<Timer>.Element

    @State var currentTime:Int = Int(Date().timeIntervalSince1970)
    @State var timerIsPaused: Bool = true
    @State var timer: Timer? = nil
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key:"order",ascending:true)],
        animation: .default)
    var items: FetchedResults<Timer>

    var body: some View {
        HStack(spacing:20){
            Spacer()
            CircleProgressView(progress:0.5)
            Text("\(currentTime)   /   \(item.order)")
            Button(action:deleteItem) {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80, idealHeight: 80, maxHeight: 80)
        .foregroundColor(.white)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(nil)
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
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
