//
//  CustomCellTableViewCell.swift
//  ToDoList
//
//  Created by Denis Borovoi on 11/8/24.
//

import UIKit

class CustomCell: UITableViewCell {
    
    //MARK: - Properties
    
    static let identifier = "CustomCell"
    
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "FFF1E1")
        view.layer.cornerRadius = 16
        return view
    }()
    
    let noteName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.sizeToFit()
        label.numberOfLines = 0
        label.textColor = UIColor(hex: "000000")
        return label
    }()
    
    let noteDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hex: "9B9B9B")
        label.sizeToFit()
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    var noteDoneImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "checkmarkImage")
        return imageView
    }()

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
        [cellView, noteName, noteDescription, noteDoneImage].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(cellView)
        cellView.addSubview(noteName)
        cellView.addSubview(noteDescription)
        cellView.addSubview(noteDoneImage)
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            
            noteName.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 14.5),
            noteName.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 16),
            noteName.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -16),

            noteDescription.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 16),
            noteDescription.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -16),
            noteDescription.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -14.5),
            noteDescription.topAnchor.constraint(equalTo: noteName.bottomAnchor, constant: 10),
            
            noteDoneImage.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
            noteDoneImage.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -17.87),
            noteDoneImage.widthAnchor.constraint(equalToConstant: 19.51),
            noteDoneImage.heightAnchor.constraint(equalToConstant: 14.25)
        ])
    }
    
    func configure(note: NoteViewModel) {
        noteName.text = note.noteName
        noteDescription.text = note.description
        noteDoneImage.isHidden = !note.completed
        
        self.cellView.backgroundColor = note.completed ? UIColor(hex: "FCE5CA") : UIColor(hex: "FFF1E1")
    }
}
