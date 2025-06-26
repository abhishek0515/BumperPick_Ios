//
//  Constant.swift
//  BumperPick
//
//  Created by tauseef hussain on 19/05/25.
//

import SwiftUI

let appThemeRedColor:Color = Color(AppString.colorPrimaryColor)


enum AppString {

    static let baseUrl = "http://13.50.109.14/api/customer/"
    static let categoriesApi = "http://13.50.109.14/api/categories"
    static let verifyOtpApi = "verify-otp"
    static let resendOtpApi = "resend-otp"
    static let sendOtpApi = "send-otp"
    static let registerApi = "register"
    static let fetchCategories = "categories"
    static let googleLoginApi = "auth-google"
    static let createOfferApi = "offers-store"
    static let offerApi = "http://13.50.109.14/api/offers"
    static let offerRemoveApi = "offers-destroy"
    static let OfferCustomerApi = "offers"
    static let saveToCartApi = "cart-offers/create"
    static let cartOfferApi = "cart-offers"
    static let deleteCartOfferApi = "cart-offers/delete/"
    static let customerProfile = "profile"
    static let customerProfileUpdate = "profile/update"
    static let refreshTokenApi = "refresh-token"


    // string constant
    static let appName = "BumperPick"
    static let yourGatewayToStunningOffer = "Your gateway to stunning \noffers!"
    static let getStarted = "Get Started"
    static let findTheBestOffer = "Find the best offers and events around you. \nGrab it, don't miss it!"
    static let loginWithYourMobileNumber = "Login with your mobile number"
    static let enterYourMobileNumber = "Enter your mobile number"
    static let termsAndConditions = "I accept the Terms and conditions & Privacy policy"
    static let signInWithGoogle = "Sign in with Google"
    static let verifyYourOtp = "Verify your OTP"
    static let verify = "Verify"
    static let didNotReceiveOtp = "Didn't receive the otp?"
    static let resend = "Resend"
    static let retryIn = "Retry in"
    static let done = "Done"
    static let locationPermissionRequired = "Location Permission Required"
    static let allowingLocationAccess = "Allowing location access helps us recommend the best offers and events near you"
    static let allow = "Allow"
    static let dontAllow = "Don’t allow"
    static let sendTo = "Sent to "
    static let phoneNumberIsValid = "Phone number is valid"
    static let phoneNumberValidationDesc = "Please enter a valid 10-digit phone number."
    static let termsAndConditionAlert = "Please accept the Terms and conditions & Privacy policy"
    static let invalidNumber = "Invalid Number"
    static let getOtp = "Get OTP"
    static let pleaseEnterOtp = "Please enter the OTP."
    
    // for color constant
    static let colorPrimaryColor = "PrimaryColor"
    
    // for image constant
    static let imageGetStarted = "GetStarted"
    static let imageBumperPick = "BumperPick"
    static let imageSale = "Sale"
    static let imageGoogleIcon = "GoogleIcon"
    static let imageEdit = "edit"
    static let imageLocation = "location"
}

let screen = UIScreen.main.bounds
