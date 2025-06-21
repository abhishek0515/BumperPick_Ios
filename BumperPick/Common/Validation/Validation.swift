//
//  Untitled.swift
//  BumperPick
//
//  Created by tauseef hussain on 20/05/25.
//
import Foundation


func isNumberValid(_ number: String) -> Bool {
    // 10-digit Indian mobile number format (example)
    let phoneRegex = "^[6-9]\\d{9}$"
    let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
    return predicate.evaluate(with: number)
}

 func isValidEmail(_ email: String) -> Bool {
      let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
      let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
      return emailPredicate.evaluate(with: email)
}
