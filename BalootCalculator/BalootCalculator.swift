//
//  BalootCalculatorService.swift
//  BalootCalculator
//
//  Created by the Luckiest on 7/31/17.
//  Copyright © 2017 the Luckiest. All rights reserved.
//

import Foundation
import Darwin

enum ScoreType {
    case score
    case result
}

enum DistributerTurn {
    case me
    case right
    case front
    case left
}

class Score {
    var lana: Int
    var lahm: Int
    var type: ScoreType
    
    init(lana: Int, lahm: Int, type: ScoreType) {
        self.lana = lana
        self.lahm = lahm
        self.type = type
    }
}

class BalootCalculator {
    var result: [Score] = []
    var redoStack: [Score] = []
    var distributer: DistributerTurn = .me
    
    var currentScore: Score {
        if result.count == 0 {
            return Score(lana: 0, lahm: 0, type: .score)
        } else {
            return result.last!
        }
    }
    
    var hasRedo: Bool {
        return redoStack.count > 0
    }
    
    static var instance = BalootCalculator()
    
    func add(lana: Int, lahm: Int, isRedo: Bool = false) {
        if(result.count == 0) {
            let score = Score(lana: lana, lahm: lahm, type: .score)
            result.append(score)
        } else {
            let score = Score(lana: lana, lahm: lahm, type: .score)
            let lastScore = result.last!
            let resultScore = Score(lana: score.lana + lastScore.lana, lahm: score.lahm + lastScore.lahm, type: .result)
            
            result.append(score)
            result.append(resultScore)
            
        }
        if(!isRedo){
            self.redoStack.removeAll()
        }
        moveDistributer()
    }
    
    func moveDistributer() {
        if distributer == .me {
            distributer = .right
        } else if distributer == .right {
            distributer = .front
        } else if distributer == .front {
            distributer = .left
        } else {
            distributer = .me
        }
    }
    
    func backDistributer() {
        if distributer == .me {
            distributer = .left
        } else if distributer == .right {
            distributer = .me
        } else if distributer == .front {
            distributer = .right
        } else {
            distributer = .front
        }
    }
    
    func undo() {
        if(result.count == 0){
            return;
        } else if result.count == 1 {
            redoStack.append(result.last!)
            result.removeLast()
        } else {
            result.removeLast()
            redoStack.append(result.last!)
            result.removeLast()
        }
        backDistributer()
    }
    
    func redo() {
        if(redoStack.count == 0){
            return
        }
        let score = redoStack.popLast()!
        self.add(lana: score.lana, lahm: score.lahm, isRedo: true)
    }
    
    func newSaka() {
        result = []
        redoStack.removeAll()
    }
}
