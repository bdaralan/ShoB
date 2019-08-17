//
//  MultiPurposeForm.swift
//  ShoB
//
//  Created by Dara Beng on 8/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A protocol for form view that can be use to create or update object.
///
/// The protocol provides convenient methods and navigation items to setup the form.
///
/// Code Example:
///
///     struct UserProfileForm: View, MultiPurposeForm { // conform to MultiPurposeForm
///         // required properties...
///
///         var body: some View {
///             let form = Form {
///                 Section {...}
///                 Section {...}
///                 setupRowActionSection() // setup the buttons the end
///             }
///             return setupNavItems(forForm: form) // setup the navigation items
///         }
///     }
///
protocol MultiPurposeForm {
    
    /// An action to perform when the create navigation item is tapped.
    var onCreate: (() -> Void)? { set get }
    
    /// An action to perform when the update navigation item is tapped.
    var onUpdate: (() -> Void)? { set get }
    
    /// An action to perform when the cancel navigation ite is tapped.
    var onCancel: (() -> Void)? { set get }
    
    /// A flag to enable or disable the create navigation item.
    ///
    /// The default is `nil` which is always enabled.
    var enableCreate: Bool? { set get }
    
    /// A flag to enable or disable the update navigation item.
    ///
    /// The default is `nil` which is always enabled.
    var enableUpdate: Bool? { set get }
    
    /// Custom row actions to perform.
    ///
    /// These row-button actions are setup by `setupRowActionSection()` method.
    var rowActions: [MultiPurposeFormRowAction] { set get }
}


// MARK: - Navigation Item

extension MultiPurposeForm {
    
    var createNavItem: some View {
        Button("Create", action: onCreate ?? {})
            .font(Font.body.bold())
            .disabled(enableCreate == false)
    }
    
    var cancelNavItem: some View {
        Button("Cancel", action: onCancel ?? {})
    }
    
    var updateNavItem: some View {
        Button("Update", action: onUpdate ?? {})
            .font(Font.body.bold())
            .disabled(enableUpdate == false)
    }
}


// MARK: - Setup Method

extension MultiPurposeForm {

    /// Setup navigation bar items for the given form based on the action blocks.
    ///
    /// See `MultiPurposeForm`'s document code example for how to use the method.
    /// - Parameter form: The form to setup.
    func setupNavItems(forForm form: AnyView) -> some View {
        if onCreate != nil, onCancel != nil {
            return AnyView(form.navigationBarItems(leading: cancelNavItem, trailing: createNavItem))
        }
        
        if onUpdate != nil {
            return AnyView(form.navigationBarItems(trailing: updateNavItem))
        }
        
        return AnyView(form)
    }
    
    /// Setup button for row actions if any.
    ///
    /// See `MultiPurposeForm`'s document code example for how to use the method.
    func setupRowActionSection() -> some View {
        Section {
            ForEach(rowActions, id: \.title) { row in
                Button(row.title, action: row.action)
                    .buttonStyle(CenterButtonStyle(row.isDestructive ? .destructive : .normal))
            }
        }
    }
}


// MARK: - Alert

extension MultiPurposeForm {
    
    func deleteConfirmationAlert(title: String, message: String?, action: @escaping () -> Void) -> Alert {
        let title = Text(title)
        let message = message != nil ? Text(message!) : nil
        let delete = Alert.Button.destructive(Text("Delete"), action: action)
        return Alert(title: title, message: message, primaryButton: delete, secondaryButton: .cancel())
    }
}


// MARK: - Row Action

struct MultiPurposeFormRowAction {
    var title: String
    var isDestructive = false
    var action: () -> Void
}
