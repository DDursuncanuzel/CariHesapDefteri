//
//  KayitEkleViewController.swift
//  CariHesapDefteri
//
//
//

import UIKit
import CoreData

class KayitEkleViewController: UIViewController {
    var dateFormatter: DateFormatter = DateFormatter()
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var debtTextField: UITextField!
    @IBOutlet weak var receiverTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var cariHesapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "dd/MM/y"
        descriptionTextView.clipsToBounds = true
        descriptionTextView.layer.cornerRadius = 5.0
        cariHesapButton.clipsToBounds = true
        cariHesapButton.layer.cornerRadius = 5.0
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        if receiverTextField.text!.isEmpty || cariHesapButton.currentTitle == "İsim Seç" || debtTextField.text!.isEmpty {
            let alertVC = UIAlertController(title: "Hata", message: "Bilgileri Kontrol Ediniz", preferredStyle: .alert)
            let action = UIAlertAction(title: "Tamam", style: .default)
            alertVC.addAction(action)
            present(alertVC, animated: true)
            return
        }
        
        
        let cariKayitEntity = CariKayitEntity()
        let cariKayit = NSEntityDescription.insertNewObject(forEntityName: "CariKayit", into: self.getCoreDataViewContext())
        cariKayitEntity.id = generateUniqueID(for: "CariKayit", in: self.getCoreDataViewContext())
        cariKayitEntity.tarih = self.datePicker.date
        cariKayitEntity.alici = receiverTextField.text
        cariKayitEntity.cariHesap = cariHesapButton.currentTitle
        cariKayitEntity.borc = Float(self.debtTextField.text ?? "0")
        cariKayitEntity.aciklama = descriptionTextView.text
        cariKayit.setValue(cariKayitEntity.id, forKey: "id")
        cariKayit.setValue(cariKayitEntity.tarih, forKey: "tarih")
        cariKayit.setValue(cariKayitEntity.borc, forKey: "borc")
        cariKayit.setValue(cariKayitEntity.alici, forKey: "alici")
        cariKayit.setValue(cariKayitEntity.aciklama, forKey: "aciklama")
        cariKayit.setValue(cariKayitEntity.cariHesap, forKey: "cari_hesap")
        do{
            try self.getCoreDataViewContext().save()
        } catch {
            NSLog("fotoğraf uygulama veritabanına kaydedilirken hata alındı: \(error)")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kayitEkleme"), object: nil, userInfo: ["entity": cariKayitEntity])
        navigationController?.popToRootViewController(animated: true)
    }
    
}
