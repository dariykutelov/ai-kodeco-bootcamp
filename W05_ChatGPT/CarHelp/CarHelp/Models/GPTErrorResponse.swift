//
//  GPTErrorResponse.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import Foundation

enum GPTClientError: Error, CustomStringConvertible {
    case errorResponse(statusCode: Int, error: GPTErrorResponse?, body: String?)
    case networkError(message: String? = nil, error: Error? = nil)
    case errorSummarizeChat(errorMessage: String? = nil)
    
    var description: String {
        switch self {
        case .errorResponse(let statusCode, let error, let body):
            return "GPTClientError.errorResponse: statusCode: \(statusCode), " +
            "error: \(error?.error.message ?? body ?? "unknown")"
            
        case .networkError(let message, let error):
            return "GPTClientError.networkError: message: \(String(describing: message)), " +
            "error: \(String(describing: error))"
            
        case .errorSummarizeChat(let errorMessage):
            return "GPTClientError.errorSummarizeChat: error: \(errorMessage ?? "unknown")"
        }
    }
}

struct GPTErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let message: String
        let type: String
        let param: String?
        let code: String?
    }
}
