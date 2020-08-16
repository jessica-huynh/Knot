//
//  PLKConfiguration.h
//  LinkKit
//
//  Copyright © 2016 Plaid Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PLKConstants.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The Plaid API environment selects the Plaid servers with which LinkKit communicates.
 */
typedef NS_ENUM(NSInteger, PLKEnvironment) {
    /// For APIv2 development use.
    PLKEnvironmentDevelopment = 0,
 
    /// For APIv2 testing use.
    PLKEnvironmentSandbox,

    /// For legacy API testing use.
    PLKEnvironmentTartan DEPRECATED_MSG_ATTRIBUTE("the legacy API is no longer supported. Use APIv2 and PLKEnvironmentSandbox instead"),
   
    /// For production use only (APIv1 and APIv2). @remark Requests are billed.
    PLKEnvironmentProduction,
};

/**
 The Plaid API version
 */
typedef NS_ENUM(NSInteger, PLKAPIVersion) {
    /// APIv2 is the current version of the Plaid API.
    PLKAPIv2 = 1,
    /// The latest version of the Plaid API; currently PLKAPIv2. *Note:* This may change with future releases.
    PLKAPILatest,
    /// APIv1 is deprecated and LinkKit will return an error when configured with APIv1.
    PLKAPIv1 DEPRECATED_MSG_ATTRIBUTE("transition to APIv2 instead") = 0,
};
/// The default API version to use. *Note:* This may change with future releases
static PLKAPIVersion kPLKAPIVersionDefault = PLKAPIv2;


/// Returns PLKAPIVersion corresponding to the data in the given string or -1 if the string contained invalid api version data.
PLK_EXTERN PLKAPIVersion PLKAPIVersionFromString(NSString* apiVersion);

/// Returns PLKProduct corresponding to the data in the given string or -1 contained invalid product data.
PLK_EXTERN PLKProduct PLKProductFromArray(NSArray<NSString*>* array);

/// Returns PLKEnvironment corresponding to the data in the given string or -1 contained invalid environment data.
PLK_EXTERN PLKEnvironment PLKEnvironmentFromString(NSString* environment);


/// A Plaid public_key that can be used for testing when using the legacy API and PLKEnvironmentTartan.
PLK_EXTERN NSString* const kPLKTestKey DEPRECATED_MSG_ATTRIBUTE("the legacy API is no longer supported. Use APIv2 and PLKEnvironmentSandbox with your own public key instead");

/// A Plaid public_key that can be used for testing longtail when using the legacy API and PLKEnvironmentTartan.
PLK_EXTERN NSString* const kPLKTestKeyLongtailAuth DEPRECATED_MSG_ATTRIBUTE("the legacy API is no longer supported. Use APIv2 and PLKEnvironmentSandbox with your own public key instead");

/// A Plaid public_key to use when using the item-add flow.
PLK_EXTERN NSString* const kPLKUseItemAddTokenInsteadOfPublicKey DEPRECATED_MSG_ATTRIBUTE("please use kPLKUseTokenInsteadOfPublicKey instead");

/// A Plaid public_key to use when using the link token flow.
PLK_EXTERN NSString* const kPLKUseTokenInsteadOfPublicKey;

// Keys customizing panes, see customizeWithDictionary:
/// This pane is shown at the end of an successful update flow.
PLK_EXTERN NSString* const kPLKConnectedPaneKey;

/// This pane is shown at the end of an successful update flow.
PLK_EXTERN NSString* const kPLKReconnectedPaneKey;

/// This pane is shown at the end of an successful update flow.
PLK_EXTERN NSString* const kPLKInstitutionSelectPaneKey;

/// This pane is shown at the end of an successful update flow.
PLK_EXTERN NSString* const kPLKInstitutionSearchPaneKey;

// Keys customizing UI elements in panes, see customizeWithDictionary:
/// The text shown as the navigation bar title.
PLK_EXTERN NSString* const kPLKCustomizationTitleKey;

/// The text shown upon successful (re)connection of an account.
PLK_EXTERN NSString* const kPLKCustomizationMessageKey;

/// The text shown on the submit button.
PLK_EXTERN NSString* const kPLKCustomizationSubmitButtonKey;

/// The text shown on the button on the bottom of the institution select view to show the institution search.
PLK_EXTERN NSString* const kPLKCustomizationSearchButtonKey;

/// The text shown when the institution search is activated.
PLK_EXTERN NSString* const kPLKCustomizationInitialMessageKey;

/// The text shown for empty search results.
PLK_EXTERN NSString* const kPLKCustomizationNoResultsMessageKey;

/// The text shown on the exit button for empty search results.
PLK_EXTERN NSString* const kPLKCustomizationExitButtonKey;


/**
 The PLKConfiguration class defines properties used when interacting with the Plaid API.
 */
@interface PLKConfiguration : NSObject

// MARK: Required configuration properties
/// The public_key associated with your account. Available from https://dashboard.plaid.com/account/keys.
@property (readonly) NSString* key;

/// The Plaid API environment on which to create user accounts.
@property (readonly) PLKEnvironment env;

/**
 The Plaid requested products.
 @see PLKProduct
 */
@property (readonly) PLKProduct product;

/// Displayed once a user has successfully linked their account.
@property (copy,nonatomic) NSString* _Nullable clientName;

// MARK: Optional configuration properties
/**
 The webhook to receive notifications once a user's transactions have been processed and are ready for use.
 For details consult https://plaid.com/docs/api/#webhook.
 */
@property (copy,nonatomic) NSURL* _Nullable webhook;

/// The legal name of the end-user, necessary for microdeposit support.
@property (copy,nonatomic) NSString* _Nullable userLegalName;

/// The email address of the end-user, necessary for microdeposit support.
@property (copy,nonatomic) NSString* _Nullable userEmailAddress;

/// The phone number of the end-user, used for returning user experience.
@property (copy,nonatomic) NSString* _Nullable userPhoneNumber;

/// A list of ISO 3166-1 alpha-2 country codes, used to select institutions available in the given countries.
@property (copy,nonatomic) NSArray<NSString*>* _Nullable countryCodes;

/// A map of account types and subtypes, used to filter accounts so only the desired account types/subtypes are returned
/// and only institutions that support the requested subtypes are displayed in Link.
@property (copy,nonatomic) NSDictionary<NSString*, NSArray<NSString*>*>* _Nullable accountSubtypes;

/**
 An URL that has been registered with Plaid for OpenBanking App-to-App authentication
 and is set up as an Apple universal link for your application.
 */
@property (copy,nonatomic) NSURL* _Nullable oauthRedirectUri;

/**
 The oauthNonce must be uniquely generated per login, it must not be contained within the oauthRedirectUri,
 and must be separate from any user identifiers you pass with the oauthRedirectUri.
 */
@property (copy,nonatomic) NSString* _Nullable oauthNonce;

/// The name of the specific customization to initialize with. Will use 'default' if none is passed.
@property (copy,nonatomic) NSString* _Nullable linkCustomizationName;

/**
 Specify a Plaid-supported language to localize Link. English ('en') will be used by default.
 For details consult https://plaid.com/docs/#parameter-reference.
 */
@property (copy,nonatomic) NSString* _Nullable language;

/// Whether support for longtailAuth institutions should be enabled.
@property (readonly) BOOL longtailAuth;

/// Whether the user should select a specific account to link.
@property (readonly) BOOL selectAccount;

/// The Plaid API version to use.
@property (readonly) PLKAPIVersion apiVersion;

/**
 The singleton instance of the PLKConfiguration class initialized with the values
 from the PLKPlaidLinkConfiguration entry in the applications Info.plist. Note that
 if you want to use Link tokens to integrate with Plaid, you cannot use sharedConfiguration.
 To learn more about Link tokens, visit https://plaid.com/docs/link-token-migration-guide/.

 @return Returns the shared instance of the PLKConfiguration class
         or throws an exception if the provided values are invalid.
 @throws NSInvalidArgumentException
 */
+ (instancetype)sharedConfiguration;

PLK_EMPTY_INIT_UNAVAILABLE;

/**
 This is the designated initializer for this class,
 it initializes a PLKConfiguration object with the provided arguments.

 @param key The public_key associated with your account. Available from https://dashboard.plaid.com/account/keys.
            For link token based flows use `kPLKUseTokenInsteadOfPublicKey`.
 @param env The Plaid API environment on which to create user accounts
 @param product The Plaid products you wish to use.
 @param selectAccount The selectAccount parameter controls whether or not your Link integration uses the Select Account view.
                      This parameter will be removed in a future release, since it has been deprecated in favor of
                      the Select Account view customization available from the Dashboard https://dashboard.plaid.com/link/account-select.
 @param longtailAuth Enables support for longtailAuth institutions when set to YES.
 @param apiVersion Selects the Plaid API version to use.
 @return A PLKConfiguration object initialized with the given arguments.
 @throws NSInvalidArgumentException
 */
- (instancetype)initWithKey:(NSString*)key
                        env:(PLKEnvironment)env
                    product:(PLKProduct)product
              selectAccount:(BOOL)selectAccount // DEPRECATED
               longtailAuth:(BOOL)longtailAuth
                 apiVersion:(PLKAPIVersion)apiVersion NS_DESIGNATED_INITIALIZER;

/**
 Initializes a PLKConfiguration object with the provided arguments.

 @param key The public_key associated with your account. Available from https://dashboard.plaid.com/account/keys.
            For link token based flows use `kPLKUseTokenInsteadOfPublicKey`.
 @param env The Plaid API environment on which to create user accounts
 @param product The Plaid products you wish to use.
 @return A PLKConfiguration object initialized with the given arguments.
 @throws NSInvalidArgumentException
 */
- (instancetype)initWithKey:(NSString*)key
                        env:(PLKEnvironment)env
                    product:(PLKProduct)product;

/**
  Initializes a PLKConfiguration object with the provided arguments
 
  @param linkToken A link_token received from /link/token/create.
  @return A PLKConfiguration object initialized with the link_token environment and the kPLKUseTokenInsteadOfPublicKey key.
  @throws NSInvalidArgumentException
 */
- (instancetype)initWithLinkToken:(NSString*)linkToken;

/**
 Change the text of certain user interface elements.
 
 @param customizations The desired customizations, for details which elements can be customized
 on which panes please refer to the online documentation available at:
 https://github.com/plaid/link/blob/master/ios/README.md#customization
 */
- (void)customizeWithDictionary:(NSDictionary<NSString*,NSDictionary<NSString*,id>*>*)customizations;
@end

NS_ASSUME_NONNULL_END
