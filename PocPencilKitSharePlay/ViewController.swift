//  ViewController.swift
//  DrawingExample
//
//  Created by Leticia Bezerra on 04/06/25.
//

import UIKit
import PencilKit

class DrawingViewController: UIViewController {
    
    private let canvasView = PKCanvasView()
    private var crayonTool: PKInkingTool!
    private var eraserTool: PKEraserTool!
    private var customToolbar: UIToolbar!
    
    // Propriedades para controle de estado
    private var currentColor: UIColor = .systemRed
    private var isUsingColor1 = true
    private var currentEraserWidth: CGFloat = 10
    private var currentInkingWidth: CGFloat = 10
    
    private var currentOpacity: CGFloat = 1.0 // de 0.0 (transparente) a 1.0 (opaco)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvas()
        setupTools()
        setupCustomToolbar()
    }
    
    private func setupCanvas() {
        view.addSubview(canvasView)
        
        canvasView.drawingPolicy = .anyInput
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            canvasView.leftAnchor.constraint(equalTo: view.leftAnchor),
            canvasView.rightAnchor.constraint(equalTo: view.rightAnchor),
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateInkingTool() {
        let colorWithOpacity = currentColor.withAlphaComponent(currentOpacity)
        crayonTool = PKInkingTool(.crayon, color: colorWithOpacity, width: currentInkingWidth)
        canvasView.tool = crayonTool
    }

    private func setupTools() {
        // Configuração inicial da borracha
        eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
        
        // Configuração inicial do crayon
        crayonTool = PKInkingTool(.crayon, color: currentColor, width: currentInkingWidth)
        canvasView.tool = crayonTool
    }
    
    private func setupCustomToolbar() {
        customToolbar = UIToolbar()
        customToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customToolbar)
        
        NSLayoutConstraint.activate([
            customToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let color1Item = UIBarButtonItem(
            image: UIImage(systemName: "circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(selectColor1)
        )
                
        let color2Item = UIBarButtonItem(
            image: UIImage(systemName: "circle.fill")?.withTintColor(.systemMint, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(selectColor2)
        )
        
        let crayonItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil.tip"),
            style: .plain,
            target: self,
            action: #selector(selectCrayon))
        
        let decreaseWidthItem = UIBarButtonItem(
            image: UIImage(systemName: "minus.circle"),
            style: .plain,
            target: self,
            action: #selector(decreaseStrokeWidth)
        )

        let increaseWidthItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle"),
            style: .plain,
            target: self,
            action: #selector(increaseStrokeWidth)
        )
        
        let eraserItem = UIBarButtonItem(
            image: UIImage(systemName: "eraser"),
            style: .plain,
            target: self,
            action: #selector(selectEraser))
        
        let decreaseOpacityItem = UIBarButtonItem(
            image: UIImage(systemName: "circle.lefthalf.fill"),
            style: .plain,
            target: self,
            action: #selector(decreaseOpacity)
        )

        let increaseOpacityItem = UIBarButtonItem(
            image: UIImage(systemName: "circle.righthalf.fill"),
            style: .plain,
            target: self,
            action: #selector(increaseOpacity)
        )
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        customToolbar.items = [
            crayonItem,
            eraserItem,
            space,
            decreaseWidthItem,
            increaseWidthItem,
            space,
            decreaseOpacityItem,
            increaseOpacityItem,
            space,
            color1Item,
            color2Item
        ]
    }
    
    @objc func increaseOpacity() {
        currentOpacity = min(currentOpacity + 0.1, 1.0)
        updateInkingTool()
    }

    @objc func decreaseOpacity() {
        currentOpacity = max(currentOpacity - 0.1, 0.1)
        updateInkingTool()
    }
    
    @objc func increaseStrokeWidth() {
        if canvasView.tool is PKInkingTool {
            currentInkingWidth = min(currentInkingWidth + 2, 200) // Aumenta de 5 em 5
            updateInkingTool()
        } else if canvasView.tool is PKEraserTool {
            currentEraserWidth = min(currentEraserWidth + 2, 200)
            updateEraserTool()
        }
    }

    @objc func decreaseStrokeWidth() {
        if canvasView.tool is PKInkingTool {
            currentInkingWidth = max(currentInkingWidth - 5, 5) // Diminui de 5 em 5
            updateInkingTool()
        } else if canvasView.tool is PKEraserTool {
            currentEraserWidth = max(currentEraserWidth - 5, 5)
            updateEraserTool()
        }
    }
    
    private func updateEraserTool() {
        eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
        canvasView.tool = eraserTool
    }
    
    @objc func selectColor1() {
        currentColor = .systemRed
        isUsingColor1 = true
        updateInkingTool()
    }
    
    @objc func selectColor2() {
        currentColor = .systemMint
        isUsingColor1 = false
        updateInkingTool()
    }
    
    @objc func selectCrayon() {
        updateInkingTool()
    }
    
    @objc func selectEraser() {
        updateEraserTool()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        canvasView.becomeFirstResponder()
    }
}

#Preview {
    DrawingViewController()
}
