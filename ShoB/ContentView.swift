//
//  ContentView.swift
//  ShoB
//
//  Created by Dara Beng on 6/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct ContentView : View {
    
    @ObjectBinding var order = Order(context: CoreDataStack.current.mainContext)
    
    var body: some View {
        NavigationView {
            TabbedView {
                OrderList()
            }
            .tabItemLabel(Text("Orders"))
            .navigationBarTitle(Text("Orders"), displayMode: .large)
            .navigationBarItems(trailing:
                PresentationButton(
                    Image(systemName: "plus")
                        .imageScale(.large),
                    destination: Text("Order Form Create Mode")
                )
            )
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
