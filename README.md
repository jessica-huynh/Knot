# Knot

An iOS app that lets you keep track of your account balances and transactions from bank accounts belonging to various financial institutions.


![Screenshots](/Assets/Screenshots.png)

## How it works

This app uses [Plaid](https://www.plaid.com) to link your bank accounts and fetch data including basic account information and past transactions.

## How to use it

1. Go to the [Plaid](https://www.plaid.com) website to get API keys for their `Development` environment. Note that once you sign up, you will automatically be given an API key to access their `Sandbox` environment but you'll need to further apply to get an API key to access their `Development` environment in order to link real bank accounts. <br> <br>If you do not want to use real account credentials, you can run the app in the `Sandbox` environment but you will need to open  `/Knot/API/PlaidManager.swift` and change the `environment` variable to `.sandbox` from the class' `init()`. Then, you can select any financial institution and use the username: `user_good` and password: `pass_good` to successfully link a dummy account.

2. This app uses [CocoaPods-keys](https://github.com/orta/cocoapods-keys) to store the API keys. Once you have your API keys, open a terminal in the application's folder and run `pod install`. You will be prompted to enter in the API keys. (If you are only planning on running the app in `Sandbox` mode, you can leave the `secret_development` key blank when prompted).

3. Open `Knot.xcworkspace` in Xcode.

6. Build and run the app. 

<br>
<b>Note:</b> This project is made for personal use only. 

