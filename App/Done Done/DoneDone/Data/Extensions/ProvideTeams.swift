//
//  ProvideTeams.swift
//  Done Done
//
//  Created by Ezekiel Abuhoff on 6/20/25.
//

import Foundation
import Combine

// MARK: - Team Methods
extension Provide {
    static func createTeam(name: String, description: String) -> AnyPublisher<Team, Error> {
        Just(Local.profile)
            .tryMap {
                guard let profile = $0 else { throw Failure.actionRequiresProfile }
                return (Team.Draft(name: name, description: description), profile)
            }
            .flatMap(FirebaseHandler.createTeam)
            .sideEffect(updateLocalProfileWithNewTeam)
            .eraseToAnyPublisher()
    }

    static func sendTeamInvitation(team: String, teamName: String, recipient: String)
    -> AnyPublisher<TeamInvitation, Error> {
        Just(Local.profile)
            .tryMap {
                guard let profile = $0 else { throw Failure.actionRequiresProfile }
                return TeamInvitation.Draft(
                    team: team,
                    teamName: teamName,
                    recipient: recipient,
                    senderName: profile.name
                )
            }
            .flatMap(FirebaseHandler.sendTeamInvitation)
            .eraseToAnyPublisher()
    }

    static func getMyTeamInvitations() -> AnyPublisher<[TeamInvitation], Error> {
        FirebaseHandler.getMyTeamInvitations()
            .eraseToAnyPublisher()
    }

    static func acceptTeamInvitation(_ invitation: TeamInvitation) -> AnyPublisher<Void, Error> {
        FirebaseHandler.acceptTeamInvitation(invitation)
            .eraseToAnyPublisher()
    }

    static func declineTeamInvitation(_ invitation: TeamInvitation) -> AnyPublisher<Void, Error> {
        FirebaseHandler.declineTeamInvitation(invitation)
            .eraseToAnyPublisher()
    }

    static func leaveTeam(_ team: Team) -> AnyPublisher<Void, Error> {
        Just(team)
            .tryMap {
                guard let teamID = $0.id else { throw Failure.actionRequiresGroupID }
                return teamID
            }
            .flatMap(FirebaseHandler.leaveTeam)
            .eraseToAnyPublisher()
    }

    static func getMyTeams() -> AnyPublisher<[Team], Error> {
        Just(Local.profile?.memberTeams)
            .map { $0 ?? [] }
            .flatMap(FirebaseHandler.getTeams)
            .eraseToAnyPublisher()
    }

    static func getTeamLeaders(_ team: Team) -> AnyPublisher<[Profile], Error> {
        FirebaseHandler.getTeamLeaders(team)
            .eraseToAnyPublisher()
    }

    static func getTeamMembers(_ team: Team) -> AnyPublisher<[Profile], Error> {
        FirebaseHandler.getTeamMembers(team)
            .eraseToAnyPublisher()
    }
}

extension Provide {
    private static func updateLocalProfileWithNewTeam(_ newTeam: Team) {
        guard let profile = Local.profile else { return }
        let updatedProfile = Profile(
            userID: profile.userID,
            name: profile.name,
            tagline: profile.tagline,
            icon: profile.icon,
            userTeam: profile.userTeam,
            memberTeams: profile.memberTeams + [newTeam.id ?? ""],
            leaderTeams: profile.leaderTeams + [newTeam.id ?? ""]
        )
        Local.profile = updatedProfile
    }

//    private static func addTeamInfoToTeamInvitations(_ groupInvitations: [GroupInvitation])
//    -> AnyPublisher<[GroupInvitation.WithGroup], Error> {
//        FirebaseHandler.getGroups(groupIDs: groupInvitations.map(\.group))
//            .map { (groups: [Group]) -> [GroupInvitation.WithGroup] in
//                groupInvitations.compactMap { (invitation: GroupInvitation) -> GroupInvitation.WithGroup? in
//                    guard let correctGroup = groups.first(where: { $0.id == invitation.group }) else { return nil }
//                    return GroupInvitation.WithGroup(invitation: invitation, group: correctGroup)
//                }
//            }
//            .eraseToAnyPublisher()
//    }
}
