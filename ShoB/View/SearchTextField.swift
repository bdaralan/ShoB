//
//  SearchTextField.swift
//  ShoB
//
//  Created by Dara Beng on 8/7/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import Combine


/// A search text box.
struct SearchTextField: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var searchField: SearchField
    
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField(searchField.placeholder, text: $searchField.searchText)
            }
            .padding(8)
            .background(Color(UIColor(white: colorScheme == .light ? 0.92 : 0.1, alpha: 1)))
            .cornerRadius(10)
            .animation(.easeOut)
            
            // show cancel button when there is text in the text field
            if !searchField.searchText.isEmpty {
                Button("Cancel", action: cancelSearch)
                    .foregroundColor(.accentColor)
                    .transition(.move(edge: .trailing))
                    .animation(.easeOut)
            }
        }
    }
}


extension SearchTextField {
    
    func cancelSearch() {
        searchField.cancel()
        searchField.clear()
    }
}


/// An observable object used with `SearchTextField` to handle search.
///
/// The object provides actions to perform when text changed or debounced.
class SearchField: ObservableObject {

    @Published var searchText = "" {
        didSet { onSearchTextChanged?(searchText) }
    }
    
    var placeholder = "Search"
    
    /// An action to perform when text changed.
    var onSearchTextChanged: ((String) -> Void)?
    
    /// An action to perform when debounce text changed.
    var onSearchTextDebounced: ((String) -> Void)?
    
    private var searchTextDebounceCancellable: AnyCancellable?
    
    
    init() {
        searchTextDebounceCancellable = $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { newValue in
                self.objectWillChange.send()
                self.onSearchTextDebounced?(newValue)
            })
    }
    
    
    /// Clear the search text.
    func clear() {
        searchText = ""
    }
    
    /// Ask the application to resign the first responder, which is the keyboard.
    func cancel() {
        let dismissKeyboard = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(dismissKeyboard, to: nil, from: nil, for: nil)
    }
}


struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(searchField: .init())
    }
}
