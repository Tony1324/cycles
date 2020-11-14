//
//  ContentView.swift
//  cycles
//
//  Created by Tony Zhang on 11/12/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key:"order",ascending:true)],
        animation: .default)
    var items: FetchedResults<TimerItem>

    var body: some View {
        List {
            ForEach(items) { item in
                TimerRowView(item: item)
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            Button(action: addItem) {
                Label("Add Timer", systemImage: "plus")
            }
        }
        .frame(minWidth:400,maxWidth:400,minHeight:110)
    }

    private func addItem() {
        withAnimation {
            let newItem = TimerItem(context: viewContext)
            newItem.order = Int64(items.count)
            newItem.duration = Int64(300)
            newItem.timeLeft = Int64(300)
            newItem.paused = true
            newItem.color = Int64(4)
            newItem.name = "Untitled Timer"
            newItem.cycle = false
            newItem.sound = true
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

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            items.forEach{ item in
                if (item.order > offsets.map { items[$0] }[0].order){
                    item.order-=1
                }
            }
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
