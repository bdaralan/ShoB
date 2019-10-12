//
//  AddOrderItemForm.swift
//  ShoB
//
//  Created by Dara Beng on 8/1/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct OrderItemForm: View {
    
    @Binding var orderItemModel: SaleItemFormModel
    
    var saleItems: [SaleItem] = []
    
    var onAdd: (() -> Void)?
    
    var onCancel: (() -> Void)?
    
    var onDone: (() -> Void)?
    
    var onDelete: (() -> Void)?
    
    @State private var incrementValue = 1
    
    @State private var quantityMode = QuantityMode.unit
    
    var incrementRange: ClosedRange<Int> {
        orderItemModel.name.isEmpty ? 1...1 : 1...999
    }
  
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // Input Section
            Section(header: Text.topSection("ORDER ITEM")) {
                // MARK: Name
                Text(orderItemModel.name.isEmpty ? "Select an item" : orderItemModel.name)
                    .fontWeight(.semibold)
                    .foregroundColor(orderItemModel.name.isEmpty ? .secondary : .primary)
                
                // MARK: Price
                HStack {
                    Text("Price")
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(orderItemModel.price)
                        .multilineTextAlignment(.trailing)
                }
                
                // MARK: Subtotal
                HStack {
                    Text("Subtotal").fontWeight(.semibold)
                    Spacer()
                    Text("\(orderItemModel.subtotal)").fontWeight(.semibold)
                }
                
                // MARK: Quantity
                HStack {
                    Text("Quantity")
                    Spacer()
                    quantityText
                }
                
                HStack {
                    // MARK: Unit Segment
                    Picker("", selection: $quantityMode) {
                        Text("Unit").tag(QuantityMode.unit)
                        Text("Dozen").tag(QuantityMode.dozen)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // MARK: Increment Segment
                    Picker("", selection: $incrementValue) {
                        Text("1").tag(1)
                        Text("6").tag(6)
                        Text("12").tag(QuantityMode.dozenCount)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // MARK: Stepper
                    Stepper(
                        value: $orderItemModel.quantity,
                        in: incrementRange,
                        step: incrementValue,
                        onEditingChanged: updateStepperValue,
                        label: EmptyView.init
                    )
                }
            }
        
            // MARK: Sale Item Selection List
            saleItemListSection
                .hidden(saleItems.isEmpty)
            
            // MARK: Delete Button
            Button(action: onDelete ?? {}) {
                Text("Delete")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.red)
            }
            .hidden(onDelete == nil)
        }
        .navigationBarItems(leading: leadingNavItem(), trailing: trailingNavItem())
    }
}


// MARK: - Body Component

extension OrderItemForm {
    
    /// Add navigation item.
    var addNavItem: some View {
        Button("Add", action: onAdd!)
            .disabled(orderItemModel.name.isEmpty)
    }
    
    /// Cancel navigation item.
    var cancelNavItem: some View {
        Button("Cancel", action: onCancel!)
    }
    
    /// Done navigation item.
    var doneNavItem: some View {
        Button("Done", action: onDone!)
    }
    
    func leadingNavItem() -> some View {
        if onCancel != nil {
            return cancelNavItem.eraseToAnyView()
        }
        
        return AnyView.emptyView
    }
    
    func trailingNavItem() -> some View {
        if onAdd != nil, onDone == nil {
            return addNavItem.eraseToAnyView()
        }
        
        if onDone != nil, onAdd == nil {
            return doneNavItem.eraseToAnyView()
        }
        
        return AnyView.emptyView
    }
    
    /// Selectable sale item list.
    var saleItemListSection: some View {
        Section(header: Text("ALL SALE ITEMS")) {
            // Expand Sale Item List Button
            if !orderItemModel.shouldExpandSelectionList {
                Button("Select Item", action: { self.orderItemModel.shouldExpandSelectionList = true })
            }
            
            // Sale Item List
            ForEach(orderItemModel.shouldExpandSelectionList ? saleItems : [], id: \.self) { item in
                Button(action: {
                    // only need to get values for the model
                    // do not keep reference to avoid editing the item's original values
                    self.orderItemModel = .init(saleItem: item, keepReference: false)
                    
                    // collapse the selection list once selected
                    self.orderItemModel.shouldExpandSelectionList = false
                }) {
                    HStack {
                        Text("\(item.name)")
                        Spacer()
                        Text(verbatim: "\(Currency(item.price))")
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
    /// View that displays quantity based on `quantityMode`.
    var quantityText: Text {
        switch quantityMode {
        case .unit:
            return Text("\(orderItemModel.quantity)")
        case .dozen:
            let dozen = orderItemModel.quantity / QuantityMode.dozenCount
            let remain = orderItemModel.quantity % QuantityMode.dozenCount
            let remainString = remain == 0 ? "" : " + \(remain)"
            return Text("\(dozen) ") + Text(QuantityMode.dozenAbbrev).fontWeight(.light).italic() + Text(remainString)
        }
    }
    
    func updateStepperValue(isChanging: Bool) {
        // if quantity is less then a dozen, switch back to unit segment
        guard !isChanging, self.orderItemModel.quantity < QuantityMode.dozenCount else { return }
        self.quantityMode = .unit
    }
}


extension OrderItemForm {
    
    enum QuantityMode {
        case unit
        case dozen
        
        static let dozenCount = 12
        static let dozenAbbrev = "doz."
    }
}


struct AddOrderItemView_Previews: PreviewProvider {
    static var previews: some View {
        OrderItemForm(orderItemModel: .constant(.init()), saleItems: [], onAdd: {}, onCancel: {})
    }
}
