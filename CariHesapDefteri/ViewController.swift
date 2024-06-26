//
//  ViewController.swift
//  CariHesapDefteri
//
//  
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var cariTableView: UITableView!
    let formatter: DateFormatter = DateFormatter()
    var cariKayitEntities: [CariKayitEntity] = []

    override func viewDidLoad() {
        /*let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: "CariKayit")
                let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
                do { try getCoreDataViewContext().execute(DelAllReqVar) }
                catch { print(error) }*/
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(kayitEklemeObserve(_:)), name: NSNotification.Name(rawValue: "kayitEkleme"), object: nil)
        navigationItem.title = "Kalamoza Defteri"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(kayitEkleme))
        formatter.dateFormat = "dd.MM.y"
        cariTableView.dataSource = self
        cariTableView.delegate = self
        cariTableView.separatorInset = UIEdgeInsets.zero
        cariTableView.separatorStyle = .singleLine
        readCariKayit()
    }
    
    @objc func kayitEkleme() {
        performSegue(withIdentifier: "toKayitEkle", sender: self)
    }
    
    @objc func kayitEklemeObserve(_ notification: NSNotification) {
        if let entity = notification.userInfo?["entity"] as? CariKayitEntity {
            cariKayitEntities.append(entity)
            cariTableView.reloadData()
        }
    }

}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cariKayitEntities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = cariKayitEntities[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cariKayitCell", for: indexPath) as! CariKayitTableViewCell
        cell.idLabel.text = String(entity.id)
        cell.dateLabel.text = formatter.string(from: entity.tarih)
        cell.cariHesapLabel.text = entity.cariHesap
        cell.aliciLabel.text = entity.alici
        cell.borcLabel.text = String(entity.borc)
        cell.aciklamaTextView.text = entity.aciklama!
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CariKayit")
            fetchRequest.predicate = NSPredicate(format: "id == %d", cariKayitEntities[indexPath.row].id)
            do {
                let results = try getCoreDataViewContext().fetch(fetchRequest)
                if let cariIsimObject = results.first as? NSManagedObject {
                    getCoreDataViewContext().delete(cariIsimObject)
                    let updateFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CariKayit")
                    updateFetchRequest.predicate = NSPredicate(format: "id > %d", cariKayitEntities[indexPath.row].id)
                    let cariToUpdate = try getCoreDataViewContext().fetch(updateFetchRequest)
                    for result in cariToUpdate as! [NSManagedObject] {
                        result.setValue(result.value(forKey: "id") as! Int - 1, forKey: "id")
                    }
                    try getCoreDataViewContext().save()
                    cariKayitEntities.remove(at: indexPath.row)
                    cariTableView.deleteRows(at: [indexPath], with: .automatic)
                    readCariKayit()
                } else {
                    print("BULAMADIM")
                }
            } catch let error as NSError {
                print("silme işleminde hata gerçekleşti. \(error), \(error.userInfo)")
            }
        }
    }
    
    func readCariKayit() {
        cariKayitEntities.removeAll()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CariKayit")
        request.returnsObjectsAsFaults = false
        do {
            let results = try getCoreDataViewContext().fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    let cariKayitEntity = CariKayitEntity()
                    cariKayitEntity.id = result.value(forKey: "id") as? Int
                    cariKayitEntity.tarih = result.value(forKey: "tarih") as? Date
                    cariKayitEntity.alici = result.value(forKey: "alici") as? String
                    cariKayitEntity.aciklama = result.value(forKey: "aciklama") as? String
                    cariKayitEntity.borc = result.value(forKey: "borc") as? Float
                    cariKayitEntity.cariHesap = result.value(forKey: "cari_hesap") as? String
                    cariKayitEntities.append(cariKayitEntity)
                }
                cariTableView.reloadData()
            }
        } catch {
            NSLog("coredatadan veriler getirilirken hata oluştu: \(error)")
        }
    }
}

extension UIViewController {
    func getCoreDataViewContext() -> NSManagedObjectContext {
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegete.persistentContainer.viewContext
        return context
    }
    func generateUniqueID(for entityName: String, in context: NSManagedObjectContext) -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1
        do {
            let results = try context.fetch(fetchRequest)
            if let lastObject = results.first as? NSManagedObject, let lastID = lastObject.value(forKey: "id") as? Int {
                return lastID + 1
            } else {
                return 1
            }
        } catch {
            fatalError("Failed to fetch data: \(error)")
        }
    }
}
