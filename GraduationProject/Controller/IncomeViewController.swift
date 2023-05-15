//
//  ViewController.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 03.04.2023.
//

import UIKit

final class IncomeViewController: UIViewController, UniversalProtocol, ClosingViewsProtocol {

    @IBOutlet weak var incomeTableView: UITableView!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var runningLineLabel: UILabel!
    
    private var incomeString:String = ""
    private var classInitialized:Bool = false
    
    private lazy var popUpView = {
        let view = PopUpView(windowScene: self.view.bounds, type: .income)
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
    
    private var incomes:Incomes?
    
    var currencyRuningLine:String = "" {
        didSet {
            runningLineLabel.text = currencyRuningLine
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // - взаимодействие с СoreDataManager, создание Incomes и/или получение из Core Data
        if let object = coreDataManager.getObjectFromData(object: .incomes) as? Incomes {
            self.incomes = object
        } else {
            let object = coreDataManager.create(object: .incomes) as? Incomes
            self.incomes = object
        }
        
        incomeLabel.text = String(incomes!.cashAccount) + " Р."
        
        popUpView.sumTextField.delegate = self
        popUpView.transmitInfoDelegate = self
        incomeTableView.dataSource = self

        // - взаимодействие с NetworkManager, создание и обновления бегущей строки курсов валют
        let netWorkManager = NetworkManager()
        let url = URL(string: "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/usd.json")
        guard let url = url else { return }
        
        netWorkManager.performData(url: url) { currences in
            DispatchQueue.main.async { [weak self] in
                self?.currencyRuningLine = getCurrencyRuningLine(currencies: currences)
            }
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] timer in
            currencyRuningLine = updateCurrencyRuning(line: currencyRuningLine)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        if classInitialized {
            popUpView.removeFromSuperview()
            backgroundView.removeFromSuperview()
        }
    }

    //MARK: - Реализация UniversalProtocol, взаимодействие с СoreDataManager, создание объектов и/или их изменение, сохранение в Core Data
    
    func transmit(info valueIncome: String?, and _ : String?) {
        
        let dateOperation = DateOperation.date
        
        guard let valueIncome = valueIncome else { return }
        let index = valueIncome.firstIndex(of: " ")
        guard let index = index else { return }
        let value = valueIncome.prefix(upTo: index)

        let income = coreDataManager.create(object: .income) as! Income
        income.date = dateOperation
        income.income = Int64(value)!
        
        guard let incomes = incomes else { return }
        incomes.addToQuantity(income)
        incomes.cashAccount += income.income

        coreDataManager.save()
        
        incomeString = ""
        incomeLabel.text = String(incomes.cashAccount) + " Р."
        incomeTableView.reloadData()
    }
    //MARK: - Открытие и закрытие представления для ввода информации
    
    // - открытие представления по добавлению дохода
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
    
    // - закрытие представления по добавлению дохода
    func closeViewForInput() {

        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let popUpView = self?.popUpView,
                  let backgroundView = self?.backgroundView,
                  let selfView = self?.view else { return }
            
            popUpView.frame.origin.y = selfView.bounds.height
            popUpView.sumTextField.resignFirstResponder()
            backgroundView.alpha = 0
            
        } completion: { [weak self] _ in
            guard let backgroundView = self?.backgroundView,
                  let selfView = self?.view else { return }

            backgroundView.frame.origin.y = selfView.bounds.height
        }
    }
}

//MARK: - метод по добавлению символа "Р." в строку при вводе значения в TextField, его очищения, а также изменении state кнопки
extension IncomeViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if !string.isEmpty {
            enable(button: popUpView.viewButton, access: .available)
            incomeString.append(string)
        } else {
            var incomeChar:[Character] = Array(incomeString)
            incomeChar.removeLast()
            incomeString = String(incomeChar)
        }
        
        if !incomeString.isEmpty {
            popUpView.sumTextField.text = incomeString + " Р."
        } else {
            enable(button: popUpView.viewButton, access: .notAvailable)
            popUpView.sumTextField.text = incomeString
        }
        
        return false
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        enable(button: popUpView.viewButton, access: .notAvailable)
        incomeString = ""
        return true
    }
}

//MARK: - UITableViewDataSource
extension IncomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let incomes = incomes else { return 0 }
        return incomes.quantity?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        guard let incomes = incomes else { return cell }
        let income = incomes.quantity![indexPath.row] as! Income
        
        cell.textLabel?.text = String(income.income) + " Р."
        cell.detailTextLabel?.text = DateOperation.dateToStringFormatOne(date: income.date)
        
        return cell
    }
}
