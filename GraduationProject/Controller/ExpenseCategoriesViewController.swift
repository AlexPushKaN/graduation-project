//
//  ExpenseCategoriesViewController.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 11.04.2023.
//

import UIKit

final class ExpenseCategoriesViewController: UIViewController, UniversalProtocol, ClosingViewsProtocol {

    @IBOutlet weak var expenseCategoryTableView: UITableView!
    @IBOutlet weak var graphExpenseButton: UIButton!
    
    private var valueExpense:String = ""
    private var nameExpense:String = ""
    private var classInitialized:Bool = false
    
    private lazy var popUpView = {
        let view = PopUpView(windowScene: self.view.bounds, type: .expenseCategory)
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
    
    var expenseCategory:ExpenseCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.sumTextField.delegate = self
        popUpView.nameTextField.delegate = self
        popUpView.transmitInfoDelegate = self
        expenseCategoryTableView.delegate = self
        expenseCategoryTableView.dataSource = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if classInitialized {
            popUpView.removeFromSuperview()
            backgroundView.removeFromSuperview()
        }
    }
    
    //MARK: - Реализация UniversalProtocol, взаимодействие с СoreDataManager, создание объектов и их изменение, сохранение в Core Data
    func transmit(info valueExpense: String?, and nameExpense: String?) {
        guard let valueExpense = valueExpense,
              let nameExpense = nameExpense else { return }
        let value = Int64((valueExpense.components(separatedBy: " "))[0]) ?? 0
        let expense = coreDataManager.create(object: .expense) as! Expense
        expense.name = nameExpense
        expense.expense = value
        expense.date = DateOperation.date
        
        guard let expenseCategory = self.expenseCategory else { return }
        expenseCategory.addToQuantity(expense)
        coreDataManager.save()
        
        self.nameExpense = ""
        self.valueExpense = ""
        
        expenseCategoryTableView.reloadData()
    }
    
    //MARK: - Открытие и закрытие представления для ввода информации
    
    // - открытие представления по добавлению расходов
    @IBAction func openViewForInput(_ sender: UIButton) {
        
        view.addSubview(backgroundView)
        view.addSubview(popUpView)

        //Добавляем цвет для представления
        backgroundView.frame.origin.y = 0
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let backgroundView = self?.backgroundView else { return }
            backgroundView.alpha = 0.5
        }

        popUpView.sumTextField.becomeFirstResponder()
        
        popUpView.delegate = self
        backgroundView.delegate = self
    }
    
    // - закрытие представления по добавлению расходов
    func closeViewForInput() {

        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let popUpView = self?.popUpView,
                  let backgroundView = self?.backgroundView,
                  let selfView = self?.view else { return }
            
            popUpView.frame.origin.y = selfView.bounds.height
            popUpView.sumTextField.resignFirstResponder()
            popUpView.nameTextField.resignFirstResponder()
            backgroundView.alpha = 0
            
        } completion: { [weak self] _ in
            guard let backgroundView = self?.backgroundView,
                  let selfView = self?.view else { return }

            backgroundView.frame.origin.y = selfView.bounds.height
        }
    }
    
    //MARK: - Реализация перехода на контроллер GraphExpenseViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? GraphExpenseViewController, segue.identifier == "expenseCategoriesToGraphExpense" {
            controller.expenseCategory = expenseCategory
        }
    }
}

//MARK: - метод по добавлению символа "Р." в строку при вводе значения в TextField, очищение TextField'ов, а также изменении state кнопки
extension ExpenseCategoriesViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if !string.isEmpty && popUpView.sumTextField.isFirstResponder {
            enable(button: popUpView.viewButton, access: .available)
            valueExpense.append(string)
        } else if popUpView.sumTextField.isFirstResponder {
            var сhars:[Character] = Array(valueExpense)
            сhars.removeLast()
            valueExpense = String(сhars)
        }
        
        if !string.isEmpty && popUpView.nameTextField.isFirstResponder {
            enable(button: popUpView.viewButton, access: .available)
            nameExpense.append(string)
        } else if popUpView.nameTextField.isFirstResponder {
            var сhars:[Character] = Array(nameExpense)
            сhars.removeLast()
            nameExpense = String(сhars)
        }
 
        if !valueExpense.isEmpty {
            popUpView.sumTextField.text = valueExpense + " Р."
        } else {
            enable(button: popUpView.viewButton, access: .notAvailable)
            popUpView.sumTextField.text = valueExpense
        }
        
        if !nameExpense.isEmpty {
            popUpView.nameTextField.text = nameExpense
        } else {
            enable(button: popUpView.viewButton, access: .notAvailable)
            popUpView.nameTextField.text = nameExpense
        }
        
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        enable(button: popUpView.viewButton, access: .notAvailable)
        valueExpense = ""
        nameExpense = ""
        return true
    }
}

//MARK: - UITextFieldDelegate, UITableViewDataSource
extension ExpenseCategoriesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "headerExpense") as! ExpenseTableViewCell
        header.nameExpense.text = "На что"
        header.dateExpense.text = "Когда"
        header.expense.text = "Сколько"
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let expenseCategory = self.expenseCategory else { return 0 }
        
        if expenseCategory.quantity!.count > 0 {
            enable(button: graphExpenseButton, access: .available)
        } else {
            enable(button: graphExpenseButton, access: .notAvailable)
        }
        
        return expenseCategory.quantity!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "expense", for: indexPath) as! ExpenseTableViewCell
        
        guard let expenseCategory = self.expenseCategory else { return cell }
        
        if let expense = expenseCategory.quantity![indexPath.row] as? Expense {
            cell.nameExpense.text = expense.name
            cell.dateExpense.text = DateOperation.dateToStringFormatTwo(date: (expense.date!))
            cell.expense.text = String(expense.expense) + " Р."
        }
        return cell
    }
}
