//
//  UserAccountCoreDataEntity.swift
//  AuthBackend
//
//  Created by Ben Leggiero on 2019-12-02.
//  Copyright © 2019 Ben Leggiero. All rights reserved.
//

import Cocoa



/// Represents a `UserAccount` in CoreData
@objc(UserAccountCoreDataEntity)
internal class UserAccountCoreDataEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var displayName: String
    @NSManaged var passwordHash: Data
    @NSManaged var passwordSalt: Data
    @NSManaged var passwordHashingApproach: String?
}



internal extension UserAccount {
    
    /// Converts a CoreData entity version of a user account into a UserAccount
    init(_ coreDataEntity: UserAccountCoreDataEntity) {
        self.init(
            id: coreDataEntity.id,
            displayName: coreDataEntity.displayName,
            passwordHash: PasswordHash(
                contents: coreDataEntity.passwordHash,
                salt: coreDataEntity.passwordSalt,
                approach: .init(coreDataRepresentation: coreDataEntity.passwordHashingApproach)
            )
        )
    }
}



internal extension PasswordHash.Approach {
    
    /// A pre-computed dictionary of all the approaches' CoreData representations related to those approaches
    private static let allCoreDataRepresentations =
        [String : Self](uniqueKeysWithValues: Self.allCases.map { ($0.coreDataRepresentation, $0) })
    
    
    /// Attempts to convert the given CoreData representation of an approach into an approach.
    ///
    /// If the given string is `nil`, or does not represent an approach, then `nil` is returned
    ///
    /// - Parameter coreDataRepresentation: The representation used in the CoreData database
    init?(coreDataRepresentation: String?) {
        guard
            let approachString = coreDataRepresentation,
            let approach = Self.allCoreDataRepresentations[approachString]
            else
        {
            return nil
        }
        
        self = approach
    }
    
    
    /// The One True™ representation of this approach in a CoreData database
    fileprivate var coreDataRepresentation: String {
        switch self {
        case .sha512:
            return "SHA512"
        }
    }
}



internal extension PasswordHash.UsedApproach {
    
    init(coreDataRepresentation: String?) {
        if let approach = PasswordHash.Approach(coreDataRepresentation: coreDataRepresentation) {
            self = .known(approach: approach)
        }
        else {
            self = .unknown
        }
    }
    
    
    var coreDataRepresentation: String? {
        switch self {
        case .unknown: return nil
        case .known(let approach): return approach.coreDataRepresentation
        }
    }
}
