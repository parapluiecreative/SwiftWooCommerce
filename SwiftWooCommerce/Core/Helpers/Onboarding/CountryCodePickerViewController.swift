//
//  CountryCodePickerViewController.swift
//  ChatApp
//
//  Created by Mac  on 14/02/20.
//  Copyright © 2020 Instamobile. All rights reserved.
//

import UIKit

final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

public struct Country: Equatable {
    public let name: String
    public let code: String
    public let phoneCode: String
    public func localizedName(_ locale: Locale = Locale.current) -> String? {
        return locale.localizedString(forRegionCode: code)
    }
    public var flag: UIImage {
        return UIImage(named: "\(code.uppercased())")!
    }
}

protocol CountryCodePickerProtocol {
    func didSelectCountryCode(country: Country)
}

class CountryCodePickerViewController: UIViewController {

    @IBOutlet weak var countryCodePickerTableView: UITableView!
    @IBOutlet weak var countryCodePickerTableHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    let uiConfig: ATCOnboardingConfigurationProtocol

    var delegate: CountryCodePickerProtocol?
    
    public let countries: [Country] = {
        var countries = [Country]()
        guard let jsonPath = Bundle.main.path(forResource: "CountryCodes", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
                return countries
        }
        
        if let jsonObjects = (try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization
            .ReadingOptions.allowFragments)) as? Array<Any> {
            
            for jsonObject in jsonObjects {
                
                guard let countryObj = jsonObject as? Dictionary<String, Any> else {
                    continue
                }
                
                guard let name = countryObj["name"] as? String,
                    let code = countryObj["code"] as? String,
                    let phoneCode = countryObj["dial_code"] as? String else {
                        continue
                }
                
                let country = Country(name: name, code: code, phoneCode: phoneCode)
                countries.append(country)
            }
        }
        return countries
    }()

    init(uiConfig: ATCOnboardingConfigurationProtocol) {
        self.uiConfig = uiConfig
        super.init(nibName: "CountryCodePickerViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        countryCodePickerTableHeightCons.isActive = false
        
        let nib = UINib(nibName: "CountryCodePickerTableViewCell", bundle: nil)
        countryCodePickerTableView.register(nib, forCellReuseIdentifier: "CountryCodePickerTableViewCell")

    }

    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension CountryCodePickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCodePickerTableViewCell", for: indexPath) as! CountryCodePickerTableViewCell
        cell.countryName.text = countries[indexPath.row].name
        cell.countryCode.text = countries[indexPath.row].phoneCode
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCountryCode(country: countries[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
}

