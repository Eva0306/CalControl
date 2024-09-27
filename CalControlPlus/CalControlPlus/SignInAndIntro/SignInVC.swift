//
//  SignInVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/27.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices

class SignInVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupSignInWithAppleButton()
    }
    
    private func setupSignInWithAppleButton() {
        let appleSignInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        appleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(appleSignInButton)
        
        NSLayoutConstraint.activate([
            appleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleSignInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            appleSignInButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        appleSignInButton.addTarget(self, action: #selector(handleAppleSignInButtonTapped), for: .touchUpInside)
    }
    
    @objc private func handleAppleSignInButtonTapped() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
}

extension SignInVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // 獲取使用者資訊
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // 打印使用者資訊
            print("User Identifier: \(userIdentifier)")
            if let fullName = fullName {
                print("User Full Name: \(fullName)")
            }
            if let email = email {
                print("User Email: \(email)")
            }
            
            // 獲取 Apple 登入的 ID Token
            guard let identityTokenData = appleIDCredential.identityToken,
                  let identityTokenString = String(data: identityTokenData, encoding: .utf8) else {
                print("Unable to fetch identity token")
                return
            }
            
            let credential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: identityTokenString
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Auth Sign in failed: \(error.localizedDescription)")
                    return
                }
                
                guard let user = authResult?.user else { return }
                let name = "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")"
                
                FirebaseManager.shared.getDocument(from: .users, documentID: user.uid) { (customUser: User?) in
                    if let customUser = customUser {
                        UserProfileViewModel.shared = UserProfileViewModel(user: customUser)
                        
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                           let window = sceneDelegate.window {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            // swiftlint:disable force_cast line_length
                            let tabBarController = storyboard.instantiateInitialViewController() as! MainTabBarController
                            // swiftlint:enable force_cast line_length
                            window.rootViewController = tabBarController
                            window.makeKeyAndVisible()
                        }
                    } else {
                        
                        let informationVC = InformationVC()
                        informationVC.userID = user.uid
                        informationVC.defaultName = name
                        informationVC.email = email
                        self.navigationController?.pushViewController(informationVC, animated: true)
                    }
                }
            }



//            // 使用 Firebase Auth 登入
//            Auth.auth().signIn(with: credential) { authResult, error in
//                if let error = error {
//                    print("Firebase Auth Sign in failed: \(error.localizedDescription)")
//                    return
//                }
//                // 登入成功
//                guard let user = authResult?.user else { return }
//                let name = "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")"
//                
//                // Firebase Firestore 資料庫
//                let db = Firestore.firestore()
//                
//                // 構建使用者資料
//                let userData: [String: Any] = [
//                    "id": user.uid,
//                    "email": email ?? "", // 來自 Apple ID 資訊
//                    "name": name, // 來自 Apple ID 資訊
//                    "createdTime": Timestamp(date: Date())
//                ]
//                // 將資料寫入到 Firestore 中 "users" 集合中，並使用 uid 作為文件 ID
//                db.collection("users").document(user.uid).setData(userData) { error in
//                    if let error = error {
//                        print("Error writing user to Firestore: \(error)")
//                    } else {
//                        print("User successfully written to Firestore")
//                        let informationVC = InformationVC()
//                        informationVC.userID = user.uid
//                        informationVC.defaultName = name
//                        self.navigationController?.pushViewController(informationVC, animated: true)
//                    }
//                }
//            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 處理錯誤
        print("Sign in with Apple failed: \(error.localizedDescription)")
    }
}

extension SignInVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
