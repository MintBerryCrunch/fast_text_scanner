//
//  ORCValidationService.swift
//
//
//  Created by Pavel Kozlov on 14/10/2019.
//  Copyright © 2019 Pavel Kozlov. All rights reserved.
//

import Foundation

extension String {
    func replaceCharactersFromSet(characterSet: CharacterSet, replacementString: String = "") -> String {
        return components(separatedBy: characterSet).joined(separator: replacementString)
    }
    
    public var countDigits: Int {
        return  self
            .components(separatedBy:CharacterSet.decimalDigits.inverted)
            .joined().count
    }
}

class OCRValidationService {
    private let ocrString: String
    
    init?(ocr: String) {
        let pattern = "[^A-Za-z0-9]+"
        let result = ocr.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
        self.ocrString = result
    }
    
    private func to(letters: String) -> String {
        var updated = letters.uppercased()
        updated = updated.replacingOccurrences(of: "0", with: "O")
        updated = updated.replacingOccurrences(of: "1", with: "I")
        updated = updated.replacingOccurrences(of: "4", with: "A")
        return updated
    }
    
    private func to(numbers: String) -> String {
        var updated = numbers.uppercased()
        updated = updated.replacingOccurrences(of: "Q", with: "0")
        updated = updated.replacingOccurrences(of: "O", with: "0")
        updated = updated.replacingOccurrences(of: "D", with: "0")
        updated = updated.replacingOccurrences(of: "E", with: "0")
        updated = updated.replacingOccurrences(of: "C", with: "0")
        updated = updated.replacingOccurrences(of: "G", with: "0")
        updated = updated.replacingOccurrences(of: "J", with: "1")
        updated = updated.replacingOccurrences(of: "B", with: "6")
        updated = updated.replacingOccurrences(of: "I", with: "1")
        updated = updated.replacingOccurrences(of: "L", with: "1")
        updated = updated.replacingOccurrences(of: "A", with: "4")
        return updated
    }
    
    func validate() -> String? {
        var regex = try! NSRegularExpression(pattern: "^([A-Z]{3})([0-9]{5})([a-z])?$")
        if regex.firstMatch(in: ocrString, options: [], range: NSRange(location: 0, length: ocrString.count)) != nil {
            return ocrString
        }
        if ocrString.count < 4 || ocrString.count > 14{
            return nil
        }
        
        let start = ocrString.index(ocrString.startIndex, offsetBy: 0)
        let end = ocrString.index(ocrString.startIndex, offsetBy: 3)
        var startString = String(ocrString[start..<end])
        var endString = String(ocrString[end...])
        let lastChar = String(ocrString.last ?? " ")
        let range = NSRange(location: 0, length: 1)
        
        var ending: String?
        
        regex = try! NSRegularExpression(pattern: "[a-z]{1}")
        if regex.firstMatch(in: lastChar, options: [], range: range) != nil {
            ending = lastChar
            endString = String(endString.removeLast())
        }
        
        startString = to(letters: startString)
        endString = to(numbers: endString)
        
        let finalString = [startString, endString, ending].compactMap{$0}.joined()
        if regex.firstMatch(in: finalString, options: [], range: NSRange(location: 0, length: finalString.count)) != nil {
            return finalString
        }
        
        regex = try! NSRegularExpression(pattern: "^([^\\s]+)([0-9]+)([a-z])?$")
        if regex.firstMatch(in: ocrString, options: [], range: NSRange(location: 0, length: ocrString.count)) != nil {
            return ocrString
        }
        if regex.firstMatch(in: finalString, options: [], range: NSRange(location: 0, length: finalString.count)) != nil {
            return finalString
        }
        
        return nil
    }
    
    func peruMask() -> String? {
        let string = Array(ocrString.uppercased())
        
        if string.count == 11 {
            //Peru: 010IM 123456
            var numberOrMatchesFirstPart = [Bool]()
            
            if string[0] == "0"{
                numberOrMatchesFirstPart.append(true)
            }
            if string[1] == "1" {
                numberOrMatchesFirstPart.append(true)
            }
            if string[2] == "0" {
                numberOrMatchesFirstPart.append(true)
            }
            if string[3] == "I"{
                numberOrMatchesFirstPart.append(true)
            }
            if string[4] == "M" {
                numberOrMatchesFirstPart.append(true)
            }
            
            
            let start = ocrString.index(ocrString.startIndex, offsetBy: 5)
            var numericString = String(ocrString.uppercased()[start...])
            
            let numberOrMatchesSecondPart = numericString.countDigits
            
            if numberOrMatchesFirstPart.count > 3 && numberOrMatchesSecondPart > 3 {
                let zeroLike = CharacterSet(charactersIn: "QODCGU")     //0
                let oneLike = CharacterSet(charactersIn: "JILKV")       //1
                let twoLike = CharacterSet(charactersIn: "ZRW")         //2
                let threeLike = CharacterSet(charactersIn: "E")         //3
                let fourLike = CharacterSet(charactersIn: "AHMN")       //4
                let fiveLike = CharacterSet(charactersIn: "S")          //5
                let sixLike = CharacterSet(charactersIn: "")            //6
                let sevenLike = CharacterSet(charactersIn: "TZ")        //7
                let eightLike = CharacterSet(charactersIn: "BFPX")      //8
                let nineLike = CharacterSet(charactersIn: "Y")          //9
                
                numericString = numericString.replaceCharactersFromSet(characterSet: zeroLike, replacementString: "0")
                    .replaceCharactersFromSet(characterSet: oneLike, replacementString: "1")
                    .replaceCharactersFromSet(characterSet: twoLike, replacementString: "2")
                    .replaceCharactersFromSet(characterSet: threeLike, replacementString: "3")
                    .replaceCharactersFromSet(characterSet: fourLike, replacementString: "4")
                    .replaceCharactersFromSet(characterSet: fiveLike, replacementString: "5")
                    .replaceCharactersFromSet(characterSet: sixLike, replacementString: "6")
                    .replaceCharactersFromSet(characterSet: sevenLike, replacementString: "7")
                    .replaceCharactersFromSet(characterSet: eightLike, replacementString: "8")
                    .replaceCharactersFromSet(characterSet: nineLike, replacementString: "9")
                return "010IM\(numericString)"
            }
            
        }
        return nil
    }
}
