//
//  GPTErrorResponse.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import Foundation

enum GPTClientError: Error, CustomStringConvertible {
  case errorResponse(statusCode: Int, error: GPTErrorResponse?)
  case networkError(message: String? = nil, error: Error? = nil)
  
  var description: String {
    switch self {
    case .errorResponse(let statusCode, let error):
      return "GPTClientError.errorResponse: statusCode: \(statusCode), " +
      "error: \(String(describing: error))"
      
    case .networkError(let message, let error):
      return "GPTClientError.networkError: message: \(String(describing: message)), " +
      "error: \(String(describing: error))"
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
