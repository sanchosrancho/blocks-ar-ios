//
//  Users.swift
//  Modify
//
//  Created by Alex Shevlyakov on 28/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation
import PromiseKit
import Moya
import RealmSwift
import CoreLocation

struct Users {
    
    static func find(id: UserObjectIdentifier, realm: Realm) -> User? {
        return realm.object(ofType: User.self, forPrimaryKey: id)
    }
}
