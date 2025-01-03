//
//  CustomCellTableViewCell.swift
//  ToDoList
//
//  Created by user270963 on 11/8/24.
//

import UIKit

// по крайсоте расписать
class CustomCell: UITableViewCell {
    
    let itemName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        label.numberOfLines = 0
        return label
    }()
    
    let itemDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .lightGray
        label.sizeToFit()
        label.numberOfLines = 0
        return label
    }()
    
    static let identifier = "CustomCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // что он делает?
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    private func setupCell() {
        [itemName, itemDescription].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            itemName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            itemName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            itemName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            itemDescription.topAnchor.constraint(equalTo: itemName.bottomAnchor, constant: 5),
            itemDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            itemDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            itemDescription.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }
    
    func configure(task: Item) {
        itemName.text = task.string
        itemDescription.text = task.description
    }
}
