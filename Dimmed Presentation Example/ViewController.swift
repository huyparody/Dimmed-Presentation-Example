//
//  ViewController.swift
//  Dimmed Presentation Example
//
//  Created by Huy Trinh Duc on 10/20/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onTapPresent(_ sender: UIButton) {
        let vc = DemoPopupViewController()
        presentDimmed(popupViewController: vc, height: UIScreen.main.bounds.height * 0.7)
    }
    
}

