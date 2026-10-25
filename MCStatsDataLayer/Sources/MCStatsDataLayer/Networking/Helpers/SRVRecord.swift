import Foundation

// THIS CODE WAS MODIFIED from https://github.com/jamf/NoMAD-2
public struct SRVResult {
    let SRVRecords: [SRVRecord]
    let query: String
}

extension SRVResult: CustomStringConvertible {
    public var description: String {
        var result = "Query for: \(query)"
        result += "\n\tRecord Count: \(SRVRecords.count)"
        
        for record in SRVRecords {
            result += "\n\t\(record.description)"
        }
        
        return result
    }
}

public struct SRVRecord: Codable, Equatable {
    let priority: Int
    let weight: Int
    let port: Int
    let target: String
    
    init?(data: Data) {
        var workingTarget = ""
        
        guard data.count > 8 else {
            return nil
        }
        
        priority = Int(data[0]) * 256 + Int(data[1])
        weight = Int(data[2]) * 256 + Int(data[3])
        port = Int(data[4]) * 256 + Int(data[5])
        
        // data[6] will always be a unicode control character
        // starting off the actual hostname, so we skip it
        
        for byte in data[7...(data.count - 1)] {
            if let charData = String(data: Data([byte]), encoding: .utf8), let char = charData.first {
                
                // strip out the unicode control characters
                // there's probably a better, more complete way
                
                if NSCharacterSet.controlCharacters.containsUnicodeScalars(of: char) {
                    if charData != "\0" {
                        workingTarget += "."
                    }
                } else {
                    workingTarget += charData
                }
            }
        }
        
        target = workingTarget
    }
}

extension SRVRecord: CustomStringConvertible {
    public var description: String {
        "\(target) \(priority) \(weight) \(port)"
    }
}

extension CharacterSet {
    func containsUnicodeScalars(of character: Character) -> Bool {
        character.unicodeScalars.allSatisfy(contains(_:))
    }
}
