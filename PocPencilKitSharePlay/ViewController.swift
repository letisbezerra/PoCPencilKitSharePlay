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
    
    private var color1 = PKInkingTool(.crayon, color: .systemRed, width: 10)
    private var color2 = PKInkingTool(.crayon, color: .systemMint, width: 10)
    
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
    
    private func setupTools() {
        // Configuração da borracha (opcional)
        eraserTool = PKEraserTool(.bitmap)
        eraserTool.width = 10
        
        // Define o crayon como ferramenta inicial
        crayonTool = color1
        canvasView.tool = crayonTool
    }
    
    private func setupCustomToolbar() {
        // Cria uma toolbar customizada para substituir o PKToolPicker
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
                
        // Botão para a segunda cor
        let color2Item = UIBarButtonItem(
            image: UIImage(systemName: "circle.fill")?.withTintColor(.systemMint, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(selectColor2)
        )
        
        // Cria itens para a toolbar
        let crayonItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil.tip"),
            style: .plain,
            target: self,
            action: #selector(selectCrayon))
        
        let eraserItem = UIBarButtonItem(
            image: UIImage(systemName: "eraser"),
            style: .plain,
            target: self,
            action: #selector(selectEraser))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        customToolbar.items = [crayonItem, space, color1Item, color2Item, space, eraserItem]
    }
    
    @objc func selectColor1() {
        crayonTool = color1
        canvasView.tool = crayonTool
    }
    
    @objc func selectColor2() {
        crayonTool = color2
        canvasView.tool = crayonTool
    }
    
    @objc func selectCrayon() {
        canvasView.tool = crayonTool
    }
    
    @objc func selectEraser() {
        canvasView.tool = eraserTool
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        canvasView.becomeFirstResponder()
    }
}

#Preview {
    DrawingViewController()
}
