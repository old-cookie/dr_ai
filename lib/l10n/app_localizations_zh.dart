// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Dr.AI';

  @override
  String get optionNewChat => '新建聊天';

  @override
  String get optionSettings => '設定';

  @override
  String get optionInstallPwa => '安裝 Webapp';

  @override
  String get optionNoChatFound => '暫無聊天消息';

  @override
  String get tipPrefix => '提示： ';

  @override
  String get tip0 => '長按編輯消息';

  @override
  String get tip1 => '雙擊刪除消息';

  @override
  String get tip2 => '您可以在設定中更改主題';

  @override
  String get tip3 => '選擇一個多模態模型來輸入圖像';

  @override
  String get tip4 => '聊天記錄會自動保存';

  @override
  String get deleteChat => '刪除';

  @override
  String get renameChat => '重命名';

  @override
  String get takeImage => '拍攝圖像';

  @override
  String get uploadImage => '上傳圖片';

  @override
  String get notAValidImage => '不是一個有效的圖片文件.';

  @override
  String get imageOnlyConversation => '僅圖片對話';

  @override
  String get messageInputPlaceholder => '消息';

  @override
  String get tooltipAttachment => '添加附件';

  @override
  String get tooltipSend => '發送';

  @override
  String get tooltipSave => '保存';

  @override
  String get tooltipLetAIThink => '讓AI思考';

  @override
  String get tooltipAddHostHeaders => '設定主機請求頭';

  @override
  String get tooltipReset => '重置當前聊天';

  @override
  String get tooltipOptions => '顯示選項';

  @override
  String get noModelSelected => '未選擇模型';

  @override
  String get noHostSelected => '沒有填寫主機地址，請打開設定以進行設定';

  @override
  String get noSelectedModel => '<模型選擇>';

  @override
  String get newChatTitle => '未命名的聊天';

  @override
  String get modelDialogAddModel => '添加';

  @override
  String get modelDialogAddPromptTitle => '添加新模型';

  @override
  String get modelDialogAddPromptDescription => '可以是一個普通名稱(如：\'llama3\')，也可以是名稱加標籤(如：\'llama3:70b\')。';

  @override
  String get modelDialogAddPromptAlreadyExists => '模型已存在';

  @override
  String get modelDialogAddPromptInvalid => '無效的模型名稱';

  @override
  String get modelDialogAddAllowanceTitle => '允許代理伺服器';

  @override
  String get modelDialogAddAllowanceDescription => 'Dr.AI必須檢查輸入的模型是否有效。為此，我們通常向Ollama模型列表發送一個網絡請求並檢查狀態。由於您正在使用 Web 客戶端，我們不能直接做到這一點。因此，應用將把請求發送到另一個由 JHubi 1 部署的api 上進行檢查。\n這是一個一次性請求，只有當您添加一個新模型時才會發送。\n您的IP地址將與請求一起發送，可能會被存儲長達10分鐘，以防止潛在的有害故障。\n如果您接受，您的選擇將在將來被記住；如果不接受，將不會發送任何內容，也不會添加模型。';

  @override
  String get modelDialogAddAllowanceAllow => '允許';

  @override
  String get modelDialogAddAllowanceDeny => '拒絕';

  @override
  String modelDialogAddAssuranceTitle(String model) {
    return '添加$model?';
  }

  @override
  String modelDialogAddAssuranceDescription(String model) {
    return '按下“添加”將直接從 Ollama 伺服器下載模型“$model”到您的主機。\n這可能需要一些時間，取決於您的網路連接。該操作不能被取消。\n如果在下載過程中關閉應用，當您再次在模型對話框中輸入名稱，它將恢復之前的下載。';
  }

  @override
  String get modelDialogAddAssuranceAdd => '添加';

  @override
  String get modelDialogAddAssuranceCancel => '取消';

  @override
  String get modelDialogAddDownloadPercentLoading => '加載進度';

  @override
  String modelDialogAddDownloadPercent(String percent) {
    return '已下載 $percent%';
  }

  @override
  String get modelDialogAddDownloadFailed => '連接斷開，請重試';

  @override
  String get modelDialogAddDownloadSuccess => '下載成功';

  @override
  String get deleteDialogTitle => '刪除聊天';

  @override
  String get deleteDialogDescription => '您確定要繼續嗎？這將刪除此聊天的所有記錄，且無法撤銷。\n要禁用此對話框，請訪問設定。';

  @override
  String get deleteDialogDelete => '刪除';

  @override
  String get deleteDialogCancel => '取消';

  @override
  String get dialogEnterNewTitle => '輸入新標題';

  @override
  String get dialogEditMessageTitle => '編輯消息';

  @override
  String get settingsTitleBehavior => '行為';

  @override
  String get settingsDescriptionBehavior => '根據您的喜好修改AI的行為';

  @override
  String get settingsTitleInterface => '介面';

  @override
  String get settingsDescriptionInterface => '修改 Dr.AI的外觀和行為';

  @override
  String get settingsTitleVoice => '語音';

  @override
  String get settingsDescriptionVoice => '啟用語音模式並進行設定。';

  @override
  String get settingsTitleExport => '匯出';

  @override
  String get settingsDescriptionExport => '匯出和匯入您的聊天記錄。';

  @override
  String get settingsTitleAbout => '關於';

  @override
  String get settingsDescriptionAbout => '檢查更新並了解更多關於Dr.AI的信息。';

  @override
  String get settingsSavedAutomatically => '設定已自動保存';

  @override
  String get settingsExperimentalAlpha => 'alpha';

  @override
  String get settingsExperimentalAlphaDescription => '此功能處於 Alpha 測試階段，可能無法按預期運行。\n無法排除會對設備、服務造成嚴重問題或永久性重大損害。\n使用需自行承擔風險。應用作者不承擔任何責任。';

  @override
  String get settingsExperimentalAlphaFeature => 'Alpha功能，按住以瞭解更多';

  @override
  String get settingsExperimentalBeta => 'beta';

  @override
  String get settingsExperimentalBetaDescription => '此功能處於 Beta 測試階段，可能無法按預期運行。\n可能會出現較輕微的問題，損害預期不嚴重。\n使用需自行承擔風險。';

  @override
  String get settingsExperimentalBetaFeature => 'Beta測試版功能，按住以瞭解更多';

  @override
  String get settingsExperimentalDeprecated => '已棄用';

  @override
  String get settingsExperimentalDeprecatedDescription => '此功能已被棄用，並將在未來的版本中刪除。\n它可能無法像預期的那樣工作。請自行承擔風險。';

  @override
  String get settingsExperimentalDeprecatedFeature => '已棄用的功能，按住以瞭解更多';

  @override
  String get settingsHost => '主機地址';

  @override
  String get settingsHostValid => '有效主機地址';

  @override
  String get settingsHostChecking => '正在檢查主機地址';

  @override
  String settingsHostInvalid(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'url': '無效的URL',
        'host': '無效的主機地址',
        'timeout': '請求失敗。伺服器問題',
        'other': '請求失敗',
      },
    );
    return '問題：$_temp0';
  }

  @override
  String get settingsHostHeaderTitle => '設定主機請求頭';

  @override
  String get settingsHostHeaderInvalid => '輸入的文本不是有效的標題 JSON 對象';

  @override
  String settingsHostInvalidDetailed(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'url': '您輸入的 URL 無效。它不是一個標準的 URL 格式。',
        'other': '您輸入的主機地址無效。無法連接。請檢查主機地址並再試一次',
      },
    );
    return '$_temp0';
  }

  @override
  String get settingsSystemMessage => '系統信息';

  @override
  String get settingsUseSystem => '使用系統信息';

  @override
  String get settingsUseSystemDescription => '使用模型內嵌代替系統級別的消息。對於具有模型描述文件的模型可能會有用。';

  @override
  String get settingsDisableMarkdown => '禁用Markdown';

  @override
  String get settingsBehaviorNotUpdatedForOlderChats => '行為設定未針對舊聊天進行更新';

  @override
  String get settingsShowModelTags => '顯示模型標籤';

  @override
  String get settingsPreloadModels => '預加載模型';

  @override
  String get settingsResetOnModelChange => '模型更改時重置';

  @override
  String get settingsRequestTypeStream => '流式';

  @override
  String get settingsRequestTypeRequest => '請求';

  @override
  String get settingsGenerateTitles => '生成標題';

  @override
  String get settingsEnableEditing => '啟用消息編輯';

  @override
  String get settingsAskBeforeDelete => '刪除聊天前確認';

  @override
  String get settingsShowTips => '在側邊欄顯示提示';

  @override
  String get settingsKeepModelLoadedAlways => '始終保持模型加載';

  @override
  String get settingsKeepModelLoadedNever => '不保持模型加載';

  @override
  String get settingsKeepModelLoadedFor => '設定模型加載的時間';

  @override
  String settingsKeepModelLoadedSet(String minutes) {
    return '保持模型加載 $minutes 分鐘';
  }

  @override
  String get settingsTimeoutMultiplier => '超時時間倍數';

  @override
  String get settingsTimeoutMultiplierDescription => '選擇應用程式中每個超時時間的倍數。適用於較慢的網路連接或遠程主機。';

  @override
  String get settingsTimeoutMultiplierExample => '例如：消息超時：';

  @override
  String get settingsEnableHapticFeedback => '啟用觸覺反饋';

  @override
  String get settingsMaximizeOnStart => '最大化';

  @override
  String get settingsBrightnessSystem => '系統';

  @override
  String get settingsBrightnessLight => '明亮';

  @override
  String get settingsBrightnessDark => '黑暗';

  @override
  String get settingsThemeDevice => '設備主題';

  @override
  String get settingsThemeOllama => 'Dr.AI主題';

  @override
  String get settingsTemporaryFixes => '臨時介面修復';

  @override
  String get settingsTemporaryFixesDescription => '啟用介面問題的臨時修復。\n長按選項以瞭解更多信息。';

  @override
  String get settingsTemporaryFixesInstructions => '不要切換這些設定，除非你知道自己在做什麼！描述的行為可能不會按照預期工作。\n它們不能被視為最終結果。可能會導致一些問題。';

  @override
  String get settingsTemporaryFixesNoFixes => '沒有可用的修復';

  @override
  String get settingsVoicePermissionLoading => '加載語音許可...';

  @override
  String get settingsVoiceTtsNotSupported => '不支持文字轉語音';

  @override
  String get settingsVoiceTtsNotSupportedDescription => '所選的語言不支持文字轉語音服務，您可能需要選擇其他語言以啟用該功能。\n語音識別和 AI 等其他服務仍可正常工作，但互動可能無法流暢運行。';

  @override
  String get settingsVoicePermissionNot => '未授予許可';

  @override
  String get settingsVoiceNotEnabled => '語音模式未啟用';

  @override
  String get settingsVoiceNotSupported => '不支持語音模式';

  @override
  String get settingsVoiceEnable => '啟用語音模式';

  @override
  String get settingsVoiceNoLanguage => '未選擇語言';

  @override
  String get settingsVoiceLimitLanguage => '限制為所選語言';

  @override
  String get settingsVoicePunctuation => '啟用AI標點';

  @override
  String get settingsExportChats => '匯出聊天記錄';

  @override
  String get settingsExportChatsSuccess => '聊天記錄匯出成功';

  @override
  String get settingsImportChats => '匯入聊天記錄';

  @override
  String get settingsImportChatsTitle => '匯入';

  @override
  String get settingsImportChatsDescription => '以下步驟將從所選文件匯入聊天記錄。這將覆蓋所有當前的聊天記錄。\n您要繼續嗎？';

  @override
  String get settingsImportChatsImport => '匯入並刪除';

  @override
  String get settingsImportChatsCancel => '取消';

  @override
  String get settingsImportChatsSuccess => '聊天記錄匯入成功';

  @override
  String get settingsExportInfo => '這個選項允許您匯出和匯入您的聊天記錄。如果您想將聊天記錄轉移到另一台設備或備份您的聊天記錄，這可能會很有用。';

  @override
  String get settingsExportWarning => '多個聊天記錄將不會合併！如果匯入新的聊天記錄，您將丟失當前的聊天記錄';

  @override
  String get settingsUpdateCheck => '檢查更新';

  @override
  String get settingsUpdateChecking => '檢查更新中...';

  @override
  String get settingsUpdateLatest => '當前為最新版本';

  @override
  String settingsUpdateAvailable(String version) {
    return '有可用更新 (v$version)';
  }

  @override
  String get settingsUpdateRateLimit => '無法檢查，API使用已超過速率限制';

  @override
  String get settingsUpdateIssue => '更新服務出錯';

  @override
  String get settingsUpdateDialogTitle => '有可用的新版本';

  @override
  String get settingsUpdateDialogDescription => 'Dr.AI有新版本可用。是否下載並安裝？';

  @override
  String get settingsUpdateChangeLog => '更新日誌';

  @override
  String get settingsUpdateDialogUpdate => '更新';

  @override
  String get settingsUpdateDialogCancel => '取消';

  @override
  String get settingsCheckForUpdates => '啟動時檢查更新';

  @override
  String get settingsGithub => 'GitHub';

  @override
  String get settingsReportIssue => '問題反饋';

  @override
  String get settingsLicenses => '開源許可證';

  @override
  String get optionVaccine => '疫苗記錄';

  @override
  String get optionBMI => 'BMI 計算器';

  @override
  String get optionCalendar => '看診日曆';

  @override
  String settingsVersion(String version) {
    return 'Dr.AI v$version';
  }

  @override
  String get vaccineRecordTitle => '疫苗記錄';

  @override
  String get calendarTitle => '看診預約';

  @override
  String get vaccineDetailTitle => '疫苗詳細資料';

  @override
  String get vaccineAddTitle => '新增疫苗記錄';

  @override
  String get vaccineName => '疫苗名稱';

  @override
  String get vaccineDose => '劑次';

  @override
  String get vaccineDate => '接種日期';

  @override
  String get vaccinePlace => '接種地點（選填）';

  @override
  String get vaccineRemark => '備註（選填）';

  @override
  String get vaccinePhoto => '疫苗接種記錄照片（選填）';

  @override
  String get pickImage => '選擇照片';

  @override
  String get saveRecord => '儲存';

  @override
  String get deleteRecord => '刪除記錄';

  @override
  String get deleteConfirm => '確定要刪除這筆記錄嗎？';

  @override
  String get cancel => '取消';

  @override
  String get delete => '刪除';

  @override
  String get imageFormat => '僅支援 PNG 或 JPG 圖片格式';

  @override
  String get cropImage => '裁剪圖片';

  @override
  String get saveImage => '儲存圖片';

  @override
  String get errorLoadingRecords => '載入記錄時發生錯誤';

  @override
  String get noRecordsFound => '目前沒有疫苗接種記錄';

  @override
  String get notSelected => '未選擇';

  @override
  String vaccineFieldDate(String date) {
    return '日期：$date';
  }

  @override
  String vaccineFieldDose(String dose) {
    return '劑次：$dose';
  }

  @override
  String vaccineFieldPlace(String place) {
    return '地點：$place';
  }

  @override
  String vaccineFieldRemarks(String remarks) {
    return '備註：$remarks';
  }

  @override
  String get calendarEventTitle => '新增預約';

  @override
  String get calendarEventDate => '預約日期';

  @override
  String get calendarEventTime => '預約時間';

  @override
  String get calendarEventNotification => '提前通知';

  @override
  String get calendarEventSave => '儲存預約';

  @override
  String get calendarEventDelete => '刪除預約';

  @override
  String get calendarEventNoEvents => '這一天沒有預約事件';

  @override
  String get calendarEventAdd => '新增預約';

  @override
  String get calendarReminderTitle => '預約提醒';

  @override
  String calendarReminderBody(String eventTitle) {
    return '您有一個預約「$eventTitle」即將開始';
  }

  @override
  String calendarDeleteEvent(String eventTitle) {
    return '已刪除事件：$eventTitle';
  }

  @override
  String get calendarDeleteEventUndo => '復原';

  @override
  String get bmiCalculator => 'BMI 計算器';

  @override
  String get bmiHeight => '身高 (公分)';

  @override
  String get bmiWeight => '體重 (公斤)';

  @override
  String get bmiAge => '年齡';

  @override
  String get bmiGender => '性別';

  @override
  String get bmiMale => '男性';

  @override
  String get bmiFemale => '女性';

  @override
  String get bmiStandard => 'BMI 標準';

  @override
  String get bmiAsian => '亞洲標準';

  @override
  String get bmiWHO => 'WHO 標準';

  @override
  String get bmiCalculate => '計算 BMI';

  @override
  String bmiResult(String value) {
    return 'BMI 指數：$value';
  }

  @override
  String get bmiStandardTitle => 'BMI 分類標準';

  @override
  String get bmiChildStandardTitle => '兒童/青少年 BMI 標準';

  @override
  String get bmiAsianStandardTitle => '亞洲成人 BMI 標準';

  @override
  String get bmiWHOStandardTitle => 'WHO 成人 BMI 標準';

  @override
  String get bmiValidationEnterHeight => '請輸入身高';

  @override
  String get bmiValidationInvalidHeight => '請輸入有效的身高數值';

  @override
  String get bmiValidationEnterWeight => '請輸入體重';

  @override
  String get bmiValidationInvalidWeight => '請輸入有效的體重數值';

  @override
  String get bmiValidationEnterAge => '請輸入年齡';

  @override
  String get bmiValidationInvalidAge => '請輸入有效年齡';

  @override
  String get bmiClassificationTitle => 'BMI 分類標準：';

  @override
  String get bmiChildStandard => '兒童/青少年 BMI 標準:';

  @override
  String get bmiChildSeverelyWasted => '• 嚴重消瘦 (Severely wasted)';

  @override
  String get bmiChildWasted => '• 消瘦 (Wasted)';

  @override
  String get bmiChildNormal => '• 正常體重 (Normal weight)';

  @override
  String get bmiChildRiskOverweight => '• 可能過重風險 (Risk of overweight)';

  @override
  String get bmiChildOverweight => '• 過重 (Overweight)';

  @override
  String get bmiChildObese => '• 肥胖 (Obese)';

  @override
  String get bmiAsianAdultStandard => '亞洲成人 BMI 標準:';

  @override
  String get bmiAsianUnderweight => '• 體重過輕：BMI < 18.5';

  @override
  String get bmiAsianNormal => '• 體重正常：18.5 ≤ BMI < 23';

  @override
  String get bmiAsianOverweight => '• 體重過重：23 ≤ BMI < 25';

  @override
  String get bmiAsianObese => '• 肥胖：BMI ≥ 25';

  @override
  String get bmiWHOAdultStandard => 'WHO成人 BMI 標準:';

  @override
  String get bmiWHOUnderweight => '• 體重過輕：BMI < 18.5';

  @override
  String get bmiWHONormal => '• 體重正常：18.5 ≤ BMI < 25';

  @override
  String get bmiWHOOverweight => '• 體重過重：25 ≤ BMI < 30';

  @override
  String get bmiWHOObese => '• 肥胖：BMI ≥ 30';

  @override
  String get bmiSeverelyWasted => '嚴重消瘦';

  @override
  String get bmiUnderweight => '體重過輕';

  @override
  String get bmiWasted => '消瘦';

  @override
  String get bmiNormal => '體重正常';

  @override
  String get bmiNormalWeight => '體重正常';

  @override
  String get bmiPossibleRiskOverweight => '可能過重風險';

  @override
  String get bmiOverweight => '體重過重';

  @override
  String get dialogSelectModel => '選擇模型';

  @override
  String get bmiObese => '肥胖';

  @override
  String get addMedicalCertificate => '新增醫療證明';

  @override
  String get certificateNumber => '證明編號';

  @override
  String get hospital => '醫院';

  @override
  String get selectHospital => '選擇醫院';

  @override
  String get treatmentDate => '治療日期';

  @override
  String get hospitalizationPeriod => '住院期間';

  @override
  String get sickLeavePeriod => '病假期間';

  @override
  String get followUpDate => '複診日期';

  @override
  String get remarks => '備註';

  @override
  String get certificateImage => '證明圖片';

  @override
  String get save => '儲存';

  @override
  String get selectDate => '選擇日期';

  @override
  String get changeImage => '更換圖片';

  @override
  String get medicalCertificates => '醫療證明';

  @override
  String get viewCertificate => '查看證明';

  @override
  String get noCertificatesFound => '未找到證明';

  @override
  String get recordSaved => '記錄已儲存';

  @override
  String get pleaseEnterCertificateNumber => '請輸入證明編號';

  @override
  String get pleaseSelectTreatmentDate => '請選擇治療日期';

  @override
  String get hospitalizationStartDate => '住院開始日期';

  @override
  String get hospitalizationEndDate => '住院結束日期';

  @override
  String get sickLeaveStartDate => '病假開始日期';

  @override
  String get sickLeaveEndDate => '病假結束日期';

  @override
  String get optionMedicalCertificate => '醫療證明';

  @override
  String get searchHospital => '搜尋醫院';

  @override
  String get serverConnectionError => '伺服器連接錯誤';

  @override
  String get error => '錯誤';

  @override
  String get ok => '確定';

  @override
  String get serverNotConfigured => '伺服器未配置';

  @override
  String get loading => '加載中';

  @override
  String get selectImage => '選擇圖片';

  @override
  String get ocrSuccessful => 'OCR辨識成功，已自動填入資料';

  @override
  String get ocrNoDataFound => '未能識別任何資料';

  @override
  String get ocrError => 'OCR辨識發生錯誤';

  @override
  String get processingOcr => '正在辨識文字...';

  @override
  String get scanAndFill => '掃描並填充資料';

  @override
  String get scanToFill => '掃描以自動填充';

  @override
  String get scanText => '辨識醫療證明書文字';

  @override
  String get ocrProcessing => '文字辨識中';

  @override
  String get uploadAndScan => '上傳並辨識';

  @override
  String get selectOrTakePhoto => '選擇或拍攝照片';

  @override
  String get scannerError => '掃描器錯誤';

  @override
  String get cameraPermissionDenied => '相機權限被拒絕';

  @override
  String get calendarEventList => '事件列表';

  @override
  String get calendarSortEvents => '排序事件';

  @override
  String get calendarSortDateAsc => '日期 (升序)';

  @override
  String get calendarSortDateDesc => '日期 (降序)';

  @override
  String get calendarSortTitleAsc => '標題 (A-Z)';

  @override
  String get calendarSortTitleDesc => '標題 (Z-A)';

  @override
  String get calendarNoEvents => '無預約事件';

  @override
  String calendarEventMinutesBefore(String minutes) {
    return '提前 $minutes 分鐘';
  }

  @override
  String get settingsDemoModeEnable => '啟用演示模式（繞過 AI）';

  @override
  String get settingsDemoModeInfo => '演示模式說明';

  @override
  String get settingsDemoModeTitle => '關於演示模式';

  @override
  String get settingsDemoModeDescription => '演示模式會繞過 AI 模型，直接提供預定義的回答。\n\n這對於以下情況很有用：\n• 離線演示應用\n• 測試聊天界面\n• 在無法連接服務器時進行功能展示\n\n目前支持的關鍵詞：頭痛、發燒、咳嗽、感冒/流感\n其他輸入將收到默認回覆。';

  @override
  String get buttonGotIt => '了解了';

  @override
  String get authPrompt => '請進行生物識別驗證以解鎖應用';

  @override
  String get authFailed => '驗證失敗，請重試';

  @override
  String get authRetry => '重試';

  @override
  String get authExit => '退出';

  @override
  String get authInProgress => '請完成生物識別驗證';

  @override
  String get pinEmpty => '請輸入PIN碼';

  @override
  String get pinIncorrect => 'PIN碼不正確';

  @override
  String get pinCode => 'PIN碼';

  @override
  String get login => '登錄';

  @override
  String get usePin => '使用PIN碼';

  @override
  String get editVaccineTitle => '編輯疫苗記錄';

  @override
  String get edit => '編輯';

  @override
  String get recordUpdated => '記錄已更新';

  @override
  String get editMedicalCertificate => '編輯醫療證明';

  @override
  String get view => '查看';

  @override
  String get calendarSearchEvents => '搜尋事件';

  @override
  String get calendarEventEdit => '編輯事件';

  @override
  String get medintroTitle1 => '歡迎使用醫療證明功能';

  @override
  String get medintroTitle2 => '請按下上傳並辨識';

  @override
  String get medintroTitle3 => '選擇圖片或拍攝照片';

  @override
  String get medintroTitle4 => '請按下儲存';

  @override
  String get medintroTitle5 => '請按下查看證明或編輯證明';

  @override
  String get medintroBody1 => '按下新增醫療證明，並進入新增醫療證明頁面。';

  @override
  String get medintroBody2 => '按下上傳並辨識，然後選擇你所需的選項，在圖片庫中選擇圖片或拍攝照片。';

  @override
  String get medintroBody3 => '選擇圖片或拍攝照片，然後等待系統辨識圖片中的文字。';

  @override
  String get medintroBody4 => '辨識完成後，檢查相關資料無誤後，按下儲存，然後返回醫療證明頁面。';

  @override
  String get medintroBody5 => '按下查看證明或編輯證明，完成後可返回醫療證明頁面。';

  @override
  String get next => '下一頁';

  @override
  String get skip => '跳過';

  @override
  String get finish => '完成';

  @override
  String get previous => '上一步';

  @override
  String get guideWelcomeTitle => '歡迎使用 Dr.AI';

  @override
  String get guideWelcomeDescription => '您的智慧醫療助手';

  @override
  String get guideMedicalConsultation => '智慧醫療諮詢';

  @override
  String get guideMedicalAssistantCapabilities => 'Dr.AI 是您的智慧醫療助手，可以：\n• 24小時提供醫療諮詢\n• 解答健康相關問題\n• 提供初步醫療建議\n\n請注意：AI 建議僅供參考，重要醫療決定請諮詢專業醫師。';

  @override
  String get viewIntroduction => '查看介紹';
}
