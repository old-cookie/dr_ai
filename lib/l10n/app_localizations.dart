import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// Title of the application
  ///
  /// In en, this message translates to:
  /// **'Dr.AI'**
  String get appTitle;

  /// Text displayed for new chat option
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get optionNewChat;

  /// Text displayed for settings option
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get optionSettings;

  /// Text displayed for install PWA option
  ///
  /// In en, this message translates to:
  /// **'Install Webapp'**
  String get optionInstallPwa;

  /// Text displayed when no chats are found
  ///
  /// In en, this message translates to:
  /// **'No chats found'**
  String get optionNoChatFound;

  /// Prefix for tips
  ///
  /// In en, this message translates to:
  /// **'Tip: '**
  String get tipPrefix;

  /// First tip displayed in the sidebar
  ///
  /// In en, this message translates to:
  /// **'Edit messages by long taping on them'**
  String get tip0;

  /// Second tip displayed in the sidebar
  ///
  /// In en, this message translates to:
  /// **'Delete messages by double tapping on them'**
  String get tip1;

  /// Third tip displayed in the sidebar
  ///
  /// In en, this message translates to:
  /// **'You can change the theme in settings'**
  String get tip2;

  /// Fourth tip displayed in the sidebar
  ///
  /// In en, this message translates to:
  /// **'Select a multimodal model to input images'**
  String get tip3;

  /// Fifth tip displayed in the sidebar
  ///
  /// In en, this message translates to:
  /// **'Chats are automatically saved'**
  String get tip4;

  /// Text displayed for delete chat option
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteChat;

  /// Text displayed for rename chat option
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameChat;

  /// Text displayed for take image button
  ///
  /// In en, this message translates to:
  /// **'Take Image'**
  String get takeImage;

  /// Text displayed for image upload button
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// Text displayed when an image is not valid
  ///
  /// In en, this message translates to:
  /// **'Not a valid image'**
  String get notAValidImage;

  /// Title, if 'Generate Title' is executed on a conversation with no text messages
  ///
  /// In en, this message translates to:
  /// **'Image Only Conversation'**
  String get imageOnlyConversation;

  /// Placeholder text for message input
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageInputPlaceholder;

  /// Tooltip for attachment button
  ///
  /// In en, this message translates to:
  /// **'Add attachment'**
  String get tooltipAttachment;

  /// Tooltip for send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get tooltipSend;

  /// Tooltip for save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tooltipSave;

  /// Tooltip for let AI think button
  ///
  /// In en, this message translates to:
  /// **'Let AI think'**
  String get tooltipLetAIThink;

  /// Tooltip for add host headers button
  ///
  /// In en, this message translates to:
  /// **'Add host headers'**
  String get tooltipAddHostHeaders;

  /// Tooltip for reset button
  ///
  /// In en, this message translates to:
  /// **'Reset current chat'**
  String get tooltipReset;

  /// Tooltip for options button
  ///
  /// In en, this message translates to:
  /// **'Show options'**
  String get tooltipOptions;

  /// Text displayed when no model is selected
  ///
  /// In en, this message translates to:
  /// **'No model selected'**
  String get noModelSelected;

  /// Text displayed when no host is selected
  ///
  /// In en, this message translates to:
  /// **'No host selected'**
  String get noHostSelected;

  /// Text displayed when no model is selected
  ///
  /// In en, this message translates to:
  /// **'<selector>'**
  String get noSelectedModel;

  /// Title of a new chat
  ///
  /// In en, this message translates to:
  /// **'Unnamed Chat'**
  String get newChatTitle;

  /// Text displayed for add model button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get modelDialogAddModel;

  /// Title of the add model dialog
  ///
  /// In en, this message translates to:
  /// **'Add new model'**
  String get modelDialogAddPromptTitle;

  /// Description of the add model dialog
  ///
  /// In en, this message translates to:
  /// **'This can have either be a normal name (e.g. \'llama3\') or name and tag (e.g. \'llama3:70b\').'**
  String get modelDialogAddPromptDescription;

  /// Text displayed when the model already exists
  ///
  /// In en, this message translates to:
  /// **'Model already exists'**
  String get modelDialogAddPromptAlreadyExists;

  /// Text displayed when the model name is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid model name'**
  String get modelDialogAddPromptInvalid;

  /// No description provided for @modelDialogAddAllowanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Proxy'**
  String get modelDialogAddAllowanceTitle;

  /// Description of the allow proxy dialog
  ///
  /// In en, this message translates to:
  /// **'Dr.AI must check if the entered model is valid. For that, we normally send a web request to the Ollama model list and check the status code, but because you\'re using the web client, we can\'t do that directly. Instead, the app will send the request to a different api, hosted by JHubi1, to check for us.\nThis is a one-time request and will only be sent when you add a new model.\nYour IP address will be sent with the request and might be stored for up to ten minutes to prevent spamming with potential harmful intentions.\nIf you accept, your selection will be remembered in the future; if not, nothing will be sent and the model won\'t be added.'**
  String get modelDialogAddAllowanceDescription;

  /// Text displayed for allow button, should be capitalized
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get modelDialogAddAllowanceAllow;

  /// Text displayed for deny button, should be capitalized
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get modelDialogAddAllowanceDeny;

  /// Title of the add model assurance dialog
  ///
  /// In en, this message translates to:
  /// **'Add {model}?'**
  String modelDialogAddAssuranceTitle(String model);

  /// Description of the add model assurance dialog
  ///
  /// In en, this message translates to:
  /// **'Pressing \'Add\' will download the model \'{model}\' directly from the Ollama server to your host.\nThis can take a while depending on your internet connection. The action cannot be canceled.\nIf the app is closed during the download, it\'ll resume if you enter the name into the model dialog again.'**
  String modelDialogAddAssuranceDescription(String model);

  /// Text displayed for add button, should be capitalized
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get modelDialogAddAssuranceAdd;

  /// Text displayed for cancel button, should be capitalized
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get modelDialogAddAssuranceCancel;

  /// Text displayed while loading the download progress
  ///
  /// In en, this message translates to:
  /// **'loading progress'**
  String get modelDialogAddDownloadPercentLoading;

  /// Text displayed while downloading a model
  ///
  /// In en, this message translates to:
  /// **'download at {percent}%'**
  String modelDialogAddDownloadPercent(String percent);

  /// Text displayed when the download of a model fails
  ///
  /// In en, this message translates to:
  /// **'Disconnected, try again'**
  String get modelDialogAddDownloadFailed;

  /// Text displayed when the download of a model is successful
  ///
  /// In en, this message translates to:
  /// **'Download successful'**
  String get modelDialogAddDownloadSuccess;

  /// Title of the delete dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteDialogTitle;

  /// Description of the delete dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to continue? This will wipe all memory of this chat and cannot be undone.\nTo disable this dialog, visit the settings.'**
  String get deleteDialogDescription;

  /// Text displayed for delete button, should be capitalized
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteDialogDelete;

  /// Text displayed for cancel button, should be capitalized
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteDialogCancel;

  /// Text displayed as description for new title input
  ///
  /// In en, this message translates to:
  /// **'Enter new title'**
  String get dialogEnterNewTitle;

  /// Title of the edit message dialog
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get dialogEditMessageTitle;

  /// Title of the behavior settings section
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get settingsTitleBehavior;

  /// Description of the behavior settings section
  ///
  /// In en, this message translates to:
  /// **'Change the behavior of the AI to your liking.'**
  String get settingsDescriptionBehavior;

  /// Title of the interface settings section
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get settingsTitleInterface;

  /// Description of the interface settings section
  ///
  /// In en, this message translates to:
  /// **'Edit how Dr.AI looks and behaves.'**
  String get settingsDescriptionInterface;

  /// Title of the voice settings section. Do not translate if not required!
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get settingsTitleVoice;

  /// Description of the voice settings section
  ///
  /// In en, this message translates to:
  /// **'Enable voice mode and configure voice settings.'**
  String get settingsDescriptionVoice;

  /// Title of the export settings section
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsTitleExport;

  /// Description of the export settings section
  ///
  /// In en, this message translates to:
  /// **'Export and import your chat history.'**
  String get settingsDescriptionExport;

  /// Title of the about settings section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsTitleAbout;

  /// Description of the about settings section
  ///
  /// In en, this message translates to:
  /// **'Check for updates and learn more about Dr.AI.'**
  String get settingsDescriptionAbout;

  /// Text displayed when settings are saved automatically
  ///
  /// In en, this message translates to:
  /// **'Settings are saved automatically'**
  String get settingsSavedAutomatically;

  /// Text displayed when a feature is in alpha
  ///
  /// In en, this message translates to:
  /// **'alpha'**
  String get settingsExperimentalAlpha;

  /// Description of the alpha feature
  ///
  /// In en, this message translates to:
  /// **'This feature is in alpha and may not work as intended or expected.\nCritical issues and/or permanent critical damage to device and/or used services cannot be ruled out.\nUse at your own risk. No liability on the part of the app author.'**
  String get settingsExperimentalAlphaDescription;

  /// Text displayed when a feature is in alpha
  ///
  /// In en, this message translates to:
  /// **'Alpha feature, hold to learn more'**
  String get settingsExperimentalAlphaFeature;

  /// Text displayed when a feature is in beta
  ///
  /// In en, this message translates to:
  /// **'beta'**
  String get settingsExperimentalBeta;

  /// Description of the beta feature
  ///
  /// In en, this message translates to:
  /// **'This feature is in beta and may not work intended or expected.\nLess severe issues may or may not occur. Damage shouldn\'t be critical.\nUse at your own risk.'**
  String get settingsExperimentalBetaDescription;

  /// Text displayed when a feature is in beta
  ///
  /// In en, this message translates to:
  /// **'Beta feature, hold to learn more'**
  String get settingsExperimentalBetaFeature;

  /// Text displayed when a feature is deprecated
  ///
  /// In en, this message translates to:
  /// **'deprecated'**
  String get settingsExperimentalDeprecated;

  /// Description of the deprecated feature
  ///
  /// In en, this message translates to:
  /// **'This feature is deprecated and will be removed in a future version.\nIt may not work as intended or expected. Use at your own risk.'**
  String get settingsExperimentalDeprecatedDescription;

  /// Text displayed when a feature is deprecated
  ///
  /// In en, this message translates to:
  /// **'Deprecated feature, hold to learn more'**
  String get settingsExperimentalDeprecatedFeature;

  /// Text displayed as description for host input
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get settingsHost;

  /// Text displayed when the host is valid
  ///
  /// In en, this message translates to:
  /// **'Valid Host'**
  String get settingsHostValid;

  /// Text displayed when the host is being checked
  ///
  /// In en, this message translates to:
  /// **'Checking Host'**
  String get settingsHostChecking;

  /// Text displayed when the host is invalid
  ///
  /// In en, this message translates to:
  /// **'Issue: {type, select, url{Invalid URL} host{Invalid Host} timeout{Request Failed. Server issues} ratelimit{Too many requests} other{Request Failed}}'**
  String settingsHostInvalid(String type);

  /// Text displayed as description for host header input
  ///
  /// In en, this message translates to:
  /// **'Set host header'**
  String get settingsHostHeaderTitle;

  /// Text displayed when the host header is invalid
  ///
  /// In en, this message translates to:
  /// **'The entered text isn\'t a valid header JSON object'**
  String get settingsHostHeaderInvalid;

  /// Text displayed when the host is invalid
  ///
  /// In en, this message translates to:
  /// **'{type, select, url{The URL you entered is invalid. It isn\'t an a standardized URL format.} other{The host you entered is invalid. It cannot be reached. Please check the host and try again.}}'**
  String settingsHostInvalidDetailed(String type);

  /// Text displayed as description for system message input
  ///
  /// In en, this message translates to:
  /// **'System message'**
  String get settingsSystemMessage;

  /// Text displayed as description for use system message toggle
  ///
  /// In en, this message translates to:
  /// **'Use system message'**
  String get settingsUseSystem;

  /// Description of the use system message toggle
  ///
  /// In en, this message translates to:
  /// **'Disables setting the system message above and use the one of the model instead. Can be useful for models with model files'**
  String get settingsUseSystemDescription;

  /// Text displayed as description for disable markdown toggle
  ///
  /// In en, this message translates to:
  /// **'Disable markdown'**
  String get settingsDisableMarkdown;

  /// Text displayed when behavior settings are not updated for older chats
  ///
  /// In en, this message translates to:
  /// **'Behavior settings are not updated for older chats'**
  String get settingsBehaviorNotUpdatedForOlderChats;

  /// Text displayed as description for show model tags toggle
  ///
  /// In en, this message translates to:
  /// **'Show model tags'**
  String get settingsShowModelTags;

  /// Text displayed as description for preload models toggle
  ///
  /// In en, this message translates to:
  /// **'Preload models'**
  String get settingsPreloadModels;

  /// Text displayed as description for reset on model change toggle
  ///
  /// In en, this message translates to:
  /// **'Reset on model change'**
  String get settingsResetOnModelChange;

  /// Text displayed as description for stream request type. Do not translate if not required!
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get settingsRequestTypeStream;

  /// Text displayed as description for request request type. Do not translate if not required!
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get settingsRequestTypeRequest;

  /// Text displayed as description for generate titles toggle
  ///
  /// In en, this message translates to:
  /// **'Generate titles'**
  String get settingsGenerateTitles;

  /// Text displayed as description for enable editing toggle
  ///
  /// In en, this message translates to:
  /// **'Enable editing of messages'**
  String get settingsEnableEditing;

  /// Text displayed as description for ask before deletion toggle
  ///
  /// In en, this message translates to:
  /// **'Ask before chat deletion'**
  String get settingsAskBeforeDelete;

  /// Text displayed as description for show tips toggle
  ///
  /// In en, this message translates to:
  /// **'Show tips in sidebar'**
  String get settingsShowTips;

  /// Text displayed as description for keep model loaded always toggle
  ///
  /// In en, this message translates to:
  /// **'Keep model always loaded'**
  String get settingsKeepModelLoadedAlways;

  /// Text displayed as description for don't keep model loaded toggle
  ///
  /// In en, this message translates to:
  /// **'Don\'t keep model loaded'**
  String get settingsKeepModelLoadedNever;

  /// Text displayed as description for keep model loaded for toggle
  ///
  /// In en, this message translates to:
  /// **'Set specific time to keep model loaded'**
  String get settingsKeepModelLoadedFor;

  /// Text displayed as description for keep model loaded for set time toggle
  ///
  /// In en, this message translates to:
  /// **'Keep model loaded for {minutes} minutes'**
  String settingsKeepModelLoadedSet(String minutes);

  /// Text displayed as title for the timeout multiplier section
  ///
  /// In en, this message translates to:
  /// **'Timeout multiplier'**
  String get settingsTimeoutMultiplier;

  /// Description of the timeout multiplier section
  ///
  /// In en, this message translates to:
  /// **'Select the multiplier that is applied to every timeout value in the app. Can be useful with a slow internet connection or a slow host.'**
  String get settingsTimeoutMultiplierDescription;

  /// Example for the timeout multiplier
  ///
  /// In en, this message translates to:
  /// **'E.g. message timeout:'**
  String get settingsTimeoutMultiplierExample;

  /// Text displayed as description for enable haptic feedback toggle
  ///
  /// In en, this message translates to:
  /// **'Enable haptic feedback'**
  String get settingsEnableHapticFeedback;

  /// Text displayed as description for maximize on start toggle
  ///
  /// In en, this message translates to:
  /// **'Start maximized'**
  String get settingsMaximizeOnStart;

  /// Text displayed as description for system brightness option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsBrightnessSystem;

  /// Text displayed as description for light brightness option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsBrightnessLight;

  /// Text displayed as description for dark brightness option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsBrightnessDark;

  /// Text displayed as description for device theme option
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get settingsThemeDevice;

  /// Text displayed as description for Dr.AI theme option
  ///
  /// In en, this message translates to:
  /// **'Ollama'**
  String get settingsThemeOllama;

  /// Text displayed as description for temporary fixes section
  ///
  /// In en, this message translates to:
  /// **'Temporary interface fixes'**
  String get settingsTemporaryFixes;

  /// Description of the temporary fixes section
  ///
  /// In en, this message translates to:
  /// **'Enable temporary fixes for interface issues.\nLong press on the individual options to learn more.'**
  String get settingsTemporaryFixesDescription;

  /// Instructions and warnings for the temporary fixes
  ///
  /// In en, this message translates to:
  /// **'Do not toggle any of these settings unless you know what you are doing! The given solutions might not work as expected.\nThey cannot be seen as final or should be judged as such. Issues might occur.'**
  String get settingsTemporaryFixesInstructions;

  /// Text displayed when no fixes are available
  ///
  /// In en, this message translates to:
  /// **'No fixes available'**
  String get settingsTemporaryFixesNoFixes;

  /// Text displayed while loading voice permissions
  ///
  /// In en, this message translates to:
  /// **'Loading voice permissions ...'**
  String get settingsVoicePermissionLoading;

  /// Text displayed when text-to-speech is not supported
  ///
  /// In en, this message translates to:
  /// **'Text-to-speech not supported'**
  String get settingsVoiceTtsNotSupported;

  /// No description provided for @settingsVoiceTtsNotSupportedDescription.
  ///
  /// In en, this message translates to:
  /// **'Text-to-speech services are not supported for the selected language. Select a different language in the language drawer to reenable them.\nOther services like voice recognition and AI thinking will still work as usual, but interaction might not be as fluent.'**
  String get settingsVoiceTtsNotSupportedDescription;

  /// Text displayed when voice permissions are not granted
  ///
  /// In en, this message translates to:
  /// **'Permissions not granted'**
  String get settingsVoicePermissionNot;

  /// Text displayed when voice mode is not enabled
  ///
  /// In en, this message translates to:
  /// **'Voice mode not enabled'**
  String get settingsVoiceNotEnabled;

  /// Text displayed when voice mode is not supported
  ///
  /// In en, this message translates to:
  /// **'Voice mode not supported'**
  String get settingsVoiceNotSupported;

  /// Text displayed as description for enable voice mode toggle
  ///
  /// In en, this message translates to:
  /// **'Enable voice mode'**
  String get settingsVoiceEnable;

  /// Text displayed when no language is selected
  ///
  /// In en, this message translates to:
  /// **'No language selected'**
  String get settingsVoiceNoLanguage;

  /// Text displayed as description for limit language toggle
  ///
  /// In en, this message translates to:
  /// **'Limit to selected language'**
  String get settingsVoiceLimitLanguage;

  /// Text displayed as description for enable AI punctuation toggle
  ///
  /// In en, this message translates to:
  /// **'Enable AI punctuation'**
  String get settingsVoicePunctuation;

  /// Text displayed as description for export chats button
  ///
  /// In en, this message translates to:
  /// **'Export chats'**
  String get settingsExportChats;

  /// Text displayed when chats are exported successfully
  ///
  /// In en, this message translates to:
  /// **'Chats exported successfully'**
  String get settingsExportChatsSuccess;

  /// Text displayed as description for import chats button
  ///
  /// In en, this message translates to:
  /// **'Import chats'**
  String get settingsImportChats;

  /// Title of the import dialog
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsImportChatsTitle;

  /// Description of the import dialog
  ///
  /// In en, this message translates to:
  /// **'The following step will import the chats from the selected file. This will overwrite all currently available chats.\nDo you want to continue?'**
  String get settingsImportChatsDescription;

  /// Text displayed for import button, should be capitalized
  ///
  /// In en, this message translates to:
  /// **'Import and Erase'**
  String get settingsImportChatsImport;

  /// Text displayed for cancel button, should be capitalized
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsImportChatsCancel;

  /// Text displayed when chats are imported successfully
  ///
  /// In en, this message translates to:
  /// **'Chats imported successfully'**
  String get settingsImportChatsSuccess;

  /// Information displayed for export and import options
  ///
  /// In en, this message translates to:
  /// **'This options allows you to export and import your chat history. This can be useful if you want to transfer your chat history to another device or backup your chat history'**
  String get settingsExportInfo;

  /// Warning displayed for export and import options
  ///
  /// In en, this message translates to:
  /// **'Multiple chat histories won\'t be merged! You\'ll loose your current chat history if you import a new one'**
  String get settingsExportWarning;

  /// Text displayed as description for check for updates button
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get settingsUpdateCheck;

  /// Text displayed while looking for updates
  ///
  /// In en, this message translates to:
  /// **'Checking for updates ...'**
  String get settingsUpdateChecking;

  /// Text displayed when the app is up to date
  ///
  /// In en, this message translates to:
  /// **'You are on the latest version'**
  String get settingsUpdateLatest;

  /// Text displayed when an update is available
  ///
  /// In en, this message translates to:
  /// **'Update available (v{version})'**
  String settingsUpdateAvailable(String version);

  /// Text displayed when the API rate limit is exceeded
  ///
  /// In en, this message translates to:
  /// **'Can\'t check, API rate limit exceeded'**
  String get settingsUpdateRateLimit;

  /// Text displayed when an issue occurs while checking for updates
  ///
  /// In en, this message translates to:
  /// **'An issue occurred'**
  String get settingsUpdateIssue;

  /// Title of the update dialog
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get settingsUpdateDialogTitle;

  /// Description of the update dialog
  ///
  /// In en, this message translates to:
  /// **'A new version of Dr.AI is available. Do you want to download and install it now?'**
  String get settingsUpdateDialogDescription;

  /// Text displayed as description for change log button
  ///
  /// In en, this message translates to:
  /// **'Change Log'**
  String get settingsUpdateChangeLog;

  /// Text displayed for update button, should be capitalized
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get settingsUpdateDialogUpdate;

  /// Text displayed for cancel button, should be capitalized
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsUpdateDialogCancel;

  /// Text displayed as description for check for updates toggle
  ///
  /// In en, this message translates to:
  /// **'Check for updates on open'**
  String get settingsCheckForUpdates;

  /// Text displayed as description for GitHub button
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get settingsGithub;

  /// Text displayed as description for report issue button
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get settingsReportIssue;

  /// Text displayed as description for licenses button
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get settingsLicenses;

  /// Text displayed for Vaccine Record
  ///
  /// In en, this message translates to:
  /// **'Vaccine Record'**
  String get optionVaccine;

  /// Text displayed for BMI
  ///
  /// In en, this message translates to:
  /// **'Vaccine Record'**
  String get optionBMI;

  /// Text displayed for Calendar
  ///
  /// In en, this message translates to:
  /// **'Medical Calendar'**
  String get optionCalendar;

  /// Text displayed as description for version
  ///
  /// In en, this message translates to:
  /// **'Dr.AI v{version}'**
  String settingsVersion(String version);

  /// Title of the vaccine record page
  ///
  /// In en, this message translates to:
  /// **'Vaccine Record'**
  String get vaccineRecordTitle;

  /// Title of the Calendar page
  ///
  /// In en, this message translates to:
  /// **'Medical Appointments'**
  String get calendarTitle;

  /// Title of the vaccine detail page
  ///
  /// In en, this message translates to:
  /// **'Vaccination Details'**
  String get vaccineDetailTitle;

  /// Title of add vaccine record page
  ///
  /// In en, this message translates to:
  /// **'Add Vaccination Record'**
  String get vaccineAddTitle;

  /// Label for vaccine name field
  ///
  /// In en, this message translates to:
  /// **'Vaccine Name'**
  String get vaccineName;

  /// Label for dose sequence field
  ///
  /// In en, this message translates to:
  /// **'Dose Sequence'**
  String get vaccineDose;

  /// Label for date field
  ///
  /// In en, this message translates to:
  /// **'Date Received'**
  String get vaccineDate;

  /// Label for place field
  ///
  /// In en, this message translates to:
  /// **'Place Given (Optional)'**
  String get vaccinePlace;

  /// Label for remark field
  ///
  /// In en, this message translates to:
  /// **'Remark (Optional)'**
  String get vaccineRemark;

  /// Label for photo upload
  ///
  /// In en, this message translates to:
  /// **'Vaccination Record Photo (Optional)'**
  String get vaccinePhoto;

  /// Button text for image picker
  ///
  /// In en, this message translates to:
  /// **'Pick Image'**
  String get pickImage;

  /// Button text for save record
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveRecord;

  /// Title for delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecord;

  /// Confirmation message for deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get deleteConfirm;

  /// Button text for cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button text for delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Error message for invalid image format
  ///
  /// In en, this message translates to:
  /// **'Only PNG or JPG images supported'**
  String get imageFormat;

  /// Title of the crop image screen
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get cropImage;

  /// Button text for save cropped image
  ///
  /// In en, this message translates to:
  /// **'Save Image'**
  String get saveImage;

  /// No description provided for @errorLoadingRecords.
  ///
  /// In en, this message translates to:
  /// **'Error loading records.'**
  String get errorLoadingRecords;

  /// No description provided for @noRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No records found.'**
  String get noRecordsFound;

  /// Text shown when no date is selected
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// Date field label with value
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String vaccineFieldDate(String date);

  /// Dose field label with value
  ///
  /// In en, this message translates to:
  /// **'Dose: {dose}'**
  String vaccineFieldDose(String dose);

  /// Place field label with value
  ///
  /// In en, this message translates to:
  /// **'Place: {place}'**
  String vaccineFieldPlace(String place);

  /// Remarks field label with value
  ///
  /// In en, this message translates to:
  /// **'Remarks: {remarks}'**
  String vaccineFieldRemarks(String remarks);

  /// No description provided for @calendarEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Appointment'**
  String get calendarEventTitle;

  /// No description provided for @calendarEventDate.
  ///
  /// In en, this message translates to:
  /// **'Appointment Date'**
  String get calendarEventDate;

  /// No description provided for @calendarEventTime.
  ///
  /// In en, this message translates to:
  /// **'Appointment Time'**
  String get calendarEventTime;

  /// No description provided for @calendarEventNotification.
  ///
  /// In en, this message translates to:
  /// **'Notify Before'**
  String get calendarEventNotification;

  /// No description provided for @calendarEventSave.
  ///
  /// In en, this message translates to:
  /// **'Save Appointment'**
  String get calendarEventSave;

  /// No description provided for @calendarEventDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Appointment'**
  String get calendarEventDelete;

  /// No description provided for @calendarEventNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No appointments for this day'**
  String get calendarEventNoEvents;

  /// No description provided for @calendarEventAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Appointment'**
  String get calendarEventAdd;

  /// No description provided for @calendarReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment Reminder'**
  String get calendarReminderTitle;

  /// Message shown in appointment reminder notification
  ///
  /// In en, this message translates to:
  /// **'You have an upcoming appointment \'{eventTitle}\''**
  String calendarReminderBody(String eventTitle);

  /// Message shown when an event is deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted event: {eventTitle}'**
  String calendarDeleteEvent(String eventTitle);

  /// No description provided for @calendarDeleteEventUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get calendarDeleteEventUndo;

  /// Title of BMI calculator page
  ///
  /// In en, this message translates to:
  /// **'BMI Calculator'**
  String get bmiCalculator;

  /// Label for height input field
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get bmiHeight;

  /// Label for weight input field
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get bmiWeight;

  /// Label for age input field
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get bmiAge;

  /// Label for gender selection
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get bmiGender;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get bmiMale;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get bmiFemale;

  /// Label for BMI standard selection
  ///
  /// In en, this message translates to:
  /// **'BMI Standard'**
  String get bmiStandard;

  /// Asian BMI standard option
  ///
  /// In en, this message translates to:
  /// **'Asian Standard'**
  String get bmiAsian;

  /// WHO BMI standard option
  ///
  /// In en, this message translates to:
  /// **'WHO Standard'**
  String get bmiWHO;

  /// Text for calculate button
  ///
  /// In en, this message translates to:
  /// **'Calculate BMI'**
  String get bmiCalculate;

  /// BMI result text
  ///
  /// In en, this message translates to:
  /// **'BMI Index: {value}'**
  String bmiResult(String value);

  /// Title for BMI standards section
  ///
  /// In en, this message translates to:
  /// **'BMI Classification Standards:'**
  String get bmiStandardTitle;

  /// Title for child BMI standards
  ///
  /// In en, this message translates to:
  /// **'Child/Teen BMI Standards:'**
  String get bmiChildStandardTitle;

  /// Title for Asian BMI standards
  ///
  /// In en, this message translates to:
  /// **'Asian Adult BMI Standards:'**
  String get bmiAsianStandardTitle;

  /// Title for WHO BMI standards
  ///
  /// In en, this message translates to:
  /// **'WHO Adult BMI Standards:'**
  String get bmiWHOStandardTitle;

  /// Validation message for height input
  ///
  /// In en, this message translates to:
  /// **'Please enter height'**
  String get bmiValidationEnterHeight;

  /// Validation message for invalid height
  ///
  /// In en, this message translates to:
  /// **'Please enter valid height'**
  String get bmiValidationInvalidHeight;

  /// Validation message for weight input
  ///
  /// In en, this message translates to:
  /// **'Please enter weight'**
  String get bmiValidationEnterWeight;

  /// Validation message for invalid weight
  ///
  /// In en, this message translates to:
  /// **'Please enter valid weight'**
  String get bmiValidationInvalidWeight;

  /// Validation message for age input
  ///
  /// In en, this message translates to:
  /// **'Please enter age'**
  String get bmiValidationEnterAge;

  /// Validation message for invalid age
  ///
  /// In en, this message translates to:
  /// **'Please enter valid age'**
  String get bmiValidationInvalidAge;

  /// Title for BMI classification section
  ///
  /// In en, this message translates to:
  /// **'BMI 分類標準：'**
  String get bmiClassificationTitle;

  /// Title for child/teen BMI standards
  ///
  /// In en, this message translates to:
  /// **'兒童/青少年 BMI 標準:'**
  String get bmiChildStandard;

  /// Child BMI category - severely wasted
  ///
  /// In en, this message translates to:
  /// **'• 嚴重消瘦 (Severely wasted)'**
  String get bmiChildSeverelyWasted;

  /// Child BMI category - wasted
  ///
  /// In en, this message translates to:
  /// **'• 消瘦 (Wasted)'**
  String get bmiChildWasted;

  /// Child BMI category - normal
  ///
  /// In en, this message translates to:
  /// **'• 正常體重 (Normal weight)'**
  String get bmiChildNormal;

  /// Child BMI category - risk of overweight
  ///
  /// In en, this message translates to:
  /// **'• 可能過重風險 (Risk of overweight)'**
  String get bmiChildRiskOverweight;

  /// Child BMI category - overweight
  ///
  /// In en, this message translates to:
  /// **'• 過重 (Overweight)'**
  String get bmiChildOverweight;

  /// Child BMI category - obese
  ///
  /// In en, this message translates to:
  /// **'• 肥胖 (Obese)'**
  String get bmiChildObese;

  /// Title for Asian adult BMI standards
  ///
  /// In en, this message translates to:
  /// **'亞洲成人 BMI 標準:'**
  String get bmiAsianAdultStandard;

  /// Asian adult BMI category - underweight
  ///
  /// In en, this message translates to:
  /// **'• 體重過輕：BMI < 18.5'**
  String get bmiAsianUnderweight;

  /// Asian adult BMI category - normal
  ///
  /// In en, this message translates to:
  /// **'• 體重正常：18.5 ≤ BMI < 23'**
  String get bmiAsianNormal;

  /// Asian adult BMI category - overweight
  ///
  /// In en, this message translates to:
  /// **'• 體重過重：23 ≤ BMI < 25'**
  String get bmiAsianOverweight;

  /// Asian adult BMI category - obese
  ///
  /// In en, this message translates to:
  /// **'• 肥胖：BMI ≥ 25'**
  String get bmiAsianObese;

  /// Title for WHO adult BMI standards
  ///
  /// In en, this message translates to:
  /// **'WHO成人 BMI 標準:'**
  String get bmiWHOAdultStandard;

  /// WHO adult BMI category - underweight
  ///
  /// In en, this message translates to:
  /// **'• 體重過輕：BMI < 18.5'**
  String get bmiWHOUnderweight;

  /// WHO adult BMI category - normal
  ///
  /// In en, this message translates to:
  /// **'• 體重正常：18.5 ≤ BMI < 25'**
  String get bmiWHONormal;

  /// WHO adult BMI category - overweight
  ///
  /// In en, this message translates to:
  /// **'• 體重過重：25 ≤ BMI < 30'**
  String get bmiWHOOverweight;

  /// WHO adult BMI category - obese
  ///
  /// In en, this message translates to:
  /// **'• 肥胖：BMI ≥ 30'**
  String get bmiWHOObese;

  /// BMI category - severely wasted
  ///
  /// In en, this message translates to:
  /// **'Severely Wasted'**
  String get bmiSeverelyWasted;

  /// BMI category - underweight
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiUnderweight;

  /// BMI category - wasted
  ///
  /// In en, this message translates to:
  /// **'Wasted'**
  String get bmiWasted;

  /// BMI category - normal
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get bmiNormal;

  /// BMI category - normal weight
  ///
  /// In en, this message translates to:
  /// **'Normal Weight'**
  String get bmiNormalWeight;

  /// BMI category - possible risk of overweight
  ///
  /// In en, this message translates to:
  /// **'Possible Risk of Overweight'**
  String get bmiPossibleRiskOverweight;

  /// BMI category - overweight
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiOverweight;

  /// No description provided for @dialogSelectModel.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get dialogSelectModel;

  /// BMI category - obese
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmiObese;

  /// No description provided for @addMedicalCertificate.
  ///
  /// In en, this message translates to:
  /// **'Add Medical Certificate'**
  String get addMedicalCertificate;

  /// No description provided for @certificateNumber.
  ///
  /// In en, this message translates to:
  /// **'Certificate Number'**
  String get certificateNumber;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospital;

  /// No description provided for @selectHospital.
  ///
  /// In en, this message translates to:
  /// **'Select Hospital'**
  String get selectHospital;

  /// No description provided for @treatmentDate.
  ///
  /// In en, this message translates to:
  /// **'Treatment Date'**
  String get treatmentDate;

  /// No description provided for @hospitalizationPeriod.
  ///
  /// In en, this message translates to:
  /// **'Hospitalization Period'**
  String get hospitalizationPeriod;

  /// No description provided for @sickLeavePeriod.
  ///
  /// In en, this message translates to:
  /// **'Sick Leave Period'**
  String get sickLeavePeriod;

  /// No description provided for @followUpDate.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Date'**
  String get followUpDate;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @certificateImage.
  ///
  /// In en, this message translates to:
  /// **'Certificate Image'**
  String get certificateImage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @medicalCertificates.
  ///
  /// In en, this message translates to:
  /// **'Medical Certificates'**
  String get medicalCertificates;

  /// No description provided for @viewCertificate.
  ///
  /// In en, this message translates to:
  /// **'View Certificate'**
  String get viewCertificate;

  /// No description provided for @noCertificatesFound.
  ///
  /// In en, this message translates to:
  /// **'No certificates found'**
  String get noCertificatesFound;

  /// Message displayed when a record is saved successfully
  ///
  /// In en, this message translates to:
  /// **'Record saved'**
  String get recordSaved;

  /// Message displayed when certificate number is not entered
  ///
  /// In en, this message translates to:
  /// **'Please enter certificate number'**
  String get pleaseEnterCertificateNumber;

  /// Message displayed when treatment date is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select treatment date'**
  String get pleaseSelectTreatmentDate;

  /// Label for hospitalization start date
  ///
  /// In en, this message translates to:
  /// **'Hospitalization Start Date'**
  String get hospitalizationStartDate;

  /// Label for hospitalization end date
  ///
  /// In en, this message translates to:
  /// **'Hospitalization End Date'**
  String get hospitalizationEndDate;

  /// Label for sick leave start date
  ///
  /// In en, this message translates to:
  /// **'Sick Leave Start Date'**
  String get sickLeaveStartDate;

  /// Label for sick leave end date
  ///
  /// In en, this message translates to:
  /// **'Sick Leave End Date'**
  String get sickLeaveEndDate;

  /// No description provided for @optionMedicalCertificate.
  ///
  /// In en, this message translates to:
  /// **'Medical Certificate'**
  String get optionMedicalCertificate;

  /// No description provided for @searchHospital.
  ///
  /// In en, this message translates to:
  /// **'Search hospital...'**
  String get searchHospital;

  /// No description provided for @serverConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Server Connection Error'**
  String get serverConnectionError;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'ok'**
  String get ok;

  /// No description provided for @serverNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Server Not Configured'**
  String get serverNotConfigured;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'loading'**
  String get loading;

  /// Button text for selecting an image
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
