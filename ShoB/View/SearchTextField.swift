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
    
    @ObservedObject private var model = SearchField()
    
    let placeholder: String
    
    var onSearchTextChanged: ((String) -> Void)?
    
    var onSearchTextDebounced: ((String) -> Void)?
    
    var body: some View {
        model.onSearchTextChanged = onSearchTextChanged
        model.onSearchTextDebounced = onSearchTextDebounced
        return TextField(placeholder, text: $model.searchText)
    }
}


/// An observable object to be used with `SearchTextField`.
class SearchField: ObservableObject {
    
    let searchTextWillChange = PassthroughSubject<String, Never>()
    
    @Published var searchText = "" {
        willSet { searchTextWillChange.send(newValue) }
        didSet { onSearchTextChanged?(searchText) }
    }
    
    var onSearchTextChanged: ((String) -> Void)?
    
    var onSearchTextDebounced: ((String) -> Void)?
    
    private var searchTextCancellable: AnyCancellable?
    
    
    init() {
        searchTextCancellable = searchTextWillChange
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { self.onSearchTextDebounced?($0) })
    }
}


#if DEBUG
struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(placeholder: "Search", onSearchTextChanged: { _ in })
    }
}
#endif
