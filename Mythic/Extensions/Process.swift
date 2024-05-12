//
//  Process.swift
//  Mythic
//
//  Created by Esiayo Alegbe on 25/3/2024.
//

import Foundation

extension Process {
    static func execute(_ executablePath: String, arguments: [String]) throws -> String {
        let process = Process()
        process.launchPath = executablePath
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        try? process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? .init()
        
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func executeAsync(_ executablePath: String, arguments: [String], completion: @escaping (Legendary.CommandOutput) -> Void) async throws {
        let process = Process()
        process.launchPath = executablePath
        process.arguments = arguments
        
        let stderr = Pipe()
        let stdout = Pipe()
        
        process.standardError = stdout
        process.standardOutput = stdout
        
        try? process.run()
        
        let output: Legendary.CommandOutput = .init()
        
        stderr.fileHandleForReading.readabilityHandler = { handle in
            output.stderr = String(data: handle.availableData, encoding: .utf8) ?? .init()
            completion(output)
        }
        
        stderr.fileHandleForReading.readabilityHandler = { handle in
            output.stdout = String(data: handle.availableData, encoding: .utf8) ?? .init()
            completion(output)
        }
    }
}
