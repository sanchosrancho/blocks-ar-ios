//
//  ApiResponse.swift
//  Modify
//
//  Created by Alex Shevlyakov on 27/09/2017.
//  Copyright © 2017 Envent. All rights reserved.
//

import Foundation

extension Api {
    enum ResponseStatus: String, Decodable {
        case ok
        case error
    }
    
    struct ResponseError: Decodable {
        let code: [Int]
        let description: [String]
    }
    
    enum Response<T: Decodable>: Decodable {
        case error(ResponseError)
        case success(T)
        
        enum CodingKeys: String, CodingKey {
            case status
            case result
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let status = try container.decode(ResponseStatus.self, forKey: .status)
            
            switch status {
            case .error:
                let errors = try container.decode(ResponseError.self, forKey: .result)
                self = .error(errors)
            case .ok:
                let data = try container.decode(T.self, forKey: .result)
                self = .success(data)
            }
        }
    }
}
