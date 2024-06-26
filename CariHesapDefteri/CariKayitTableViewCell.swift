//
//  CariKayitTableViewCell.swift
//  CariHesapDefteri
//
//  
//

import UIKit

class CariKayitTableViewCell: UITableViewCell {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cariHesapLabel: UILabel!
    @IBOutlet weak var aliciLabel: UILabel!
    @IBOutlet weak var borcLabel: UILabel!
    @IBOutlet weak var aciklamaTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
