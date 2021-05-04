
//
//  ATCClassicResetPasswordViewController.swift
//  ATCClassicResetPasswordViewController
//
        
import UIKit

class ATCClassicResetPasswordViewController: UIViewController, ATCResetPasswordScreenProtocol {

    @IBOutlet var backButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var emailTextField: ATCTextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    weak var delegate: ATCResetPasswordScreenDelegate?
    let uiConfig: ATCOnboardingConfigurationProtocol

    init(uiConfig: ATCOnboardingConfigurationProtocol) {
        self.uiConfig = uiConfig
        super.init(nibName: "ATCClassicResetPasswordViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.resetPasswordScreenDidLoadView(self)
        backButton.tintColor = uiConfig.subtitleColor
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = uiConfig.backgroundColor
    }

    func display(alertController: UIAlertController) {
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}
