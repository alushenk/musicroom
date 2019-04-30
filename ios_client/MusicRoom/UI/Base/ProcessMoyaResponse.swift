//
//  ProcessMoyaResponse.swift
//  MusicRoom
//
//  Created by Heorhii Shakula on 4/27/19.
//  Copyright © 2019 Heorhii Shakula. All rights reserved.
//

import Foundation
import Moya
import Result

extension API {

struct ErrorLoginResponse: Decodable {
    let non_field_errors: [String]
}

}

func parseUnknownErrorResponse(data: Data) -> String? {
    guard let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
        let jsonObject = object as? [String: Any] else { return nil }

    var message = ""
    for entry in jsonObject {
        if let detail = entry.value as? String {
            message += "\(entry.key): \(detail)\n"
        } else if let details = entry.value as? [Any] {
            for detail in details {
                if let detail = detail as? String {
                    message += "\(entry.key): \(detail)\n"
                }
            }
        }
    }
    return message != "" ? message : nil
}

func getMoyaResultErrorMessage(data: Data) -> String? {
    if let msg = try? JSONDecoder().decode(API.DetailResponse.self, from: data) {
        return msg.detail
    } else if let msg = try? JSONDecoder().decode(API.ErrorLoginResponse.self, from: data) {
        var errorMessage = ""
        for errorStr in msg.non_field_errors {
            errorMessage += "\(errorStr)\n"
        }
        if errorMessage != "" {
            return errorMessage
        }
    } else {
        return parseUnknownErrorResponse(data: data)
    }
    return nil
}

func processMoyaResult(result: Result<Moya.Response, MoyaError>,
                         onSuccess: ((Data) -> Void)? = nil,
                         onFailure: ((String?) -> Void)? = nil) {
    switch result {
    case let .success(response):
        if response.statusCode >= 300 {
            onFailure?(getMoyaResultErrorMessage(data: response.data))
        } else {
            onSuccess?(response.data)
        }
    case let .failure(error):
        onFailure?(error.type.description)
    }
}
