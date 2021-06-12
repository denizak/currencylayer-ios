//
//  ViewController.swift
//  exchange
//
//  Created by Deni Zakya on 11/06/21.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet weak var value: UITextField!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var currencyList: UITableView!
    @IBOutlet weak var currencyPickerContainer: UIView!
    
    let viewModel = createExchangeRateViewModel()
    var convertedCurrencies: [CurrencyValue] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.onValueLoaded = { [weak self] results in
            self?.convertedCurrencies = results
            DispatchQueue.main.async {
                self?.currencyList.reloadData()
            }
        }
        
        viewModel.viewLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        load(value: value.text ?? "")
    }

    @IBAction func changeCurrency(_ sender: Any) {
        currencyPickerContainer.isHidden = false
        currencyPicker.reloadAllComponents()
        value.resignFirstResponder()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        if value.isFirstResponder {
            value.resignFirstResponder()
        } else if !currencyPicker.isHidden {
            currencyPickerContainer.isHidden = true
        }
    }
    
    private func load(value: String) {
        viewModel.load(value: value)
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.availableCurrencies[row].code
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.availableCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let currency = viewModel.select(at: row) else { return }
        
        currencyButton.setTitle(currency.code, for: .normal)
        load(value: value.text ?? "")
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        load(value: updatedText)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currencyPickerContainer.isHidden = true
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convertedCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        }
        
        let convertedCurrencyValue = convertedCurrencies[indexPath.row]
        cell!.textLabel?.text = convertedCurrencyValue.currency.code
        cell!.detailTextLabel?.text = String(format: "%.4f",
                                             (convertedCurrencyValue.value as NSDecimalNumber).doubleValue)
        
        return cell!
    }
    
    
}

