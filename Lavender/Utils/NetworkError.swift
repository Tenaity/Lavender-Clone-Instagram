//
//  NetworkError.swift
//  Lavender
//
//  Created by Van Muoi on 7/16/22.
//

import Foundation

public enum NetworkError: Error, LocalizedError {
    case noInternetConnection
    case operationFailed
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return NSLocalizedString("No internet connection, please try again", comment: "No internet connection, please try again")
        case .operationFailed:
            return NSLocalizedString("Operation failed, please try again later", comment: "Operation failed, please try again later")
        default:
            return NSLocalizedString("Oops, something went wrong", comment: "Oops, something went wrong")
        }
    }
}

