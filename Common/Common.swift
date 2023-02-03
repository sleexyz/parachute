//
//  Common.swift
//  Common
//
//  Created by Sean Lee on 2/2/23.
//


public enum Env: CustomStringConvertible {
    case dev
    case prod
    
    #if DEBUG
    public static let value = Env.dev
    #else
    public static let value = Env.prod
    #endif
    
    public var description: String {
        switch self {
        case .dev: return "dev"
        case .prod: return "prod"
        }
    }
}


