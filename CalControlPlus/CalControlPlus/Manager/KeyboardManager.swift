//
//  KeyboardManager.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/8.
//

import UIKit

class KeyboardManager: NSObject, UITextFieldDelegate {
    static let shared = KeyboardManager()
    
    private var activeTextField: UITextField?
    private var viewOriginalY: CGFloat = 0
    private var originalContentOffset: CGPoint = .zero
    
    weak var viewControllerDelegate: UITextFieldDelegate?
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyboardManager(for viewController: UIViewController, textFields: [UITextField], doneTitle: String = "Done") {
        setupKeyboardDismissGesture(for: viewController)
        addToolbar(to: textFields, doneTitle: doneTitle, for: viewController)
        viewControllerDelegate = viewController as? UITextFieldDelegate
        for textField in textFields {
            textField.delegate = self
        }
    }
    
    private func setupKeyboardDismissGesture(for viewController: UIViewController) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        viewController.view.addGestureRecognizer(tapGesture)
    }
    
    private func addToolbar(
        to textFields: [UITextField],
        doneTitle: String,
        for viewController: UIViewController
    ) {
        for textField in textFields {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: doneTitle, style: .done, target: KeyboardManager.shared, action: #selector(dismissKeyboard))
            
            var items: [UIBarButtonItem] = []
            
            if let placeholder = textField.placeholder {
                let placeholderLabel = UILabel()
                placeholderLabel.text = placeholder
                placeholderLabel.textColor = .gray
                placeholderLabel.font = UIFont.systemFont(ofSize: 16)
                
                let placeholderItem = UIBarButtonItem(customView: placeholderLabel)
                
                items.append(flexSpace)
                items.append(placeholderItem)
            }
            
            items.append(flexSpace)
            items.append(doneButton)
            
            toolbar.setItems(items, animated: false)
            toolbar.isUserInteractionEnabled = true
            
            textField.inputAccessoryView = toolbar
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return viewControllerDelegate?.textFieldShouldReturn?(textField) ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        viewControllerDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
        viewControllerDelegate?.textFieldDidEndEditing?(textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return viewControllerDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    @objc private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Keyboard Notification Handlers
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let activeTextField = activeTextField,
              let window = activeTextField.window else {
            return
        }
        
        let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: window)
        let keyboardHeight = keyboardFrame.height
        let textFieldBottomY = textFieldFrame.origin.y + textFieldFrame.size.height
        
        if textFieldBottomY > (window.frame.height - keyboardHeight) {
            let offset = textFieldBottomY - (window.frame.height - keyboardHeight) + 20
            
            if let scrollView = findVerticalScrollView(in: activeTextField) {
                originalContentOffset = scrollView.contentOffset
                
                UIView.animate(withDuration: 0.3) {
                    scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y + offset), animated: false)
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    if let viewController = window.rootViewController {
                        self.viewOriginalY = viewController.view.frame.origin.y
                        viewController.view.frame.origin.y = self.viewOriginalY - offset
                    }
                }
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            if let scrollView = self.findVerticalScrollView(in: self.activeTextField ?? UIView()) {
                scrollView.setContentOffset(self.originalContentOffset, animated: true)
            } else {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController?.view.frame.origin.y = self.viewOriginalY
                }
            }
        }
    }
    
    // MARK: - Private Helper Methods
    private func findVerticalScrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view.superview as? UIScrollView {
            if scrollView.contentSize.height > scrollView.frame.size.height && scrollView.contentSize.width <= scrollView.frame.size.width {
                return scrollView
            }
        } else if let superview = view.superview {
            return findVerticalScrollView(in: superview)
        }
        return nil
    }
    
    private func adjustScrollView(_ scrollView: UIScrollView, for keyboardFrame: CGRect) {
        guard let activeTextField = activeTextField else { return }
        
        let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: scrollView)
        let keyboardHeight = keyboardFrame.height
        let textFieldBottomY = textFieldFrame.origin.y + textFieldFrame.size.height
        
        if textFieldBottomY > (scrollView.frame.height - keyboardHeight) {
            let offset = textFieldBottomY - (scrollView.frame.height - keyboardHeight) + 20
            scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        }
    }
    
    private func adjustViewForKeyboard(in window: UIWindow, keyboardFrame: CGRect) {
        let keyboardHeight = keyboardFrame.height
        let textFieldFrame = activeTextField?.convert(activeTextField!.bounds, to: window)
        let textFieldBottomY = textFieldFrame?.origin.y ?? 0 + (textFieldFrame?.size.height ?? 0)
        
        if textFieldBottomY > (window.frame.height - keyboardHeight) {
            let offset = textFieldBottomY - (window.frame.height - keyboardHeight) + 20
            UIView.animate(withDuration: 0.3) {
                if let viewController = window.rootViewController {
                    self.viewOriginalY = viewController.view.frame.origin.y
                    viewController.view.frame.origin.y = self.viewOriginalY - offset
                }
            }
        }
    }
}
