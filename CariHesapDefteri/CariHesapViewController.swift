//
//  CariHesapViewController.swift
//  CariHesapDefteri
//
//  
//

import UIKit
import CoreData

class CariHesapViewController: UIViewController {
    var cariIsimEntities: [CariIsimEntity] = []
    var controllerIndex: Int!
    var kayitEkleViewController: KayitEkleViewController!
    @IBOutlet weak var cariTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(cariEkleme))
        controllerIndex = navigationController!.viewControllers.firstIndex(of: self)!
        kayitEkleViewController = navigationController!.viewControllers[controllerIndex - 1] as? KayitEkleViewController
        cariTableView.dataSource = self
        cariTableView.delegate = self
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CariIsim")
        request.returnsObjectsAsFaults = false
        do {
            let results = try getCoreDataViewContext().fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    let entity = CariIsimEntity()
                    entity.id = result.value(forKey: "id") as? UUID
                    entity.name = result.value(forKey: "name") as? String
                    cariIsimEntities.append(entity)
                }
                cariTableView.reloadData()
            }
        } catch {
            NSLog("coredatadan veriler getirilirken hata oluştu: \(error)")
        }
    }
    
    @objc func cariEkleme() {
        let alertController = UIAlertController(title: "İsim Giriniz", message: "", preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "İsim Giriniz"
        }
        let cancel = UIAlertAction(title: "Iptal", style: .cancel)
        let saveAction = UIAlertAction(title: "Kaydet", style: .default, handler: { [self] alert -> Void in
            let cariTextField = alertController.textFields![0] as UITextField
            let cariEntity = CariIsimEntity()
            let cariIsim = NSEntityDescription.insertNewObject(forEntityName: "CariIsim", into: self.getCoreDataViewContext())
            cariEntity.id = UUID()
            cariEntity.name = cariTextField.text
            cariIsim.setValue(cariEntity.id, forKey: "id")
            cariIsim.setValue(cariEntity.name, forKey: "name")
            do{
                try self.getCoreDataViewContext().save()
            } catch {
                NSLog("cari isim veritabanına kaydedilirken hata alındı: \(error)")
            }
            cariIsimEntities.append(cariEntity)
            cariTableView.reloadData()
        })
        alertController.addAction(saveAction)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }

}

extension CariHesapViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cariIsimEntities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        var content = cell.defaultContentConfiguration()
        content.text = cariIsimEntities[indexPath.row].name
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        kayitEkleViewController.cariHesapButton.setTitle(cariIsimEntities[indexPath.row].name, for: .normal)
        navigationController?.popToViewController(kayitEkleViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CariIsim")
            fetchRequest.predicate = NSPredicate(format: "id == %@", cariIsimEntities[indexPath.row].id.uuidString)
            do {
                let results = try getCoreDataViewContext().fetch(fetchRequest)
                if let cariIsimObject = results.first as? NSManagedObject {
                    getCoreDataViewContext().delete(cariIsimObject)
                    try getCoreDataViewContext().save()
                    let removed = cariIsimEntities.remove(at: indexPath.row)
                    cariTableView.deleteRows(at: [indexPath], with: .automatic)
                    if kayitEkleViewController.cariHesapButton.currentTitle == removed.name {
                        kayitEkleViewController.cariHesapButton.setTitle("İsim Seç", for: .normal)
                    }
                } else {
                    print("BULAMADIM")
                }
            } catch let error as NSError {
                print("silme işleminde hata gerçekleşti. \(error), \(error.userInfo)")
            }
        }
    }
    
}
