//
//  String.swift
//  ListingApp
//
//  Created by Florian Marcu on 6/10/18.
//  Copyright © 2018 Instamobile. All rights reserved.
//

import UIKit

extension String {

    static func isEmpty(_ str: String?) -> Bool {
        return (str == nil || (str?.count ?? 0) <= 0)
    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }

    func atcTrimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func naturalColorNameToHexString() -> String {
        switch self.lowercased() {
            case "black": return "#000000"
            case "darkGray": return "#333333"
            case "lightGray": return "#cccccc"
            case "white": return "#ffffff"
            case "gray": return "#666666"
            case "red": return "#FF0000"
            case "green": return "#00ff00"
            case "blue": return "#0000FF"
            case "cyan": return "#00FFFF"
            case "yellow": return "#ffff00"
            case "magenta": return "#ff00ff"
            case "orange": return "#ffa500"
            case "purple": return "#800080"
            case "brown": return "#654321"
            default: return "#666666"
        }
    }
    
    func htmlToAttributedString(textColor: UIColor) -> NSAttributedString {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            guard !self.isEmpty else {
                return NSAttributedString()
            }
            var modifiedFont = self.replacingOccurrences(of: "<font color='#007AFF'>", with: "InstamobileHtmlStringTag1")
            modifiedFont = modifiedFont.replacingOccurrences(of: "</font>", with: "InstamobileHtmlStringTag2")
            modifiedFont = modifiedFont.replacingOccurrences(of: "<", with: "&lt;")
            modifiedFont = modifiedFont.replacingOccurrences(of: "InstamobileHtmlStringTag1", with: "<font color='#007AFF'>")
            modifiedFont = modifiedFont.replacingOccurrences(of: "InstamobileHtmlStringTag2", with: "</font>")
            
            modifiedFont = String(format:"<span style=\"color:\(textColor.toHexString());font-family: '-apple-system', 'SFUI-Regular'; font-size: 15\">%@</span>", modifiedFont)
            
            modifiedFont = modifiedFont.replacingOccurrences(of: "\n", with: "<br>")
            modifiedFont = modifiedFont.replacingOccurrences(of: "  ", with: "&nbsp;&nbsp;")

            let attrStr = try! NSAttributedString(
                data: modifiedFont.data(using: .unicode, allowLossyConversion: true)!,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue],
                documentAttributes: nil)
            return attrStr
        } catch {
            return NSAttributedString()
        }
    }
     
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x2600...0x26FF,   // Misc symbols
                 0x2700...0x27BF,   // Dingbats
                 0xFE00...0xFE0F,   // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }
    
    func levenshteinDistanceScore(to string: String, ignoreCase: Bool = true, trimWhiteSpacesAndNewLines: Bool = true) -> Double {

        var firstString = self
        var secondString = string

        if ignoreCase {
            firstString = firstString.lowercased()
            secondString = secondString.lowercased()
        }
        if trimWhiteSpacesAndNewLines {
            firstString = firstString.trimmingCharacters(in: .whitespacesAndNewlines)
            secondString = secondString.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let empty = [Int](repeating:0, count: secondString.count)
        var last = [Int](0...secondString.count)

        for (i, tLett) in firstString.enumerated() {
            var cur = [i + 1] + empty
            for (j, sLett) in secondString.enumerated() {
                cur[j + 1] = tLett == sLett ? last[j] : Swift.min(last[j], last[j + 1], cur[j])+1
            }
            last = cur
        }

        // maximum string length between the two
        let lowestScore = max(firstString.count, secondString.count)

        if let validDistance = last.last {
            return  1 - (Double(validDistance) / Double(lowestScore))
        }

        return 0.0
    }

}

extension NSAttributedString {
    func fetchAttributedText(allTagUsers: [String]) -> String {
        
        var allSubstrings = ""
        var isPreviuosAttrbiutedString = ""

        for (index, str) in self.string.enumerated() {
            let strr = self.attributes(at: index, effectiveRange: nil)
            let checkBlue = "\(strr[NSAttributedString.Key.init(rawValue: "NSColor")])"
            if checkBlue.contains("0 0.478431 1 1") {
                isPreviuosAttrbiutedString.append(str)
                if index == self.string.count - 1 {
                    if !isPreviuosAttrbiutedString.isEmpty {
                        let filterTagUser = allTagUsers.filter { (str) -> Bool in
                            return isPreviuosAttrbiutedString.levenshteinDistanceScore(to: str, ignoreCase: false, trimWhiteSpacesAndNewLines: true) == 1.0
                        }.first
                        if let filterTagUser = filterTagUser {
                            let filterInPreviuosAttrbiutedString = isPreviuosAttrbiutedString.replacingOccurrences(of: filterTagUser, with: "")
                            allSubstrings += "<font color='#007AFF'>\(filterTagUser)</font>"
                            allSubstrings += filterInPreviuosAttrbiutedString
                        } else {
                            var checkIsPreviuosAttrbiutedString = isPreviuosAttrbiutedString
                            checkIsPreviuosAttrbiutedString.insert(allSubstrings.last ?? Character("@"), at: checkIsPreviuosAttrbiutedString.startIndex)
                            
                            let filterTagUser = allTagUsers.filter { (str) -> Bool in
                                return checkIsPreviuosAttrbiutedString.levenshteinDistanceScore(to: str, ignoreCase: false, trimWhiteSpacesAndNewLines: true) == 1.0
                            }.first
                            if let filterTagUser = filterTagUser {
                                let filterInPreviuosAttrbiutedString = checkIsPreviuosAttrbiutedString.replacingOccurrences(of: filterTagUser, with: "")
                                allSubstrings.removeLast()
                                allSubstrings += "<font color='#007AFF'>\(filterTagUser)</font>"
                                allSubstrings += filterInPreviuosAttrbiutedString
                            } else {
                                allSubstrings += isPreviuosAttrbiutedString
                            }
                        }
                    }
                    isPreviuosAttrbiutedString = ""
                }
            } else {
                if !isPreviuosAttrbiutedString.isEmpty {
                    let filterTagUser = allTagUsers.filter { (str) -> Bool in
                        return isPreviuosAttrbiutedString.levenshteinDistanceScore(to: str, ignoreCase: false, trimWhiteSpacesAndNewLines: true) == 1.0
                    }.first
                    if let filterTagUser = filterTagUser {
                        let filterInPreviuosAttrbiutedString = isPreviuosAttrbiutedString.replacingOccurrences(of: filterTagUser, with: "")
                        allSubstrings += "<font color='#007AFF'>\(filterTagUser)</font>"
                        allSubstrings += filterInPreviuosAttrbiutedString
                    } else {
                        var checkIsPreviuosAttrbiutedString = isPreviuosAttrbiutedString
                        checkIsPreviuosAttrbiutedString.insert(allSubstrings.last ?? Character("@"), at: checkIsPreviuosAttrbiutedString.startIndex)
                        
                        let filterTagUser = allTagUsers.filter { (str) -> Bool in
                            return checkIsPreviuosAttrbiutedString.levenshteinDistanceScore(to: str, ignoreCase: false, trimWhiteSpacesAndNewLines: true) == 1.0
                        }.first
                        if let filterTagUser = filterTagUser {
                            let filterInPreviuosAttrbiutedString = checkIsPreviuosAttrbiutedString.replacingOccurrences(of: filterTagUser, with: "")
                            allSubstrings.removeLast()
                            allSubstrings += "<font color='#007AFF'>\(filterTagUser)</font>"
                            allSubstrings += filterInPreviuosAttrbiutedString
                        } else {
                            allSubstrings += isPreviuosAttrbiutedString
                        }
                    }
                }
                allSubstrings.append(str)
                isPreviuosAttrbiutedString = ""
            }
            
        }
        
        return allSubstrings
    }
}
