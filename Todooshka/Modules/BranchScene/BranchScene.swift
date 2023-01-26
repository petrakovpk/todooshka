//
//  BranchScene.swift
//  Todooshka
//
//  Created by Петраков Павел Константинович on 26.11.2021.
//

import UIKit
import SpriteKit

class BranchScene: SKScene {
  private var actions: [BirdActionType] = [.create, .create, .create, .create, .create, .create, .create]
  private var SKBirdNodes: [SKBirdNode] = []

  // MARK: - UI Nodes
  private let background: SKSpriteNode = {
    let node = SKSpriteNode()
    node.xScale = Style.Scene.scale * 1.5
    node.yScale = Style.Scene.scale * 1.5
    node.name = "background"
    return node
  }()

  // MARK: - Lifecycle
  override func didMove(to view: SKView) {
    if let scene = scene {
      scene.position = view.frame.origin
      scene.size = view.size
      scene.backgroundColor = .clear

      addChild(background)

      background.position = CGPoint(x: position.x + 40, y: position.y)

      SKBirdNodes = [
        SKBirdNode(level: 1, style: .simple),
        SKBirdNode(level: 2, style: .simple),
        SKBirdNode(level: 3, style: .simple),
        SKBirdNode(level: 4, style: .simple),
        SKBirdNode(level: 5, style: .simple),
        SKBirdNode(level: 6, style: .simple),
        SKBirdNode(level: 7, style: .simple)
      ]

      for node in SKBirdNodes {
        addChild(node)
        node.position = Settings.Birds.BranchPosition[node.level] ?? .zero
      }
    }
  }

  // MARK: - BackgroundNode
  func setup(with backgroundImage: UIImage) {
    let texture = SKTexture(image: backgroundImage)
    let action = SKAction.setTexture(texture, resize: false)
    background.run(action)
  }

  func setup(with actions: [BirdActionType]) {
    self.actions = actions
  }

  // MARK: - DataSource
    func reloadData() {
      let hiddenBirds = SKBirdNodes.filter { $0.action == .hide }

      for (index, node) in SKBirdNodes.enumerated() {
        guard let action = actions[safe: index] else { return }

        switch (node.action, action) {
        case let (.create, .sitting(newStyle, _)):
          node.changeStyle(style: newStyle, withDelay: false)

        case let (.hide, .sitting(newStyle, _)):
          node.changeStyle(style: newStyle, withDelay: hiddenBirds.count != 7 )

        case let (.sitting(oldStyle, oldClosed), .sitting(newStyle, newClosed)):
          if Calendar.current.isDate(oldClosed, inSameDayAs: newClosed) == false || oldStyle != newStyle {
            node.changeStyle(style: newStyle, withDelay: true)
          }

        case (_, .hide):
          node.hide()
        default:
          continue
        }

        node.action = action
      }
    }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let location = touch.location(in: self)
      let touchedNode = self.nodes(at: location)
      for node in touchedNode {
        for bird in SKBirdNodes where node == bird {
          if bird.wingsIsUp {
            bird.wingsIsUp = false
            bird.dowsWings()
          } else {
            bird.wingsIsUp = true
            bird.upWings()
          }
        }
      }
    }
  }
}
