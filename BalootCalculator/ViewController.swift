//
//  ViewController.swift
//  BalootCalculator
//
//  Created by the Luckiest on 7/30/17.
//  Copyright © 2017 the Luckiest. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lanaTF: UITextField!
    @IBOutlet weak var lahmTF: UITextField!
    
    @IBOutlet weak var lanaLbl: UILabel!
    @IBOutlet weak var lahmLbl: UILabel!
    @IBOutlet weak var lanaCont: UIView!
    @IBOutlet weak var lahmCont: UIView!
    
    
    @IBOutlet weak var calcBtn: UIButton!
    @IBOutlet weak var undoBtn: UIButton!
    @IBOutlet weak var newSakaBtn: UIButton!
    @IBOutlet weak var undoWidthConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var redoBtn: UIButton!
    var redoMode = false
    
    
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var lanaTopLbl: UILabel!
    @IBOutlet weak var lahmTopLbl: UILabel!
    @IBOutlet weak var lanaTVLbl: UILabel!
    @IBOutlet weak var lahmTVLbl: UILabel!
    @IBOutlet weak var btnsBackgroundView: UIView!
    @IBOutlet weak var lanaResultLbl: UILabel!
    @IBOutlet weak var lanaResultBG: UIView!
    @IBOutlet weak var lahmResultLbl: UILabel!
    @IBOutlet weak var lahmResultBG: UIView!
    var darkMode : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "darkMode") ? true : false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "darkMode")
            UserDefaults.standard.synchronize()

        }
    }
    
    
    @IBOutlet weak var distributerBtn: UIButton!
    
    
    let calculator = BalootCalculator.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView.delegate = self
        tableView.dataSource = self
        
        // register custome cells
        tableView.register(UINib.init(nibName: "ScoreCell", bundle: nil), forCellReuseIdentifier: "ScoreCell")
        tableView.register(UINib.init(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        if(self.darkMode){
            self.applyDarkMode()
        }
        updateUI()
        
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculator.result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let score = calculator.result[indexPath.row]
        
        if(score.type == .score) {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
            cell.configure(score: score)
            return cell
        } else if(score.type == .result) {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
            cell.configure(score: score)
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    

    @IBAction func calculate(_ sender: Any) {
        if((lanaTF.text == nil || lanaTF.text == "") && (lahmTF.text == nil || lahmTF.text == "")) {
            view.endEditing(true)
            return;
        }
        let lahmScore = lahmTF.text == nil || lahmTF.text == "" ? 0 : Int((lahmTF.text! as NSString).intValue)
        let lanaScore = lanaTF.text == nil || lanaTF.text == "" ? 0 : Int((lanaTF.text! as NSString).intValue)
        
        
        calculator.add(lana:lanaScore, lahm:lahmScore)
        lahmTF.text = ""
        lanaTF.text = ""
        self.updateUI()
        self.checkWinner()
    }

    @IBAction func newSaka(_ sender: Any) {
        let alert = UIAlertController(title: "هل أنت متأكد من بداية صكة جديدة؟", message: nil, preferredStyle: .alert);
        let yesAction = UIAlertAction(title: "نعم", style: .cancel) { (action) in
            self.calculator.newSaka()
            self.updateUI()
        }
        let cancelAction = UIAlertAction(title: "إلغاء", style: .default, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil);
    }
    
    @IBAction func undo(_ sender: Any) {
        calculator.undo()
        self.updateUI()
        
    }
    
    @IBAction func redo(_ sender: Any) {
        calculator.redo()
        self.updateUI()
    }
    
    
    
    func updateUI() {
        if (calculator.currentScore.lahm == 0){
            lahmLbl.text = "صفر"
        } else {
            lahmLbl.text = "\(calculator.currentScore.lahm)"
        }
        
        if (calculator.currentScore.lana == 0){
            lanaLbl.text = "صفر"
        } else {
            lanaLbl.text = "\(calculator.currentScore.lana)"
        }
        
        tableView.reloadData()
        if(calculator.result.count > 0){
           let indexPath = IndexPath(row: self.calculator.result.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        if(calculator.hasRedo && !self.redoMode) {
            // go redo mode
            undoWidthConstrain.constant = 100
            undoBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
            redoBtn.isHidden = false
            redoMode = true
        } else if(!calculator.hasRedo && self.redoMode) {
            // back to regular mode
            undoWidthConstrain.constant = 80
            undoBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            redoBtn.isHidden = true
            redoMode = false
        }
        switch calculator.distributer {
        case .me:
            distributerBtn.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        case .right:
            distributerBtn.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        case .front:
            distributerBtn.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 3/2))
        default:
            distributerBtn.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }
        
        view.endEditing(true)
        
    }
    
    func checkWinner() {
        let lanaScore = calculator.currentScore.lana
        let lahmScore = calculator.currentScore.lahm
        
        if(lanaScore < 152 && lahmScore < 152) || (lanaScore == 152 && lahmScore == 152) {
            return
        }
        
        if(lanaScore >= 152 && lanaScore > lahmScore){
            let alert = UIAlertController(title: "مبروك الفوز", message: "قامت لكم.. هل تريد بدء صكة جديدة؟", preferredStyle: .alert)
            let newSakaAction = UIAlertAction(title: "نعم", style: .cancel, handler: { (action) in
                self.calculator.newSaka()
                self.updateUI()
            })
            let noAction = UIAlertAction(title: "لا", style: .default, handler: nil)
            
            alert.addAction(newSakaAction)
            alert.addAction(noAction)
            
            present(alert, animated: true, completion: nil)
        }
        
        if(lahmScore >= 152 && lahmScore > lanaScore) {
            let alert = UIAlertController(title: "خيرها في غيرها", message: "قامت لهم.. هل تريد بدء صكة جديدة؟", preferredStyle: .alert)
            let newSakaAction = UIAlertAction(title: "نعم", style: .cancel, handler: { (action) in
                self.calculator.newSaka()
                self.updateUI()
            })
            let noAction = UIAlertAction(title: "لا", style: .default, handler: nil)
            
            alert.addAction(newSakaAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundView?.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(calculator.result[indexPath.row].type == .score) {
            return 25
        } else if (calculator.result[indexPath.row].type == .result && calculator.result.count - 1 == indexPath.row) {
            return 50
        } else {
            return 30
        }
        
    }
    
    func applyDarkMode(){
        backgroundImg.image = #imageLiteral(resourceName: "Dark Background")
        calcBtn.backgroundColor = UIColor(white: 255.0/255.0, alpha: 1.0)
        calcBtn.setTitleColor(UIColor(white: 0.0, alpha: 1.0), for: .normal)
        lanaTopLbl.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        lahmTopLbl.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        lanaTVLbl.textColor = UIColor(white: 166.0/255.0, alpha: 1.0)
        lahmTVLbl.textColor = UIColor(white: 166.0/255.0, alpha: 1.0)
        btnsBackgroundView.backgroundColor = UIColor(white: 0.0/255.0, alpha: 0.4)
        lanaResultLbl.textColor = UIColor(white: 255.0/255.0, alpha: 0.44)
        lanaResultBG.borderColor = UIColor(white: 255.0/255.0, alpha: 0.44)
        lahmResultLbl.textColor = UIColor(red: 251.0/255.0, green: 104.0/255.0, blue: 104.0/255.0, alpha: 0.7)
        lahmResultBG.borderColor = UIColor(red: 251.0/255.0, green: 104.0/255.0, blue: 104.0/255.0, alpha: 0.6)
        lanaLbl.textColor = UIColor(red: 226.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0)
        lahmLbl.textColor = UIColor(red: 226.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0)
    }
    func applyRegularMode(){
        backgroundImg.image = #imageLiteral(resourceName: "Background")
        calcBtn.backgroundColor = UIColor(white: 53.0/255.0, alpha: 1.0)
        calcBtn.setTitleColor(UIColor(white: 255.0/255.0, alpha: 1.0), for: .normal)
        lanaTopLbl.textColor = UIColor(white: 74.0/255.0, alpha: 1.0)
        lahmTopLbl.textColor = UIColor(white: 74.0/255.0, alpha: 1.0)
        lanaTVLbl.textColor = UIColor(white: 74.0/255.0, alpha: 1.0)
        lahmTVLbl.textColor = UIColor(white: 74.0/255.0, alpha: 1.0)
        btnsBackgroundView.backgroundColor = UIColor(white: 203.0/255.0, alpha: 0.7)
        lanaResultLbl.textColor = UIColor(white: 69.0/255.0, alpha: 0.6)
        lanaResultBG.borderColor = UIColor(white: 69.0/255.0, alpha: 0.44)
        lahmResultLbl.textColor = UIColor(red: 248.0/255.0, green: 89.0/255.0, blue: 89.0/255.0, alpha: 0.6)
        lahmResultBG.borderColor = UIColor(red: 248.0/255.0, green: 89.0/255.0, blue: 89.0/255.0, alpha: 0.44)
        lanaLbl.textColor = UIColor(white: 0.0/255.0, alpha: 0.6)
        lahmLbl.textColor = UIColor(white: 0.0/255.0, alpha: 0.6)
    }
    @IBAction func darkModeToggle(_ sender: Any) {
        if(!self.darkMode) {
            // to dark mode
            applyDarkMode()
            darkMode = true
        } else {
            // to regular mode
            applyRegularMode()
            darkMode = false
        }
    }
    
    
    @IBAction func changeDistributer(_ sender: Any) {
        calculator.moveDistributer()
        updateUI()
    }
    
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

