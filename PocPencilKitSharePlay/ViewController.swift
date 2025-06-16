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
    private var currentEraserWidth: CGFloat = 5
    private var currentInkingWidth: CGFloat = 5
    private var currentOpacity: CGFloat = 1.0
    
    // Adicionando propriedades para armazenar as cores do conjunto
    private var color1: UIColor = .systemRed
    private var color2: UIColor = .systemMint
    private var currentInkType: PKInkingTool.InkType = .crayon
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvas()
        setupTools()
        setupCustomToolbar()
        
        // Gerar e aplicar um conjunto aleatório quando a view carrega
        setupToolSetsForTwoUsers()
    }
    
    // Configuração Inicial
    
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
        eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
        crayonTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
        canvasView.tool = crayonTool
    }
    
    // Sistema de Ferramentas Aleatórias
    
    // Lista de tipos de ferramentas de desenho disponíveis
    private var availableInkTypes: [PKInkingTool.InkType] {
        return [.pen, .pencil, .marker, .monoline, .fountainPen, .watercolor, .crayon]
    }
    
    // Lista de cores disponíveis
    private var availableColors: [UIColor] {
        return [
            .systemRed, .systemBlue, .systemGreen, .systemYellow, .systemOrange,
            .systemPurple, .systemPink, .systemTeal, .systemIndigo, .systemBrown,
            .systemMint, .systemCyan, .systemGray, .black
        ]
    }
    
    // Estrutura para representar um conjunto de ferramentas
    struct ToolSet {
        let inkType: PKInkingTool.InkType
        let color1: UIColor
        let color2: UIColor
    }
    
    // Método para gerar um conjunto aleatório de ferramentas
    private func generateRandomToolSet() -> ToolSet {
        let randomInkType = availableInkTypes.randomElement() ?? .crayon
        
        // Garantir que as duas cores sejam diferentes
        var randomColors = availableColors.shuffled().prefix(2)
        while randomColors.count < 2 {
            randomColors.append(.systemRed) // fallback
        }
        
        return ToolSet(
            inkType: randomInkType,
            color1: randomColors[0],
            color2: randomColors[1]
        )
    }
    
    // Método para configurar os conjuntos para dois usuários
    private func setupToolSetsForTwoUsers() {
        let user1ToolSet = generateRandomToolSet()
        
        // Aplica o conjunto para o usuário 1 (poderia ser adaptado para alternar entre usuários)
        applyToolSet(user1ToolSet)
        
        // Mostra as ferramentas selecionadas
        showToolsetInfo(toolSet: user1ToolSet)
    }
    
    // Aplica um conjunto de ferramentas
    private func applyToolSet(_ toolSet: ToolSet) {
        currentInkType = toolSet.inkType
        color1 = toolSet.color1
        color2 = toolSet.color2
        
        // Define a cor inicial
        currentColor = color1
        isUsingColor1 = true
        
        // Atualiza a ferramenta
        updateInkingTool()
        
        // Atualiza os ícones na toolbar
        updateToolbarColors()
    }
    
    // Atualiza as cores na toolbar
    private func updateToolbarColors() {
        guard let items = customToolbar.items else { return }
        
        for item in items {
            if item.action == #selector(selectColor1) {
                item.image = UIImage(systemName: "circle.fill")?
                    .withTintColor(color1, renderingMode: .alwaysOriginal)
            } else if item.action == #selector(selectColor2) {
                item.image = UIImage(systemName: "circle.fill")?
                    .withTintColor(color2, renderingMode: .alwaysOriginal)
            }
        }
    }
    
    // Mostra informações sobre as ferramentas selecionadas
    private func showToolsetInfo(toolSet: ToolSet) {
        let inkTypeName: String
        switch toolSet.inkType {
        case .pen: inkTypeName = "Caneta"
        case .pencil: inkTypeName = "Lápis"
        case .marker: inkTypeName = "Marcador"
        case .monoline: inkTypeName = "Monolinha"
        case .fountainPen: inkTypeName = "Caneta tinteiro"
        case .watercolor: inkTypeName = "Aquarela"
        case .crayon: inkTypeName = "Giz de cera"
        @unknown default: inkTypeName = "Ferramenta"
        }
        
        let alert = UIAlertController(
            title: "Ferramentas Selecionadas",
            message: "Tipo: \(inkTypeName)\nCor 1: \(toolSet.color1.accessibilityName)\nCor 2: \(toolSet.color2.accessibilityName)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Atualização de Ferramentas
    
    private func updateInkingTool() {
        let colorWithOpacity = currentColor.withAlphaComponent(currentOpacity)
        crayonTool = PKInkingTool(currentInkType, color: colorWithOpacity, width: currentInkingWidth)
        canvasView.tool = crayonTool
    }
    
    private func updateEraserTool() {
        eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
        canvasView.tool = eraserTool
    }
    
    // Configuração da Toolbar
    
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
            image: UIImage(systemName: "circle.fill")?.withTintColor(color1, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(selectColor1))
                
        let color2Item = UIBarButtonItem(
            image: UIImage(systemName: "circle.fill")?.withTintColor(color2, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(selectColor2))
        
        let crayonItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil.tip"),
            style: .plain,
            target: self,
            action: #selector(selectCrayon))
        
        let decreaseWidthItem = UIBarButtonItem(
            image: UIImage(systemName: "minus.circle"),
            style: .plain,
            target: self,
            action: #selector(decreaseStrokeWidth))
        
        let increaseWidthItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle"),
            style: .plain,
            target: self,
            action: #selector(increaseStrokeWidth))
        
        let eraserItem = UIBarButtonItem(
            image: UIImage(systemName: "eraser"),
            style: .plain,
            target: self,
            action: #selector(selectEraser))
        
        let decreaseOpacityItem = UIBarButtonItem(
            image: UIImage(systemName: "circle.lefthalf.fill"),
            style: .plain,
            target: self,
            action: #selector(decreaseOpacity))
        
        let increaseOpacityItem = UIBarButtonItem(
            image: UIImage(systemName: "circle.righthalf.fill"),
            style: .plain,
            target: self,
            action: #selector(increaseOpacity))
        
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
    
    // Ações da Toolbar
    
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
            currentInkingWidth = min(currentInkingWidth + 2, 500)
            updateInkingTool()
        } else if canvasView.tool is PKEraserTool {
            currentEraserWidth = min(currentEraserWidth + 2, 500)
            updateEraserTool()
        }
    }

    @objc func decreaseStrokeWidth() {
        if canvasView.tool is PKInkingTool {
            currentInkingWidth = max(currentInkingWidth - 2, 2)
            updateInkingTool()
        } else if canvasView.tool is PKEraserTool {
            currentEraserWidth = max(currentEraserWidth - 2, 2)
            updateEraserTool()
        }
    }
    
    @objc func selectColor1() {
        currentColor = color1
        isUsingColor1 = true
        updateInkingTool()
    }
    
    @objc func selectColor2() {
        currentColor = color2
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
