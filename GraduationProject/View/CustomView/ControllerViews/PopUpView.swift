//
//  CustomView.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 06.04.2023.
//

import UIKit

//MARK: - перечисление для выбора типа всплывающего представления
enum PopUpViewEnum {
    case income
    case expense
    case expenseCategory
}

//MARK: - перечисление и метод для доступа к кнопкам представлений
enum AccessButton {
    case available
    case notAvailable
}

func enable(button:UIButton, access:AccessButton) {
    switch access {
    case .available:
        button.isSelected = true
        button.isEnabled = true
        button.alpha = 1
    case .notAvailable:
        button.isSelected = false
        button.isEnabled = false
        button.alpha = 0.5
    }
}

final class PopUpView: UIView, UITextFieldDelegate {
    
    private var windowScene:CGRect = CGRect()
    private var keyboardSize:CGRect = CGRect()
    private var totalViewHeight:CGFloat = 0
    var nameTextField:UITextField = UITextField()
    var sumTextField:UITextField = UITextField()
    var viewButton:UIButton = UIButton()
    var transmitInfoDelegate:UniversalProtocol?
    var delegate:ClosingViewsProtocol? = nil

    // - инициализируем представление для размещения на нем полей ввода и кнопку добавления информации
    init(windowScene:CGRect, type:PopUpViewEnum?) {
        super.init(frame: windowScene)
        self.frame.origin.y = windowScene.maxY
        self.backgroundColor = .white
        self.windowScene = windowScene
        
        // - добавляем наблюдатель за клавиатурой
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        self.configureCustomView(type: type!)
        
        if type == .income {

            // - добавляем все представления на self
            self.addSubview(sumTextField)
            self.addSubview(viewButton)
            self.frame.size.height = (sumTextField.bounds.height + viewButton.bounds.height) + CGFloat((self.subviews.count + 1) * 16)
            
        } else if type == .expense {
            
            // - добавляем все представления на self
            self.addSubview(nameTextField)
            self.addSubview(viewButton)
            self.frame.size.height = (nameTextField.bounds.height + viewButton.bounds.height) + CGFloat((self.subviews.count + 1) * 16)

        } else if type == .expenseCategory {
            
            // - добавляем все представления на self
            self.addSubview(sumTextField)
            self.addSubview(nameTextField)
            self.addSubview(viewButton)
            self.frame.size.height = (sumTextField.bounds.height + nameTextField.bounds.height + viewButton.bounds.height) + CGFloat((self.subviews.count + 1) * 16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // - удаляем наблюдатель, чтобы избежать утечек памяти
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    // - определяем селектор для обработки событий, связанных с клавиатурой
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let totalViewWidth = windowScene.width

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.keyboardSize = keyboardSize
            
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.frame = CGRect(x: 0, y: strongSelf.windowScene.height - keyboardSize.height - strongSelf.frame.height, width: totalViewWidth, height: strongSelf.frame.height)
            }
        }
    }
    
    //MARK: - Создаем и конфигурируем представление с полем ввода суммы и кнопкой добавления информации в таблицу, добавляем жесты к представлениям и анимацию на закрытие представления
    
    private func configureCustomView(type:PopUpViewEnum) {
        
        // - в зависимости от type формируем главное представление
        if type == .income {
            
            configureSumTextField(positionY: 16)
            configureViewButton(positionY: 82)
            sumTextField.placeholder = "Сумма"
            sumTextField.attributedPlaceholder = NSAttributedString(string: sumTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            sumTextField.keyboardType = .numberPad
            viewButton.setTitle("Добавить доход", for: .normal)
            
        } else if type == .expense {
            
            configureNameTextField(positionY: 16)
            configureViewButton(positionY: 82)
            nameTextField.placeholder = "Наименование"
            nameTextField.attributedPlaceholder = NSAttributedString(string: nameTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            nameTextField.keyboardType = .default
            viewButton.setTitle("Добавить категорию расходов", for: .normal)
            
        } else if type == .expenseCategory {
            
            configureSumTextField(positionY: 16)
            configureNameTextField(positionY: 82)
            configureViewButton(positionY: 146)
            sumTextField.placeholder = "Сумма"
            sumTextField.attributedPlaceholder = NSAttributedString(string: sumTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            sumTextField.keyboardType = .numberPad
            nameTextField.placeholder = "Наименование"
            nameTextField.attributedPlaceholder = NSAttributedString(string: nameTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
            nameTextField.keyboardType = .default
            viewButton.setTitle("Добавить расход", for: .normal)
            
        }

        // - добавляем распознователь жеста на представление
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGestureRecognizer)

    }
    
    private func configureSumTextField(positionY:CGFloat) {
        
        // - создаем поле ввода суммы
        sumTextField = UITextField(frame: CGRect(x: 16, y: positionY, width: windowScene.width - 32, height: 50))
        sumTextField.borderStyle = .roundedRect
        sumTextField.backgroundColor = .init(red: 0, green: 0.478431, blue: 1, alpha: 0.1)
        sumTextField.clearButtonMode = .always
        sumTextField.textColor = .black
        sumTextField.textAlignment = .left
        sumTextField.keyboardAppearance = .light
    }
 
    private func configureNameTextField(positionY:CGFloat) {
        
        // - создаем поле ввода наименования
        nameTextField = UITextField(frame: CGRect(x: 16, y: positionY, width: windowScene.width - 32, height: 50))
        nameTextField.borderStyle = .roundedRect
        nameTextField.backgroundColor = .init(red: 0, green: 0.478431, blue: 1, alpha: 0.1)
        nameTextField.clearButtonMode = .always
        nameTextField.textColor = .black
        nameTextField.textAlignment = .left
        nameTextField.keyboardAppearance = .light
    }
    
    private func configureViewButton(positionY:CGFloat) {
        
        // - создаем кнопку для добавления дохода
        viewButton = UIButton(frame: CGRect(x: 16, y: positionY, width: windowScene.width - 32, height: 50))
        viewButton.backgroundColor = .systemBlue
        viewButton.layer.cornerRadius = 25
        viewButton.setTitleColor(.white, for: .normal)
        viewButton.addTarget(self, action: #selector(addIncome), for: .touchUpInside)
        enable(button: viewButton, access: .notAvailable)
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {

        let translation = gestureRecognizer.translation(in: self)
        if gestureRecognizer.state == .changed {
            if translation.y > 0 {
                self.frame.origin.y = windowScene.height - self.frame.height - keyboardSize.height + translation.y
            }
        } else if gestureRecognizer.state == .ended {
            if translation.y > 50 {
                closeViewForInput()
            }
            else {
                UIView.animate(withDuration: 0.5) { [weak self] in

                    guard let strongSelf = self else { return }
                    strongSelf.frame.origin.y = strongSelf.windowScene.height - strongSelf.frame.height - strongSelf.keyboardSize.height
                }
            }
        }
    }

    //MARK: - метод делегата UniversalCurrencyProtocol для передачи информации о введенной информации, приватный метод для закрытия представления на контроллере IncomeViewController
    
    @objc private func addIncome() {
        closeViewForInput()
        
        var textSum:String? = nil
        var textName:String? = nil
        
        if let text = sumTextField.text, !text.isEmpty {
            textSum = text
            sumTextField.text = ""
        }
        
        if let text = nameTextField.text, !text.isEmpty {
            textName = text
            nameTextField.text = ""
        }
        
        transmitInfoDelegate?.transmit(info: textSum, and: textName )
    }
    
    func closeViewForInput() {
        delegate?.closeViewForInput()
    }
}
