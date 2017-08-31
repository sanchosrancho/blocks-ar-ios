//
//  Extensions.swift
//  Modify
//
//  Created by Олег Адамов on 30.08.17.
//  Copyright © 2017 Envent. All rights reserved.
//

import ARKit

extension SCNScene {
    func enableEnvironmentMapWithIntensity(_ intensity: CGFloat, queue: DispatchQueue) {
        queue.async {
            if self.lightingEnvironment.contents == nil {
                if let environmentMap = UIImage(named: "art.scnassets/sharedImages/environment.jpg") {
                    self.lightingEnvironment.contents = environmentMap
                }
            }
            self.lightingEnvironment.intensity = intensity
        }
    }
}
