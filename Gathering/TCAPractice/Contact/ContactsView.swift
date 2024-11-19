//
//  ContactsView.swift
//  Gathering
//
//  Created by dopamint on 11/11/24.
//

//import SwiftUI
//import ComposableArchitecture
//
//
//struct ContactsView: View {
//    @Perception.Bindable var store: StoreOf<ContactsFeature>
//    
//    var body: some View {
//        NavigationStack {
//            List {
//                ForEach(store.contacts) { contact in
//                    Text(contact.name)
//                }
//            }
//            .navigationTitle("Contacts")
//            .toolbar {
//                ToolbarItem {
//                    Button {
//                        store.send(.addButtonTapped)
//                    } label: {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
//        }
//        .sheet(
//            item: $store.scope(state: \.addContact, action: \.addContact)
//        ) { addContactStore in
//            NavigationStack {
//                AddContactView(store: addContactStore)
//            }
//        }
//    }
//}
