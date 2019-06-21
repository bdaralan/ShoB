//
//  CustomerList.swift
//  ShoB
//
//  Created by Dara Beng on 6/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct CustomerList : View {
    
    @State var customers = sampleCustomers()
    
    var body: some View {
        List(customers.identified(by: \.self)) { customer in
            NavigationButton(destination: Text("Customer Info"), label: {
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
        CustomerList()
    }
}
#endif


func sampleCustomers() -> [Customer] {
    var customers = [Customer]()
    for i in 1...40 {
        let context = CoreDataStack.current.mainContext
        let customer = Customer(context: context)
        customer.firstName = "F\(i)"
        customer.lastName = "L\(i)"
        customers.append(customer)
    }
    return customers
}
