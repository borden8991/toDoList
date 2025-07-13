//
//  CustomEditAlertView.swift
//  ToDoList
//
//  Created by Denis Borovoi on 23.06.2025.
//


import UIKit

protocol CustomEditAlertDelegate: AnyObject {
    func didEditNote(newName: String, newDescription: String?, noteID: UUID?)
}

class CustomEditAlertView: UIView {
    weak var delegate: CustomEditAlertDelegate?
    private var noteID: UUID?

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor(hex: "FF8C00").cgColor
        textField.textColor = UIColor(hex: "000000")
        textField.placeholder = "Note title"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let descriptionTextView: GrowingTextView = {
        let textView = GrowingTextView()
        textView.layer.borderColor = UIColor(hex: "FF8C00").withAlphaComponent(0.6).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.textColor = UIColor(hex: "9B9B9B")
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.tintColor = UIColor(hex: "FF8C00")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.tintColor = UIColor(hex: "FF8C00").withAlphaComponent(0.6)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        addSubview(containerView)

        [nameTextField, descriptionTextView, saveButton, cancelButton].forEach {
            containerView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),

            nameTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            descriptionTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),

            saveButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 12),
            saveButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            saveButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor, constant: -20),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.topAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])

        backgroundView.alpha = 0
        containerView.alpha = 0

        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(nameTextChanged), for: .editingChanged)

    }

    func configure(with note: NoteViewModel?) {
        if let note = note {
            nameTextField.text = note.noteName
            descriptionTextView.text = note.description
            descriptionTextView.placeholderLabel.isHidden = !(note.description?.isEmpty ?? true)
            noteID = note.id
        } else {
            nameTextField.text = ""
            descriptionTextView.text = ""
            descriptionTextView.placeholderLabel.isHidden = false
            noteID = nil
        }
        nameTextChanged()
    }

    func show(in parentView: UIView) {
        parentView.addSubview(self)

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            topAnchor.constraint(equalTo: parentView.topAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])

        layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = 1
            self.containerView.alpha = 1
        }
    }

    @objc private func saveButtonTapped() {
        let trimmedTitle = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedDesc = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        delegate?.didEditNote(newName: trimmedTitle, newDescription: trimmedDesc, noteID: noteID)
        saveButton.isEnabled = !trimmedTitle.isEmpty
        
        self.removeFromSuperview()
    }
    
    @objc private func cancelTapped() {
        self.removeFromSuperview()
    }
    
    @objc private func nameTextChanged() {
        let trimmedTitle = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        saveButton.isEnabled = !trimmedTitle.isEmpty
    }
}

class GrowingTextView: UITextView, UITextViewDelegate {

    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .placeholderText
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Enter description..."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var maxHeight: CGFloat = 120

    override var text: String! {
        didSet {
            placeholderLabel.isHidden = !text.isEmpty
            invalidateIntrinsicContentSize()
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = .systemBackground
        font = .systemFont(ofSize: 16)
        layer.cornerRadius = 8
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1
        isScrollEnabled = false
        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
        ])

        delegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.isHidden = !text.isEmpty
    }

    override var intrinsicContentSize: CGSize {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)

        let height = min(size.height, maxHeight)
        isScrollEnabled = size.height > maxHeight
        return CGSize(width: bounds.width, height: height)
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !text.isEmpty
        invalidateIntrinsicContentSize()
    }
}

