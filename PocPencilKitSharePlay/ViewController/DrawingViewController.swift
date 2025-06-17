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
        setupSliders()
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
    
    // Setup Sliders
    private func setupSliders() {
        view.addSubview(opacitySlider)
        view.addSubview(opacityIcon)
        view.addSubview(widthSlider)
        view.addSubview(widthIcon)

        NSLayoutConstraint.activate([
            // Slider de Opacidade (superior)
            opacitySlider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -60),
            opacitySlider.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),

            // Ícone de opacidade
            opacityIcon.centerXAnchor.constraint(equalTo: opacitySlider.centerXAnchor),
            opacityIcon.bottomAnchor.constraint(equalTo: opacitySlider.topAnchor, constant: -100),

            // Slider de Espessura (inferior)
            widthSlider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -60),
            widthSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),

            // Ícone de espessura
            widthIcon.centerXAnchor.constraint(equalTo: widthSlider.centerXAnchor),
            widthIcon.bottomAnchor.constraint(equalTo: widthSlider.topAnchor, constant: 150),
        ])

        // Ações
        opacitySlider.addTarget(self, action: #selector(opacitySliderChanged), for: .valueChanged)
        widthSlider.addTarget(self, action: #selector(widthSliderChanged), for: .valueChanged)
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
    
    private lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let opacitySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.1
        slider.maximumValue = 1.0
        slider.value = 1.0
        slider.transform = CGAffineTransform(rotationAngle: -.pi/2)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.widthAnchor.constraint(equalToConstant: 200).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return slider
    }()
    
    private let widthSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 2
        slider.maximumValue = 50
        slider.value = 5
        slider.transform = CGAffineTransform(rotationAngle: -.pi/2)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.widthAnchor.constraint(equalToConstant: 200).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return slider
    }()
    
    private let opacityIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "circle.lefthalf.filled"))
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let widthIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "lineweight"))
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func saveDrawingAsImage() {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
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
        
        let saveItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(saveButtonTapped)
        )

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        customToolbar.items = [
            eraserItem,
            space,
            penItem,
            color1Item, color2Item,
            space,
            saveItem
        ]
    }

    // Tool handling
    private func apply(toolSet: ToolSet) {
        currentInkType = toolSet.inkType
        currentColor = toolSet.color1
        currentOpacity = 1.0           // Garante que a opacidade seja reiniciada
        currentInkingWidth = 5         // Define um tamanho padrão para o pincel
        
        inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
        eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
        canvasView.tool = inkingTool
            
        // Sincroniza os sliders com os valores atuais
        opacitySlider.value = Float(currentOpacity)
        widthSlider.value = Float(currentInkingWidth)
            
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
            currentInkingWidth = min(currentInkingWidth + 2, 50)
            widthSlider.value = Float(currentInkingWidth)
            inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
            canvasView.tool = inkingTool
        } else {
            currentEraserWidth = min(currentEraserWidth + 2, 50)
            widthSlider.value = Float(currentEraserWidth)
            eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
            canvasView.tool = eraserTool
        }
    }
    
    @objc private func decreaseStrokeWidth() {
        if canvasView.tool is PKInkingTool {
            currentInkingWidth = max(currentInkingWidth - 2, 2)
            widthSlider.value = Float(currentInkingWidth)
            inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
            canvasView.tool = inkingTool
        } else {
            currentEraserWidth = max(currentEraserWidth - 2, 2)
            widthSlider.value = Float(currentEraserWidth)
            eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
            canvasView.tool = eraserTool
        }
    }
    
    @objc private func opacitySliderChanged(_ sender: UISlider) {
        currentOpacity = CGFloat(sender.value)
        updateOpacity()
    }
       
    @objc private func widthSliderChanged(_ sender: UISlider) {
        if canvasView.tool is PKInkingTool {
            currentInkingWidth = CGFloat(sender.value)
            inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
            canvasView.tool = inkingTool
        } else {
            currentEraserWidth = CGFloat(sender.value)
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
        opacitySlider.value = Float(currentOpacity)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alert: UIAlertController
        if let error = error {
            alert = UIAlertController(title: "Erro", message: "Não foi possível salvar: \(error.localizedDescription)", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Salvo", message: "Sua imagem foi salva na galeria com sucesso.", preferredStyle: .alert)
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        saveDrawingAsImage()
    }
}

#Preview {
    DrawingViewController()
}
