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
    
    @ObservedObject var searchField: SearchField
    
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField(searchField.placeholder, text: $searchField.searchText)
            }
            .padding(8)
            .background(Color(UIColor(white: 0.94, alpha: 1)))
            .cornerRadius(10)
            .animation(.easeOut)
            
            // show cancel button when there is text in the text field
            if !searchField.searchText.isEmpty {
                Button("Cancel", action: searchField.clear)
                    .foregroundColor(.accentColor)
                    .transition(.move(edge: .trailing))
                    .animation(.easeOut)
            }
        }
    }
}


/// An observable object used with `SearchTextField` to handle search.
///
/// The object provides actions to perform when text changed or debounced.
class SearchField: ObservableObject {

    @Published var searchText = "" {
        willSet { searchTextWillChange.send(newValue) }
        didSet { onSearchTextChanged?(searchText) }
    }
    
    var placeholder = "Search"
    
    /// An action to perform when text changed.
    var onSearchTextChanged: ((String) -> Void)?
    
    /// An action to perform when debounce text changed.
    var onSearchTextDebounced: ((String) -> Void)?
    
    /// A publisher for sending change when `text` changed.
    private let searchTextWillChange = PassthroughSubject<String, Never>()
    
    private var searchTextWillChangeCancellable: AnyCancellable?
    
    
    init() {
        searchTextWillChangeCancellable = searchTextWillChange
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
}


#if DEBUG
struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(searchField: .init())
    }
}
#endif
