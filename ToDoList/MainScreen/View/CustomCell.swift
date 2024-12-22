//
//  CustomCellTableViewCell.swift
//  ToDoList
//
//  Created by Denis Borovoi on 11/8/24.
//

import UIKit

class CustomCell: UITableViewCell {
    
    //MARK: - Properties
    
    let noteName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        label.numberOfLines = 0
        return label
    }()
    
    let noteDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .lightGray
        label.sizeToFit()
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    static let identifier = "CustomCell"

    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Private methods
    
    private func setupCell() {
        [noteName, noteDescription].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            noteName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            noteName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            noteName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            noteDescription.topAnchor.constraint(equalTo: noteName.bottomAnchor, constant: 5),
            noteDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            noteDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            noteDescription.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }
    
    func configure(note: NoteViewModel) {
        noteName.text = note.noteName
        noteDescription.text = note.description
    }
}
