//
//  UIHelper.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//


import UIKit


enum UIHelper {
    
    enum Attributed {
        //Both
        static let none: [NSAttributedString.Key: Any] = [.font: Font.none, .foregroundColor: UIColor.clear]
        
        static let systemBlueInterBold18: [NSAttributedString.Key: Any] = [.font: Font.InterBold18, .foregroundColor: UIColor.systemBlue]

        static let grayInterMedium16: [NSAttributedString.Key: Any] = [.font: Font.InterMedium16, .foregroundColor: Color.graySubtitleAndFilterButtons]

        static let blackInterBold22: [NSAttributedString.Key: Any] = [.font: Font.InterBold22, .foregroundColor: UIColor.black]
    }
    
    enum Font {
        static let none = UIFont.systemFont(ofSize: 1, weight: .ultraLight)
        
        static let InterBold14 = UIFont(name: "Inter-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .bold)
        static let InterMedium16 = UIFont(name: "Inter-Medium", size: 16) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        static let InterBold18 = UIFont(name: "Inter-Bold", size: 18) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        static let InterBold22 = UIFont(name: "Inter-Bold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .bold)
    }
    
    enum Color {
        static let grayBack = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.00)
        static let graySubtitleAndFilterButtons = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.00)
        static let blueBackNewTask = UIColor(red: 0.89, green: 0.92, blue: 0.98, alpha: 1.00)
        
        static let lightGrayTimeAndSeparator = UIColor(red: 0.84, green: 0.84, blue: 0.84, alpha: 1.00)
    }
    
    enum Margins {
        static let small1px: CGFloat = 1
        static let small2px: CGFloat = 2
        static let small4px: CGFloat = 4
        static let small6px: CGFloat = 6
        
        static let medium8px: CGFloat = 8
        static let medium10px: CGFloat = 10
        static let medium12px: CGFloat = 12
        static let medium14px: CGFloat = 14
        static let medium16px: CGFloat = 16
        static let medium18px: CGFloat = 18
        
        static let large20px: CGFloat = 20
        static let large22px: CGFloat = 22
        static let large23px: CGFloat = 23
        static let large24px: CGFloat = 24
        static let large26px: CGFloat = 26
        static let large30px: CGFloat = 30
        static let large32px: CGFloat = 32
        
        static let huge36px: CGFloat = 36
        static let huge40px: CGFloat = 40
        static let huge42px: CGFloat = 42
        static let huge48px: CGFloat = 48
        static let huge56px: CGFloat = 56
    }
}



