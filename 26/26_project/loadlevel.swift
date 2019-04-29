//
//  loadl2.swift
//  26_project
//
//  Created by Ayane on 4/29/19.
//  Copyright © 2019 Ayane. All rights reserved.
//for 2 challange

import SpriteKit

extension GameScene{
    
    func getString(){
        guard let fileUrl = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            fatalError("could not load file")
        }
        guard let string = try? String(contentsOf: fileUrl) else{
            fatalError("Could not make a string from fle contant")
        }
        arrayFromText = string.components(separatedBy: "\n")
    }
    
    
    func loadLevel2(){
        
        getString()
        
        for (row, line) in  arrayFromText.reversed().enumerated() {
            
            var lineArr = Array(line)
            
            
            if nextLev == true {
                if row == 10{ lineArr[3...14].shuffle() }
                else{ lineArr[1...14].shuffle()}
            }
            nextLev = true
            
            for (columnn, letter) in lineArr.enumerated(){
                nodePosition = CGPoint(x: 64 * columnn + 32, y: 64 * row + 32)
                
                if letter == "x" {
                    //load wall
                    configureNode(letter: "x", imageName:"wall", value: CollisionTypesEnum.wall)
                }
                else if letter == "v"{
                    //load vortex
                    configureNode(letter: "v", imageName:"vortex", value: CollisionTypesEnum.vortex)
                }
                else if letter == "s"{
                    //load star
                    configureNode(letter: "s", imageName:"star", value: CollisionTypesEnum.star)
                }
                else if letter == "f"{
                    //load finish
                    configureNode(letter: "f", imageName:"finish", value: CollisionTypesEnum.finish)
                }
                else if letter == "p"{
                    configureNode(letter: "p", imageName:"port", value: CollisionTypesEnum.port)
                }
                else if letter == " "{
                    //do nothing
                }
                else{
                    fatalError("no such letter")
                }
            }
        }
    }
    
    
    func configureNode(letter: String, imageName:String, value: CollisionTypesEnum){
        let node = SKSpriteNode(imageNamed: imageName)
        node.name = imageName
        node.position = nodePosition
        if imageName == "port"{portpositions.append(nodePosition)}
        node.physicsBody = (letter == "x" ) ? //|| letter == "f"
            SKPhysicsBody(rectangleOf: node.size) : SKPhysicsBody(circleOfRadius: node.size.width/2)
        if node.name == "vortex" {
            node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 0.25)))
        }
        node.physicsBody?.isDynamic = false
        node.physicsBody?.contactTestBitMask = CollisionTypesEnum.player.rawValue
        node.physicsBody?.categoryBitMask = value.rawValue
        if imageName != "wall" {
            node.physicsBody?.collisionBitMask = 0}
        
        addChild(node)
        
    }
    
    
}
