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
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
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
                        UserInfoCollector.shared.userID = user.uid
                        UserInfoCollector.shared.name = name
                        UserInfoCollector.shared.email = email
                        let InfoNameVC = InfoNameVC()
                        self.navigationController?.pushViewController(InfoNameVC, animated: true)
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple failed: \(error.localizedDescription)")
    }
}

extension SignInVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
