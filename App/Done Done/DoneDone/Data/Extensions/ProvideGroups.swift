//
//  ProvideGroups.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 4/28/25.
//

import Foundation
import Combine

// MARK: - Group Methods
extension Provide {
    static func createGroup(name: String, description: String) -> AnyPublisher<Group, Error> {
        Just(Local.profile)
            .tryMap {
                guard let profile = $0 else { throw Failure.actionRequiresProfile }
                return (Group.Draft(name: name, description: description), profile)
            }
            .flatMap(FirebaseHandler.createGroup)
            .sideEffect(updateLocalProfileWithNewGroup)
            .eraseToAnyPublisher()
    }

    static func sendGroupInvitation(group: String, recipient: String) -> AnyPublisher<GroupInvitation, Error> {
        Just(Local.profile?.name ?? "")
            .map { (GroupInvitation.Draft(group: group, senderName: $0, recipient: recipient)) }
            .flatMap(FirebaseHandler.sendGroupInvitation)
            .eraseToAnyPublisher()
    }

    static func getMyGroupInvitations() -> AnyPublisher<[GroupInvitation.WithGroup], Error> {
        FirebaseHandler.getMyGroupInvitations()
            .flatMap(addGroupInfoToGroupInvitations)
            .eraseToAnyPublisher()
    }

    static func acceptGroupInvitation(_ invitation: GroupInvitation) -> AnyPublisher<Void, Error> {
        FirebaseHandler.acceptGroupInvitation(invitation)
            .eraseToAnyPublisher()
    }

    static func declineGroupInvitation(_ invitation: GroupInvitation) -> AnyPublisher<Void, Error> {
        FirebaseHandler.declineGroupInvitation(invitation)
            .eraseToAnyPublisher()
    }

    static func leaveGroup(_ group: Group) -> AnyPublisher<Void, Error> {
        Just(group)
            .tryMap {
                guard let groupID = $0.id else { throw Failure.actionRequiresGroupID }
                return groupID
            }
            .flatMap(FirebaseHandler.leaveGroup)
            .eraseToAnyPublisher()
    }

    static func getMyGroups() -> AnyPublisher<[Group], Error> {
        Just(Local.profile?.memberGroups)
            .map { $0 ?? [] }
            .flatMap(FirebaseHandler.getGroups)
            .eraseToAnyPublisher()
    }

    static func getGroupOrganizers(_ group: Group) -> AnyPublisher<[Profile], Error> {
        FirebaseHandler.getGroupOrganizers(group)
            .eraseToAnyPublisher()
    }

    static func getGroupMembers(_ group: Group) -> AnyPublisher<[Profile], Error> {
        FirebaseHandler.getGroupMembers(group)
            .eraseToAnyPublisher()
    }
}

extension Provide {
    private static func updateLocalProfileWithNewGroup(_ newGroup: Group) {
        guard let profile = Local.profile else { return }
        let updatedProfile = Profile(
            userID: profile.userID,
            name: profile.name,
            memberGroups: profile.memberGroups + [newGroup.id ?? ""],
            organizerGroups: profile.organizerGroups + [newGroup.id ?? ""],
            attendingEvents: profile.attendingEvents
        )
        Local.profile = updatedProfile
    }

    private static func addGroupInfoToGroupInvitations(_ groupInvitations: [GroupInvitation])
    -> AnyPublisher<[GroupInvitation.WithGroup], Error> {
        FirebaseHandler.getGroups(groupIDs: groupInvitations.map(\.group))
            .map { (groups: [Group]) -> [GroupInvitation.WithGroup] in
                groupInvitations.compactMap { (invitation: GroupInvitation) -> GroupInvitation.WithGroup? in
                    guard let correctGroup = groups.first(where: { $0.id == invitation.group }) else { return nil }
                    return GroupInvitation.WithGroup(invitation: invitation, group: correctGroup)
                }
            }
            .eraseToAnyPublisher()
    }
}
