//
//  CustomerListView.swift
//  ShoB
//
//  Created by Dara Beng on 6/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct CustomerListView: View {
    
    @State var customers = [Customer]()
    
    
    // MARK: - View Body
    
    var body: some View {
        List(customers, id: \.self) { customer in
            NavigationLink(destination: Text("Customer Info"), label: {
                HStack {
                    Image(systemName: "person.crop.rectangle").imageScale(.large)
                    Text("\(customer.firstName) \(customer.lastName)")
                }
            })
        }
    }
}

#if DEBUG
struct CustomerList_Previews : PreviewProvider {
    static var previews: some View {
        CustomerListView()
    }
}
#endif
