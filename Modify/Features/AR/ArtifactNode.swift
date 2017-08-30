//
//  ArtifactNode.swift
//  Modify
//
//  Created by Alex Shevlyakov on 31.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import CoreLocation

class ArtifactNode: LocationNode {
    let artifactId: String
    
    public init(location: CLLocation?, artifactId: String) {
        self.artifactId = artifactId
        super.init(location: location)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
