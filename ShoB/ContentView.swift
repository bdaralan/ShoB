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
