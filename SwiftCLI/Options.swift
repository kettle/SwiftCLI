//
//  Options.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

typealias OptionsFlagBlock = (flag: String) -> ()
typealias OptionsKeyBlock = (key: String, value: String) -> ()

class Options {
    
    let combinedFlagsAndKeys: [String]
    var flagOptions: [String] = []
    var keyedOptions: [String: String] = [:]
    
    var accountedForFlags: [String] = []
    var accountedForKeys: [String] = []
        
    init(args: [String]) {
        self.combinedFlagsAndKeys = args
        
        self.splitArguments()
    }
    
    func splitArguments() {
        var skipNext = false
        for index in 0..<self.combinedFlagsAndKeys.count {
            if skipNext {
                skipNext = false
                continue
            }
            
            let argument = self.combinedFlagsAndKeys[index]
            
            if index < self.combinedFlagsAndKeys.count-1 {
                let nextArgument = self.combinedFlagsAndKeys[index+1]
                
                if nextArgument.hasPrefix("-") {
                    self.flagOptions += argument
                } else {
                    self.keyedOptions[argument] = nextArgument
                    skipNext = true
                }
                
            } else {
                self.flagOptions += argument
            }
            
        }
    }
    
    func description() -> String {
        return "Flag options: \(self.flagOptions) Keyed options: \(self.keyedOptions)"
    }
    
    // Flags

    func onFlag(flag: String, block: OptionsFlagBlock?) {
        if contains(self.flagOptions, flag) {
            self.accountedForFlags += flag
            block?(flag: flag)
        }
    }

    func onFlags(flags: [String], block: OptionsFlagBlock?) {
        for flag in flags {
            self.onFlag(flag, block: block)
        }
    }
    
    // Keys

    func onKey(key: String, block: OptionsKeyBlock?) {
        if contains(Array(self.keyedOptions.keys), key) {
            self.accountedForKeys += key
            block?(key: key, value: self.keyedOptions[key]!)
        }
    }
    
    func onKeys(keys: [String], block: OptionsKeyBlock?) {
        for key in keys {
            self.onKey(key, block: block)
        }
    }
    
    // Other publics

    func allAccountedFor() -> Bool {
        return self.remainingFlags().count == 0 && self.remainingOptions().count == 0
    }
    
    func unaccountedForMessage(#command: Command) -> String {
        var message = "Unrecognized options:"
        for flag in self.remainingFlags() {
            message += "\n\t\(flag)"
        }
        for option in self.remainingOptions() {
            message += "\n\t\(option) \(self.keyedOptions[option]!)"
        }
        
        message += "\n"
        
        message += command.commandUsageStatement()
        
        return message
    }
    
    // Privates
    
    private func remainingFlags() -> [String] {
        let remainingFlags = NSMutableArray(array: self.flagOptions)
        remainingFlags.removeObjectsInArray(self.accountedForFlags)
        var stringArray = NSArray(array: remainingFlags) as [String]
        return stringArray
    }
    
    private func remainingOptions() -> [String] {
        let remainingOptions = NSMutableArray(array: Array(self.keyedOptions.keys))
        remainingOptions.removeObjectsInArray(self.accountedForKeys)
        var stringArray = NSArray(array: remainingOptions) as [String]
        return stringArray
    }
    
}