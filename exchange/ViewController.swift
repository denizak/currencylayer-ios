//
//  ViewController.swift
//  exchange
//
//  Created by Deni Zakya on 11/06/21.
//

import UIKit
import RxSwift
import RxCocoa

final class ViewController: UIViewController {

    @IBOutlet weak var value: UITextField!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var currencyList: UITableView!
    @IBOutlet weak var currencyPickerContainer: UIView!
    @IBOutlet weak var lastFetchTime: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private let viewModel = createExchangeRateViewModel()
    private let disposeBag = DisposeBag()
    private let numberFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.values
            .drive(
                currencyList.rx
                    .items(cellIdentifier: "Cell",
                           cellType: UITableViewCell.self)) { [unowned self] (row, item, cell) in
                cell.textLabel?.text = item.currency.code
                cell.detailTextLabel?.text = item.getFormattedValue(self.numberFormatter)
            }.disposed(by: disposeBag)
        
        viewModel.lastFetchTimeDisplay
            .drive(lastFetchTime.rx.text)
            .disposed(by: disposeBag)
            
        
        viewModel.loadingVisible
            .map { !$0 }
            .drive(loadingIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.showAlert.drive(onNext: { [unowned self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(.init(title: "close", style: .default, handler: { _ in
                alert.dismiss(animated: true)
            }))
            self.present(alert, animated: true)
        }).disposed(by: disposeBag)

        
        value.rx
            .controlEvent(.editingDidEnd)
            .compactMap { [unowned self] in value.text }
            .subscribe(onNext: { [weak self] value in
                self?.viewModel.numberValue.accept(value)
            })
            .disposed(by: disposeBag)
    
        viewModel.viewLoad()
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
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currencyPickerContainer.isHidden = true
    }
}

