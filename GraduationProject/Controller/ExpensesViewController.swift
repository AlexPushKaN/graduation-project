//
//  ViewController.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 03.04.2023.
//

import UIKit

final class ExpensesViewController: UIViewController, UniversalProtocol, ClosingViewsProtocol {

    @IBOutlet weak var expenseTableView: UITableView!
    
    private var expenseCategoryString:String = ""
    private var classInitialized:Bool = false
    
    private lazy var popUpView = {
        let view = PopUpView(windowScene: self.view.bounds, type: .expense)
        classInitialized = true
        return view
    }()
    
    private lazy var backgroundView = {
        let view = BackgroundView(frame: self.view.bounds)
        return view
    }()

    private lazy var coreDataManager = {
        return CoreDataManager.self
    }()
    
    private var expenses:Expenses?
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // - взаимодействие с СoreDataManager, создание Expenses и/или получение из Core Data
        if let object = coreDataManager.getObjectFromData(object: .expenses) as? Expenses {
            self.expenses = object
        } else {
            let object = coreDataManager.create(object: .expenses) as? Expenses
            self.expenses = object
        }
        
        popUpView.nameTextField.delegate = self
        popUpView.transmitInfoDelegate = self
        expenseTableView.delegate = self
        expenseTableView.dataSource = self

    }

    override func viewDidDisappear(_ animated: Bool) {
        if classInitialized {
            popUpView.removeFromSuperview()
            backgroundView.removeFromSuperview()
        }
    }
    
    //MARK: - Реализация UniversalProtocol, взаимодействие с СoreDataManager, создание объектов и/или их изменение, сохранение в Core Data
    
    func transmit(info _ : String?, and expenseCategory: String?)  {
        guard let text = expenseCategory else { return }
        let expenseCategory = coreDataManager.create(object: .expenseCategory) as! ExpenseCategory
        expenseCategory.name = text
        guard let expenses = self.expenses else { return }
        expenses.addToQuantity(expenseCategory)
        coreDataManager.save()
        expenseCategoryString = ""
        expenseTableView.reloadData()
    }
    
    //MARK: - Открытие и закрытие представления для ввода информации
    
    // - открытие представления по добавлению категории расхода
    @IBAction func openViewForInput(_ sender: UIButton) {
        
        view.addSubview(backgroundView)
        view.addSubview(popUpView)

        //Добавляем цвет для представления
        backgroundView.frame.origin.y = 0
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let backgroundView = self?.backgroundView else { return }
            backgroundView.alpha = 0.5
        }

        popUpView.nameTextField.becomeFirstResponder()
        
        popUpView.delegate = self
        backgroundView.delegate = self
    }

    // - закрытие представления по добавлению категории расхода
    func closeViewForInput() {

        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let popUpView = self?.popUpView,
                  let backgroundView = self?.backgroundView,
                  let selfView = self?.view else { return }
            
            popUpView.frame.origin.y = selfView.bounds.height
            popUpView.nameTextField.resignFirstResponder()
            backgroundView.alpha = 0
            
        } completion: { [weak self] _ in
            guard let backgroundView = self?.backgroundView,
                  let selfView = self?.view else { return }

            backgroundView.frame.origin.y = selfView.bounds.height
        }
    }
    
    //MARK: - Переход на ExpenseCategoriesViewController и передача информации
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let expenses = self.expenses else { return }
        performSegue(withIdentifier: "expenseToExpenseCategories", sender: expenses.quantity![indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller =  segue.destination as? ExpenseCategoriesViewController, segue.identifier == "expenseToExpenseCategories"  {
            controller.expenseCategory = (sender as? ExpenseCategory)
        }
    }
}

//MARK: - реализация UITextFieldDelegate, методы по добавлению и удалению текста в TextField, а также изменению state кнопки
extension ExpensesViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if !string.isEmpty {
            enable(button: popUpView.viewButton, access: .available)
            expenseCategoryString.append(string)
        } else {
            var incomeChar:[Character] = Array(expenseCategoryString)
            incomeChar.removeLast()
            expenseCategoryString = String(incomeChar)
        }
        
        if !expenseCategoryString.isEmpty {
            popUpView.nameTextField.text = expenseCategoryString
        } else {
            enable(button: popUpView.viewButton, access: .notAvailable)
            popUpView.nameTextField.text = expenseCategoryString
        }
        
        return false
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        enable(button: popUpView.viewButton, access: .notAvailable)
        expenseCategoryString = ""
        return true
    }
}

//MARK: - UITableViewDataSource, UITextFieldDelegate
extension ExpensesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let expenses = self.expenses else { return 0 }
        return expenses.quantity!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCategories", for: indexPath)
        guard let expenses = self.expenses,
              let expenseCategory = expenses.quantity![indexPath.row] as? ExpenseCategory else { return cell }
        cell.textLabel?.text = expenseCategory.name
        return cell
    }
}
