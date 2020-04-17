# Knot

An iOS app that lets you keep track of your account balances and transactions from bank accounts belonging to differing financial institutions.

**Note:** This project is made for personal use only. 

![Screenshots](/Assets/Screenshots.png)

## How it works

This app uses [Plaid](https://www.plaid.com) to link your bank accounts and fetch data including basic account information and past transactions.

## How to use it

1. Go to the [Plaid](https://www.plaid.com) website to get API keys for their `Development` environment. Note that once you sign up, you will automatically be given an API key to access their `Sandbox` environment but you'll need to further apply to get an API key to access their `Development` environment in order to link real bank accounts.

2. This app uses [CocoaPods-keys](https://github.com/orta/cocoapods-keys) to store the API keys. Once you have your API keys, open a terminal in the application's folder and run `pod install`. You will be prompted to enter in the API keys.

3. Open `Knot.xcworkspace` in Xcode.

6. Build and run the app. 



