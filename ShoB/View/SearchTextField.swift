//
//  SearchTextField.swift
//  ShoB
//
//  Created by Dara Beng on 8/7/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import Combine


/// A text field for searching.
struct SearchTextField: View {
    
    @ObservedObject private var searchField = SearchField()
    
    let placeholder: String
    
    var onSearchTextChanged: ((String) -> Void)?
    
    var onSearchTextDebounced: ((String) -> Void)?
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField(placeholder, text: $searchField.searchText)
            }
            .padding(8)
            .background(Color(UIColor(white: 0.94, alpha: 1)))
            .cornerRadius(10)
            .animation(.easeOut)
            
            if !searchField.searchText.isEmpty {
                Button("Cancel", action: searchField.clear)
                    .foregroundColor(.accentColor)
                    .transition(.move(edge: .trailing))
                    .animation(.easeOut)
            }
        }
        .onAppear {
            self.searchField.onSearchTextChanged = self.onSearchTextChanged
            self.searchField.onSearchTextDebounced = self.onSearchTextDebounced
        }
    }
}


/// An observable object to be used with `SearchTextField`.
class SearchField: ObservableObject {
    
    @Published var searchText = "" {
        willSet { searchTextWillChange.send(newValue) }
        didSet { onSearchTextChanged?(searchText) }
    }
    
    var onSearchTextChanged: ((String) -> Void)?
    
    var onSearchTextDebounced: ((String) -> Void)?
    
    private let searchTextWillChange = PassthroughSubject<String, Never>()
    
    private var searchTextWillChangeCancellable: AnyCancellable?
    
    
    init() {
        searchTextWillChangeCancellable = searchTextWillChange
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { self.onSearchTextDebounced?($0) })
    }
    
    /// Clear the search text to empty.
    func clear() {
        searchText = ""
    }
}


#if DEBUG
struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(placeholder: "Search", onSearchTextChanged: { _ in })
    }
}
#endif
