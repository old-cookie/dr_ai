// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dr.AI';

  @override
  String get optionNewChat => 'New Chat';

  @override
  String get optionSettings => 'Settings';

  @override
  String get optionInstallPwa => 'Install Webapp';

  @override
  String get optionNoChatFound => 'No chats found';

  @override
  String get tipPrefix => 'Tip: ';

  @override
  String get tip0 => 'Edit messages by long taping on them';

  @override
  String get tip1 => 'Delete messages by double tapping on them';

  @override
  String get tip2 => 'You can change the theme in settings';

  @override
  String get tip3 => 'Select a multimodal model to input images';

  @override
  String get tip4 => 'Chats are automatically saved';

  @override
  String get deleteChat => 'Delete';

  @override
  String get renameChat => 'Rename';

  @override
  String get takeImage => 'Take Image';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get notAValidImage => 'Not a valid image';

  @override
  String get imageOnlyConversation => 'Image Only Conversation';

  @override
  String get messageInputPlaceholder => 'Message';

  @override
  String get tooltipAttachment => 'Add attachment';

  @override
  String get tooltipSend => 'Send';

  @override
  String get tooltipSave => 'Save';

  @override
  String get tooltipLetAIThink => 'Let AI think';

  @override
  String get tooltipAddHostHeaders => 'Add host headers';

  @override
  String get tooltipReset => 'Reset current chat';

  @override
  String get tooltipOptions => 'Show options';

  @override
  String get noModelSelected => 'No model selected';

  @override
  String get noHostSelected => 'No host selected';

  @override
  String get noSelectedModel => '<selector>';

  @override
  String get newChatTitle => 'Unnamed Chat';

  @override
  String get modelDialogAddModel => 'Add';

  @override
  String get modelDialogAddPromptTitle => 'Add new model';

  @override
  String get modelDialogAddPromptDescription => 'This can have either be a normal name (e.g. \'llama3\') or name and tag (e.g. \'llama3:70b\').';

  @override
  String get modelDialogAddPromptAlreadyExists => 'Model already exists';

  @override
  String get modelDialogAddPromptInvalid => 'Invalid model name';

  @override
  String get modelDialogAddAllowanceTitle => 'Allow Proxy';

  @override
  String get modelDialogAddAllowanceDescription => 'Dr.AI must check if the entered model is valid. For that, we normally send a web request to the Ollama model list and check the status code, but because you\'re using the web client, we can\'t do that directly. Instead, the app will send the request to a different api, hosted by JHubi1, to check for us.\nThis is a one-time request and will only be sent when you add a new model.\nYour IP address will be sent with the request and might be stored for up to ten minutes to prevent spamming with potential harmful intentions.\nIf you accept, your selection will be remembered in the future; if not, nothing will be sent and the model won\'t be added.';

  @override
  String get modelDialogAddAllowanceAllow => 'Allow';

  @override
  String get modelDialogAddAllowanceDeny => 'Deny';

  @override
  String modelDialogAddAssuranceTitle(String model) {
    return 'Add $model?';
  }

  @override
  String modelDialogAddAssuranceDescription(String model) {
    return 'Pressing \'Add\' will download the model \'$model\' directly from the Ollama server to your host.\nThis can take a while depending on your internet connection. The action cannot be canceled.\nIf the app is closed during the download, it\'ll resume if you enter the name into the model dialog again.';
  }

  @override
  String get modelDialogAddAssuranceAdd => 'Add';

  @override
  String get modelDialogAddAssuranceCancel => 'Cancel';

  @override
  String get modelDialogAddDownloadPercentLoading => 'loading progress';

  @override
  String modelDialogAddDownloadPercent(String percent) {
    return 'download at $percent%';
  }

  @override
  String get modelDialogAddDownloadFailed => 'Disconnected, try again';

  @override
  String get modelDialogAddDownloadSuccess => 'Download successful';

  @override
  String get deleteDialogTitle => 'Delete Chat';

  @override
  String get deleteDialogDescription => 'Are you sure you want to continue? This will wipe all memory of this chat and cannot be undone.\nTo disable this dialog, visit the settings.';

  @override
  String get deleteDialogDelete => 'Delete';

  @override
  String get deleteDialogCancel => 'Cancel';

  @override
  String get dialogEnterNewTitle => 'Enter new title';

  @override
  String get dialogEditMessageTitle => 'Edit message';

  @override
  String get settingsTitleBehavior => 'Behavior';

  @override
  String get settingsDescriptionBehavior => 'Change the behavior of the AI to your liking.';

  @override
  String get settingsTitleInterface => 'Interface';

  @override
  String get settingsDescriptionInterface => 'Edit how Dr.AI looks and behaves.';

  @override
  String get settingsTitleVoice => 'Voice';

  @override
  String get settingsDescriptionVoice => 'Enable voice mode and configure voice settings.';

  @override
  String get settingsTitleExport => 'Export';

  @override
  String get settingsDescriptionExport => 'Export and import your chat history.';

  @override
  String get settingsTitleAbout => 'About';

  @override
  String get settingsDescriptionAbout => 'Check for updates and learn more about Dr.AI.';

  @override
  String get settingsSavedAutomatically => 'Settings are saved automatically';

  @override
  String get settingsExperimentalAlpha => 'alpha';

  @override
  String get settingsExperimentalAlphaDescription => 'This feature is in alpha and may not work as intended or expected.\nCritical issues and/or permanent critical damage to device and/or used services cannot be ruled out.\nUse at your own risk. No liability on the part of the app author.';

  @override
  String get settingsExperimentalAlphaFeature => 'Alpha feature, hold to learn more';

  @override
  String get settingsExperimentalBeta => 'beta';

  @override
  String get settingsExperimentalBetaDescription => 'This feature is in beta and may not work intended or expected.\nLess severe issues may or may not occur. Damage shouldn\'t be critical.\nUse at your own risk.';

  @override
  String get settingsExperimentalBetaFeature => 'Beta feature, hold to learn more';

  @override
  String get settingsExperimentalDeprecated => 'deprecated';

  @override
  String get settingsExperimentalDeprecatedDescription => 'This feature is deprecated and will be removed in a future version.\nIt may not work as intended or expected. Use at your own risk.';

  @override
  String get settingsExperimentalDeprecatedFeature => 'Deprecated feature, hold to learn more';

  @override
  String get settingsHost => 'Host';

  @override
  String get settingsHostValid => 'Valid Host';

  @override
  String get settingsHostChecking => 'Checking Host';

  @override
  String settingsHostInvalid(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'url': 'Invalid URL',
        'host': 'Invalid Host',
        'timeout': 'Request Failed. Server issues',
        'ratelimit': 'Too many requests',
        'other': 'Request Failed',
      },
    );
    return 'Issue: $_temp0';
  }

  @override
  String get settingsHostHeaderTitle => 'Set host header';

  @override
  String get settingsHostHeaderInvalid => 'The entered text isn\'t a valid header JSON object';

  @override
  String settingsHostInvalidDetailed(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'url': 'The URL you entered is invalid. It isn\'t an a standardized URL format.',
        'other': 'The host you entered is invalid. It cannot be reached. Please check the host and try again.',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingsSystemMessage => 'System message';

  @override
  String get settingsUseSystem => 'Use system message';

  @override
  String get settingsUseSystemDescription => 'Disables setting the system message above and use the one of the model instead. Can be useful for models with model files';

  @override
  String get settingsDisableMarkdown => 'Disable markdown';

  @override
  String get settingsBehaviorNotUpdatedForOlderChats => 'Behavior settings are not updated for older chats';

  @override
  String get settingsShowModelTags => 'Show model tags';

  @override
  String get settingsPreloadModels => 'Preload models';

  @override
  String get settingsResetOnModelChange => 'Reset on model change';

  @override
  String get settingsRequestTypeStream => 'Stream';

  @override
  String get settingsRequestTypeRequest => 'Request';

  @override
  String get settingsGenerateTitles => 'Generate titles';

  @override
  String get settingsEnableEditing => 'Enable editing of messages';

  @override
  String get settingsAskBeforeDelete => 'Ask before chat deletion';

  @override
  String get settingsShowTips => 'Show tips in sidebar';

  @override
  String get settingsKeepModelLoadedAlways => 'Keep model always loaded';

  @override
  String get settingsKeepModelLoadedNever => 'Don\'t keep model loaded';

  @override
  String get settingsKeepModelLoadedFor => 'Set specific time to keep model loaded';

  @override
  String settingsKeepModelLoadedSet(String minutes) {
    return 'Keep model loaded for $minutes minutes';
  }

  @override
  String get settingsTimeoutMultiplier => 'Timeout multiplier';

  @override
  String get settingsTimeoutMultiplierDescription => 'Select the multiplier that is applied to every timeout value in the app. Can be useful with a slow internet connection or a slow host.';

  @override
  String get settingsTimeoutMultiplierExample => 'E.g. message timeout:';

  @override
  String get settingsEnableHapticFeedback => 'Enable haptic feedback';

  @override
  String get settingsMaximizeOnStart => 'Start maximized';

  @override
  String get settingsBrightnessSystem => 'System';

  @override
  String get settingsBrightnessLight => 'Light';

  @override
  String get settingsBrightnessDark => 'Dark';

  @override
  String get settingsThemeDevice => 'Device';

  @override
  String get settingsThemeOllama => 'Ollama';

  @override
  String get settingsTemporaryFixes => 'Temporary interface fixes';

  @override
  String get settingsTemporaryFixesDescription => 'Enable temporary fixes for interface issues.\nLong press on the individual options to learn more.';

  @override
  String get settingsTemporaryFixesInstructions => 'Do not toggle any of these settings unless you know what you are doing! The given solutions might not work as expected.\nThey cannot be seen as final or should be judged as such. Issues might occur.';

  @override
  String get settingsTemporaryFixesNoFixes => 'No fixes available';

  @override
  String get settingsVoicePermissionLoading => 'Loading voice permissions ...';

  @override
  String get settingsVoiceTtsNotSupported => 'Text-to-speech not supported';

  @override
  String get settingsVoiceTtsNotSupportedDescription => 'Text-to-speech services are not supported for the selected language. Select a different language in the language drawer to reenable them.\nOther services like voice recognition and AI thinking will still work as usual, but interaction might not be as fluent.';

  @override
  String get settingsVoicePermissionNot => 'Permissions not granted';

  @override
  String get settingsVoiceNotEnabled => 'Voice mode not enabled';

  @override
  String get settingsVoiceNotSupported => 'Voice mode not supported';

  @override
  String get settingsVoiceEnable => 'Enable voice mode';

  @override
  String get settingsVoiceNoLanguage => 'No language selected';

  @override
  String get settingsVoiceLimitLanguage => 'Limit to selected language';

  @override
  String get settingsVoicePunctuation => 'Enable AI punctuation';

  @override
  String get settingsExportChats => 'Export chats';

  @override
  String get settingsExportChatsSuccess => 'Chats exported successfully';

  @override
  String get settingsImportChats => 'Import chats';

  @override
  String get settingsImportChatsTitle => 'Import';

  @override
  String get settingsImportChatsDescription => 'The following step will import the chats from the selected file. This will overwrite all currently available chats.\nDo you want to continue?';

  @override
  String get settingsImportChatsImport => 'Import and Erase';

  @override
  String get settingsImportChatsCancel => 'Cancel';

  @override
  String get settingsImportChatsSuccess => 'Chats imported successfully';

  @override
  String get settingsExportInfo => 'This options allows you to export and import your chat history. This can be useful if you want to transfer your chat history to another device or backup your chat history';

  @override
  String get settingsExportWarning => 'Multiple chat histories won\'t be merged! You\'ll loose your current chat history if you import a new one';

  @override
  String get settingsUpdateCheck => 'Check for updates';

  @override
  String get settingsUpdateChecking => 'Checking for updates ...';

  @override
  String get settingsUpdateLatest => 'You are on the latest version';

  @override
  String settingsUpdateAvailable(String version) {
    return 'Update available (v$version)';
  }

  @override
  String get settingsUpdateRateLimit => 'Can\'t check, API rate limit exceeded';

  @override
  String get settingsUpdateIssue => 'An issue occurred';

  @override
  String get settingsUpdateDialogTitle => 'New version available';

  @override
  String get settingsUpdateDialogDescription => 'A new version of Dr.AI is available. Do you want to download and install it now?';

  @override
  String get settingsUpdateChangeLog => 'Change Log';

  @override
  String get settingsUpdateDialogUpdate => 'Update';

  @override
  String get settingsUpdateDialogCancel => 'Cancel';

  @override
  String get settingsCheckForUpdates => 'Check for updates on open';

  @override
  String get settingsGithub => 'GitHub';

  @override
  String get settingsReportIssue => 'Report Issue';

  @override
  String get settingsLicenses => 'Licenses';

  @override
  String get optionVaccine => 'Vaccine Record';

  @override
  String get optionBMI => 'Vaccine Record';

  @override
  String get optionCalendar => 'Medical Calendar';

  @override
  String settingsVersion(String version) {
    return 'Dr.AI v$version';
  }

  @override
  String get vaccineRecordTitle => 'Vaccine Record';

  @override
  String get calendarTitle => 'Medical Appointments';

  @override
  String get vaccineDetailTitle => 'Vaccination Details';

  @override
  String get vaccineAddTitle => 'Add Vaccination Record';

  @override
  String get vaccineName => 'Vaccine Name';

  @override
  String get vaccineDose => 'Dose Sequence';

  @override
  String get vaccineDate => 'Date Received';

  @override
  String get vaccinePlace => 'Place Given (Optional)';

  @override
  String get vaccineRemark => 'Remark (Optional)';

  @override
  String get vaccinePhoto => 'Vaccination Record Photo (Optional)';

  @override
  String get pickImage => 'Pick Image';

  @override
  String get saveRecord => 'Save';

  @override
  String get deleteRecord => 'Delete Record';

  @override
  String get deleteConfirm => 'Are you sure you want to delete this record?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get imageFormat => 'Only PNG or JPG images supported';

  @override
  String get cropImage => 'Crop Image';

  @override
  String get saveImage => 'Save Image';

  @override
  String get errorLoadingRecords => 'Error loading records.';

  @override
  String get noRecordsFound => 'No records found.';

  @override
  String get notSelected => 'Not selected';

  @override
  String vaccineFieldDate(String date) {
    return 'Date: $date';
  }

  @override
  String vaccineFieldDose(String dose) {
    return 'Dose: $dose';
  }

  @override
  String vaccineFieldPlace(String place) {
    return 'Place: $place';
  }

  @override
  String vaccineFieldRemarks(String remarks) {
    return 'Remarks: $remarks';
  }

  @override
  String get calendarEventTitle => 'Add Appointment';

  @override
  String get calendarEventDate => 'Appointment Date';

  @override
  String get calendarEventTime => 'Appointment Time';

  @override
  String get calendarEventNotification => 'Notify Before';

  @override
  String get calendarEventSave => 'Save Appointment';

  @override
  String get calendarEventDelete => 'Delete Appointment';

  @override
  String get calendarEventNoEvents => 'No appointments for this day';

  @override
  String get calendarEventAdd => 'Add Appointment';

  @override
  String get calendarReminderTitle => 'Appointment Reminder';

  @override
  String calendarReminderBody(String eventTitle) {
    return 'You have an upcoming appointment \'$eventTitle\'';
  }

  @override
  String calendarDeleteEvent(String eventTitle) {
    return 'Deleted event: $eventTitle';
  }

  @override
  String get calendarDeleteEventUndo => 'Undo';

  @override
  String get bmiCalculator => 'BMI Calculator';

  @override
  String get bmiHeight => 'Height (cm)';

  @override
  String get bmiWeight => 'Weight (kg)';

  @override
  String get bmiAge => 'Age';

  @override
  String get bmiGender => 'Gender';

  @override
  String get bmiMale => 'Male';

  @override
  String get bmiFemale => 'Female';

  @override
  String get bmiStandard => 'BMI Standard';

  @override
  String get bmiAsian => 'Asian Standard';

  @override
  String get bmiWHO => 'WHO Standard';

  @override
  String get bmiCalculate => 'Calculate BMI';

  @override
  String bmiResult(String value) {
    return 'BMI Index: $value';
  }

  @override
  String get bmiStandardTitle => 'BMI Classification Standards:';

  @override
  String get bmiChildStandardTitle => 'Child/Teen BMI Standards:';

  @override
  String get bmiAsianStandardTitle => 'Asian Adult BMI Standards:';

  @override
  String get bmiWHOStandardTitle => 'WHO Adult BMI Standards:';

  @override
  String get bmiValidationEnterHeight => 'Please enter height';

  @override
  String get bmiValidationInvalidHeight => 'Please enter valid height';

  @override
  String get bmiValidationEnterWeight => 'Please enter weight';

  @override
  String get bmiValidationInvalidWeight => 'Please enter valid weight';

  @override
  String get bmiValidationEnterAge => 'Please enter age';

  @override
  String get bmiValidationInvalidAge => 'Please enter valid age';

  @override
  String get bmiClassificationTitle => 'BMI classification criteria: ';

  @override
  String get bmiChildStandard => 'BMI standards for children/teens:';

  @override
  String get bmiChildSeverelyWasted => '• Severely wasted';

  @override
  String get bmiChildWasted => '• Wasted';

  @override
  String get bmiChildNormal => '• Normal weight';

  @override
  String get bmiChildRiskOverweight => '• Risk of overweight';

  @override
  String get bmiChildOverweight => '• Overweight';

  @override
  String get bmiChildObese => '• Obese';

  @override
  String get bmiAsianAdultStandard => 'BMI standards for Asian adults:';

  @override
  String get bmiAsianUnderweight => '• Underweight: BMI < 18.5';

  @override
  String get bmiAsianNormal => '• Normal weight: 18.5 ≤ BMI < 23';

  @override
  String get bmiAsianOverweight => '• Overweight: 23 ≤ BMI < 25';

  @override
  String get bmiAsianObese => '• Obesity: BMI ≥ 25';

  @override
  String get bmiWHOAdultStandard => 'WHO adult BMI standard:';

  @override
  String get bmiWHOUnderweight => '• Underweight: BMI < 18.5';

  @override
  String get bmiWHONormal => '• Normal weight: 18.5 ≤ BMI < 25';

  @override
  String get bmiWHOOverweight => '• Overweight: 25 ≤ BMI < 30';

  @override
  String get bmiWHOObese => '• Obesity: BMI ≥ 30';

  @override
  String get bmiSeverelyWasted => 'Severely Wasted';

  @override
  String get bmiUnderweight => 'Underweight';

  @override
  String get bmiWasted => 'Wasted';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiNormalWeight => 'Normal Weight';

  @override
  String get bmiPossibleRiskOverweight => 'Possible Risk of Overweight';

  @override
  String get bmiOverweight => 'Overweight';

  @override
  String get dialogSelectModel => 'Select Model';

  @override
  String get bmiObese => 'Obese';

  @override
  String get addMedicalCertificate => 'Add Medical Certificate';

  @override
  String get certificateNumber => 'Certificate Number';

  @override
  String get hospital => 'Hospital';

  @override
  String get selectHospital => 'Select Hospital';

  @override
  String get treatmentDate => 'Treatment Date';

  @override
  String get hospitalizationPeriod => 'Hospitalization Period';

  @override
  String get sickLeavePeriod => 'Sick Leave Period';

  @override
  String get followUpDate => 'Follow-up Date';

  @override
  String get remarks => 'Remarks';

  @override
  String get certificateImage => 'Certificate Image';

  @override
  String get save => 'Save';

  @override
  String get selectDate => 'Select Date';

  @override
  String get changeImage => 'Change Image';

  @override
  String get medicalCertificates => 'Medical Certificates';

  @override
  String get viewCertificate => 'View Certificate';

  @override
  String get noCertificatesFound => 'No certificates found';

  @override
  String get recordSaved => 'Record saved';

  @override
  String get pleaseEnterCertificateNumber => 'Please enter certificate number';

  @override
  String get pleaseSelectTreatmentDate => 'Please select treatment date';

  @override
  String get hospitalizationStartDate => 'Hospitalization Start Date';

  @override
  String get hospitalizationEndDate => 'Hospitalization End Date';

  @override
  String get sickLeaveStartDate => 'Sick Leave Start Date';

  @override
  String get sickLeaveEndDate => 'Sick Leave End Date';

  @override
  String get optionMedicalCertificate => 'Medical Certificate';

  @override
  String get searchHospital => 'Search hospital...';

  @override
  String get serverConnectionError => 'Server Connection Error';

  @override
  String get error => 'Error';

  @override
  String get ok => 'ok';

  @override
  String get serverNotConfigured => 'Server Not Configured';

  @override
  String get loading => 'loading';

  @override
  String get selectImage => 'Select Image';

  @override
  String get ocrSuccessful => 'OCR successful, form filled automatically';

  @override
  String get ocrNoDataFound => 'No data could be recognized';

  @override
  String get ocrError => 'OCR recognition error';

  @override
  String get processingOcr => 'Processing text...';

  @override
  String get scanAndFill => 'Scan and Fill';

  @override
  String get scanToFill => 'Scan to auto-fill';

  @override
  String get scanText => 'Recognize medical certificate text';

  @override
  String get ocrProcessing => 'Text recognition in progress';

  @override
  String get uploadAndScan => 'Upload & Scan';

  @override
  String get selectOrTakePhoto => 'Select or Take Photo';

  @override
  String get scannerError => 'Scanner Error';

  @override
  String get cameraPermissionDenied => 'Camera permission is required to scan documents';

  @override
  String get calendarEventList => 'Event List';

  @override
  String get calendarSortEvents => 'Sort Events';

  @override
  String get calendarSortDateAsc => 'Date (Ascending)';

  @override
  String get calendarSortDateDesc => 'Date (Descending)';

  @override
  String get calendarSortTitleAsc => 'Title (A-Z)';

  @override
  String get calendarSortTitleDesc => 'Title (Z-A)';

  @override
  String get calendarNoEvents => 'No Appointments';

  @override
  String calendarEventMinutesBefore(String minutes) {
    return '$minutes minutes before';
  }

  @override
  String get settingsDemoModeEnable => 'Enable Demo Mode (bypass AI)';

  @override
  String get settingsDemoModeInfo => 'Demo Mode Information';

  @override
  String get settingsDemoModeTitle => 'About Demo Mode';

  @override
  String get settingsDemoModeDescription => 'Demo mode bypasses the AI model and provides predefined answers.\n\nThis is useful for:\n• Offline app demonstrations\n• Testing chat interface\n• Feature showcasing without server connection\n\nCurrently supported keywords: headache, fever, cough, cold/flu\nOther inputs will receive a default response.';

  @override
  String get buttonGotIt => 'Got it';

  @override
  String get authPrompt => 'Please authenticate to unlock the app';

  @override
  String get authFailed => 'Authentication failed, please try again';

  @override
  String get authRetry => 'Retry';

  @override
  String get authExit => 'Exit';

  @override
  String get authInProgress => 'Please complete the biometric authentication';

  @override
  String get pinEmpty => 'Please enter a PIN';

  @override
  String get pinIncorrect => 'Incorrect PIN';

  @override
  String get pinCode => 'PIN Code';

  @override
  String get login => 'Login';

  @override
  String get usePin => 'Use PIN';

  @override
  String get editVaccineTitle => 'Edit Vaccination Record';

  @override
  String get edit => 'Edit';

  @override
  String get recordUpdated => 'Edit Record';

  @override
  String get editMedicalCertificate => 'Edit Medical Certificate';

  @override
  String get view => 'View';

  @override
  String get calendarSearchEvents => 'Search Events';

  @override
  String get calendarEventEdit => 'Edit Event';

  @override
  String get medintroTitle1 => 'Welcome to Medical Certificate';

  @override
  String get medintroTitle2 => 'press the upload photo button';

  @override
  String get medintroTitle3 => 'take or pick photo to upload';

  @override
  String get medintroTitle4 => 'press the save button';

  @override
  String get medintroTitle5 => 'View, Edit and change records';

  @override
  String get medintroBody1 => 'Your personal health management assistant, \nyou can Click the add medical certificate button \nto add a new medical certificate';

  @override
  String get medintroBody2 => 'You can press the upload \nphoto button to upload a \nphoto of your medical certificate';

  @override
  String get medintroBody3 => 'You can take your follow-up paper \nor pick a photo from your gallery \nto upload a medical certificate';

  @override
  String get medintroBody4 => 'After upload the photo \n you can check the information \n and press the save button \n to save the medical certificate';

  @override
  String get medintroBody5 => 'when the upload is done \n you can view the record \n or the record update or wrong \n you edit or delete the old record';

  @override
  String get next => 'next';

  @override
  String get skip => 'Skip';

  @override
  String get finish => 'finish';

  @override
  String get previous => 'previous';

  @override
  String get guideWelcomeTitle => 'Welcome to Dr.AI';

  @override
  String get guideWelcomeDescription => 'Your Smart Medical Assistant';

  @override
  String get guideMedicalConsultation => 'Smart Medical Consultation';

  @override
  String get guideMedicalAssistantCapabilities => 'Dr.AI is your smart medical assistant, which can:\n• Provide 24-hour medical consultation\n• Answer health-related questions\n• Offer preliminary medical advice\n\nNote: AI suggestions are for reference only, please consult professional physicians for important medical decisions.';

  @override
  String get viewIntroduction => 'View Introduction';

  @override
  String get guidecalendarTitle1 => 'Introdution Calendar';

  @override
  String get guidecalendarBody1 => 'User can see the reminder';

  @override
  String get guidecalendarTitle2 => 'Introdution reminder listview';

  @override
  String get guidecalendarBody2 => 'Check the reminder listview';

  @override
  String get guidecalendarTitle3 => 'Create or motify the reminder';

  @override
  String get guidecalendarBody3 => 'User can input event select date and time';
}
