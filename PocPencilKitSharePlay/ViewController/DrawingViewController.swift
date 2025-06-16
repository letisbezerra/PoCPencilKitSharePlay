//  ViewController.swift
//  DrawingExample
//
//  Created by Leticia Bezerra on 04/06/25.
//

import UIKit
import PencilKit

final class DrawingViewController: UIViewController {
    // Definição do canvas(posso personalizar também)
    private let canvasView: PKCanvasView = {
        let cv = PKCanvasView()
        cv.drawingPolicy = .anyInput
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    private var customToolbar: UIToolbar!

    // State
    private var currentToolSet: ToolSet!
    private var currentOpacity: CGFloat = 1.0
    private var currentInkingWidth: CGFloat = 5
    private var currentEraserWidth: CGFloat = 5
    private var currentColor: UIColor!
    private var currentInkType: PKInkingTool.InkType!

    // Tools
    private var inkingTool: PKInkingTool!
    private var eraserTool: PKEraserTool!

    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupCanvas()
        setupToolbar()
        setupInitialToolSet()
    }

    // Setup
    private func setupCanvas() {
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupToolbar() {
        customToolbar = UIToolbar()
        customToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customToolbar)

        NSLayoutConstraint.activate([
            customToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        buildToolbarItems()
    }

    private func setupInitialToolSet() {
        // recebe do Model
        currentToolSet = ToolSetManager.random()
        apply(toolSet: currentToolSet)
        showToolsetInfo()
    }

    // Toolbar items
    private func buildToolbarItems() {
        let color1Item = UIBarButtonItem(
            image: UIImage(systemName: "circle.fill"),
            style: .plain,
            target: self,
            action: #selector(selectColor1))

        let color2Item = UIBarButtonItem(
            image: UIImage(systemName: "circle.fill"),
            style: .plain,
            target: self,
            action: #selector(selectColor2))

        let penItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil.tip"),
            style: .plain,
            target: self,
            action: #selector(selectPen))

        let eraserItem = UIBarButtonItem(
            image: UIImage(systemName: "eraser"),
            style: .plain,
            target: self,
            action: #selector(selectEraser))

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
            penItem, eraserItem,
            space,
            decreaseWidthItem, increaseWidthItem,
            space,
            decreaseOpacityItem, increaseOpacityItem,
            space,
            color1Item, color2Item
        ]
    }

    // Tool handling
    private func apply(toolSet: ToolSet) {
        currentInkType = toolSet.inkType
        currentColor   = toolSet.color1    // começa com a primeira cor
        inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
        eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
        canvasView.tool = inkingTool
        updateToolbarColors()
    }

    private func updateToolbarColors() {
        guard let items = customToolbar.items else { return }
        for item in items {
            if item.action == #selector(selectColor1) {
                item.image = UIImage(systemName: "circle.fill")?
                    .withTintColor(currentToolSet.color1, renderingMode: .alwaysOriginal)
            } else if item.action == #selector(selectColor2) {
                item.image = UIImage(systemName: "circle.fill")?
                    .withTintColor(currentToolSet.color2, renderingMode: .alwaysOriginal)
            }
        }
    }

    private func showToolsetInfo() {
        let inkName: String
        switch currentToolSet.inkType {
        case .pen:          inkName = "Caneta"
        case .pencil:       inkName = "Lápis"
        case .marker:       inkName = "Marcador"
        case .monoline:     inkName = "Monolinha"
        case .fountainPen:  inkName = "Caneta tinteiro"
        case .watercolor:   inkName = "Aquarela"
        case .crayon:       inkName = "Giz de cera"
        @unknown default:   inkName = "Ferramenta"
        }

        let alert = UIAlertController(
            title: "Ferramentas Selecionadas",
            message: "Tipo: \(inkName)\nCor 1: \(currentToolSet.color1.accessibilityName)\nCor 2: \(currentToolSet.color2.accessibilityName)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Toolbar actions

    @objc private func selectColor1() {
        currentColor = currentToolSet.color1
        inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
        canvasView.tool = inkingTool
    }

    @objc private func selectColor2() {
        currentColor = currentToolSet.color2
        inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
        canvasView.tool = inkingTool
    }

    @objc private func selectPen() {
        canvasView.tool = inkingTool
    }

    @objc private func selectEraser() {
        canvasView.tool = eraserTool
    }

    @objc private func increaseStrokeWidth() {
        if canvasView.tool is PKInkingTool {
            currentInkingWidth = min(currentInkingWidth + 2, 500)
            inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
            canvasView.tool = inkingTool
        } else {
            currentEraserWidth = min(currentEraserWidth + 2, 500)
            eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
            canvasView.tool = eraserTool
        }
    }

    @objc private func decreaseStrokeWidth() {
        if canvasView.tool is PKInkingTool {
            currentInkingWidth = max(currentInkingWidth - 2, 2)
            inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
            canvasView.tool = inkingTool
        } else {
            currentEraserWidth = max(currentEraserWidth - 2, 2)
            eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
            canvasView.tool = eraserTool
        }
    }

    @objc private func increaseOpacity() {
        currentOpacity = min(currentOpacity + 0.1, 1.0)
        updateOpacity()
    }

    @objc private func decreaseOpacity() {
        currentOpacity = max(currentOpacity - 0.1, 0.1)
        updateOpacity()
    }

    private func updateOpacity() {
        currentColor = currentColor.withAlphaComponent(currentOpacity)
        inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
        canvasView.tool = inkingTool
    }
}

#Preview {
    DrawingViewController()
}
