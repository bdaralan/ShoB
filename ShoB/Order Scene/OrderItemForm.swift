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
    
    let searchField = SearchField()
    
    var incrementRange: ClosedRange<Int> {
        orderItemModel.name.isEmpty ? 1...1 : 1...999
    }
    
    /// The sale items to display based on the search text.
    @State private var filteredSaleItems = [SaleItem]()
    
    /// A flag used to control how the UI will look.
    @State private var isSearching = false
  
    
    // MARK: - Body
    
    var body: some View {
        Form {
            // Input Section
            saleItemInputSection
                .disabled(orderItemModel.quantity == 0)
                .hidden(isSearching)
        
            // Sale Item Selection List
            saleItemListSection
                .hidden(saleItems.isEmpty)
            
            // Delete Button
            Button(action: onDelete ?? {}) {
                Text("Delete")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.red)
            }
            .hidden(onDelete == nil)
        }
        .navigationBarItems(leading: leadingNavItem, trailing: trailingNavItem)
        .onAppear(perform: { self.filterSaleItems(searchText: "") })
    }
}


// MARK: - Section View

extension OrderItemForm {
    
    var saleItemInputSection: some View {
        Section(header: Text.topSection("ORDER ITEM")) {
            // Name
            Text(orderItemModel.name.isEmpty ? "Select an item" : orderItemModel.name)
                .fontWeight(.semibold)
                .foregroundColor(orderItemModel.name.isEmpty ? .secondary : .primary)
            
            // Price
            HStack {
                Text("Price")
                    .multilineTextAlignment(.leading)
                Spacer()
                Text(orderItemModel.price)
                    .multilineTextAlignment(.trailing)
            }
            
            // Subtotal
            HStack {
                Text("Subtotal").fontWeight(.semibold)
                Spacer()
                Text("\(orderItemModel.subtotal)").fontWeight(.semibold)
            }
            
            // Quantity
            HStack {
                Text("Quantity")
                Spacer()
                quantityText
            }
            
            HStack {
                // Unit Segment
                Picker("", selection: $quantityMode) {
                    Text("Unit").tag(QuantityMode.unit)
                    Text("Dozen").tag(QuantityMode.dozen)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Increment Segment
                Picker("", selection: $incrementValue) {
                    Text("1").tag(1)
                    Text("6").tag(6)
                    Text("12").tag(QuantityMode.dozenCount)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Stepper
                Stepper(
                    value: $orderItemModel.quantity,
                    in: incrementRange,
                    step: incrementValue,
                    onEditingChanged: updateStepperValue,
                    label: EmptyView.init
                )
            }
        }
    }
    
    /// Selectable sale item list.
    var saleItemListSection: some View {
        Section(header: Text.topSection("ALL SALE ITEMS", padding: isSearching ? nil : 0)) {
            // Expand Sale Item List Button
            Button("Select Item", action: beginSelectSaleItem)
                .hidden(orderItemModel.shouldExpandSelectionList)
            
            // Search Field
            SearchTextField(searchField: searchField, onEditingChanged: searchTextFieldEditingChanged)
                .onAppear(perform: setupSearchField)
                .hidden(!orderItemModel.shouldExpandSelectionList)
            
            // Sale Item List
            ForEach(filteredSaleItems, id: \.self) { item in
                Button(action: { self.selectSaleItem(item) }) {
                    HStack {
                        Text("\(item.name)")
                        Spacer()
                        Text(verbatim: "\(Currency(item.price))")
                    }
                    .foregroundColor(.primary)
                }
            }
            .hidden(filteredSaleItems.isEmpty)
            
            Text("no item found")
                .foregroundColor(.secondary)
                .hidden(searchField.searchText.isEmpty || !filteredSaleItems.isEmpty)
        }
    }
}


extension OrderItemForm {
    
    func beginSelectSaleItem() {
        orderItemModel.shouldExpandSelectionList = true
        filteredSaleItems = saleItems
    }
    
    func selectSaleItem(_ item: SaleItem) {
        // only need to get values for the model
        // do not keep reference to avoid editing the item's original values
        let currentQuantity = orderItemModel.quantity
        orderItemModel = .init(saleItem: item, keepReference: false)
        orderItemModel.quantity = currentQuantity == 0 ? 1 : currentQuantity
        
        // collapse the selection list once selected
        orderItemModel.shouldExpandSelectionList = false
        filteredSaleItems = []
        searchField.cancel()
        searchField.clear()
    }
    
    func filterSaleItems(searchText: String) {
        if !orderItemModel.shouldExpandSelectionList {
            filteredSaleItems = []
            return
        }
        
        if searchText.isEmpty {
            filteredSaleItems = saleItems
            return
        }
        
        if let dollar = Double(searchText) {
            let price = Currency("\(dollar)").amount
            filteredSaleItems = saleItems.filter({ $0.price == price })
        } else {
            filteredSaleItems = saleItems.filter({ $0.name.range(of: searchText, options: .caseInsensitive) != nil })
        }
    }
    
    func setupSearchField() {
        searchField.placeholder = "Search name or price"
        searchField.onSearchTextDebounced = { searchText in
            self.filterSaleItems(searchText: searchText)
        }
    }
    
    func searchTextFieldEditingChanged(_ isEditing: Bool) {
        isSearching = isEditing
    }
}


extension OrderItemForm {
    
    /// Add navigation item.
    var addNavItem: some View {
        Button("Add", action: onAdd!)
            .disabled(orderItemModel.name.isEmpty || orderItemModel.quantity == 0)
    }
    
    /// Cancel navigation item.
    var cancelNavItem: some View {
        Button("Cancel", action: onCancel!)
    }
    
    /// Done navigation item.
    var doneNavItem: some View {
        Button("Done", action: onDone!)
    }
    
    var leadingNavItem: some View {
        if onCancel != nil {
            return cancelNavItem.eraseToAnyView()
        }
        
        return AnyView.emptyView
    }
    
    var trailingNavItem: some View {
        if onAdd != nil, onDone == nil {
            return addNavItem.eraseToAnyView()
        }
        
        if onDone != nil, onAdd == nil {
            return doneNavItem.eraseToAnyView()
        }
        
        return AnyView.emptyView
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
