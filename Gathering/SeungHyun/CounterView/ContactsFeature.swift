//
//  ContactsFeature.swift
//  Gathering
//
//  Created by dopamint on 11/11/24.
//

import Foundation
import ComposableArchitecture


struct Contact: Equatable, Identifiable {
    let id: UUID
    var name: String
}


// 1. 가고자 하는 뷰의 State를 @Presents로 감싼다.
// 또한 네이게이션 stack이 될 array을 생성한다. (보편적으로 스택의 경우에는 최상단의 뷰가 가지면 된다.)
@Reducer
struct ContactsFeature {
    @ObservableState
    struct State: Equatable {
//        @Presents var addContact: AddContactFeature.State?
//        @Presents var alert: AlertState<Action.Alert>?
        @Presents var destination: Destination.State?
        var contacts: IdentifiedArrayOf<Contact> = []
    }
    enum Action {
        case addButtonTapped
//        case addContact(PresentationAction<AddContactFeature.Action>)
//        case alert(PresentationAction<Alert>)
        case deleteButtonTapped(id: Contact.ID)
        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.addContact = AddContactFeature.State(
                    contact: Contact(id: UUID(), name: "")
                )
                return .none
                
            case let .addContact(.presented(.delegate(.saveContact(contact)))):
                state.contacts.append(contact)
                return .none
                
            case .addContact:
                return .none
                
            case let .alert(.presented(.confirmDeletion(id: id))):
                state.contacts.remove(id: id)
                return .none
                
            case .alert:
                return .none
                
            case let .deleteButtonTapped(id: id):
                state.alert = AlertState {
                    TextState("Are you sure?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                        TextState("Delete")
                    }
                }
                return .none
            }
        }
        .ifLet(\.$addContact, action: \.addContact) {
            AddContactFeature()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension ContactsFeature {
  @Reducer
  enum Destination {
    case addContact(AddContactFeature)
    case alert(AlertState<ContactsFeature.Action.Alert>)
  }
}
extension ContactsFeature.Destination.State: Equatable {}
