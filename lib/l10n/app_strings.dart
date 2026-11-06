import 'package:flutter/material.dart';

import '../app_state.dart';

class AppStrings {
  AppStrings._(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml'),
    Locale('hi'),
    Locale('ta'),
    Locale('kn'),
  ];

  static AppStrings of(BuildContext context) {
    final appState = FloraMindAppScope.maybeOf(context);
    final effectiveLocale = appState?.locale ?? Localizations.localeOf(context);
    return AppStrings._(effectiveLocale);
  }

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'appTitle': 'FloraMind AI',
      'settings': 'Settings',
      'customizeExperience': 'Customize your FloraMind AI experience.',
      'appearance': 'Appearance',
      'appearanceSubtitle':
          'Choose how FloraMind AI should look on your device.',
      'lightTheme': 'Light Theme',
      'darkTheme': 'Dark Theme',
      'systemTheme': 'System Theme',
      'language': 'Language',
      'languageSubtitle':
          'Select the language used throughout the app interface.',
      'appLanguage': 'App Language',
      'languageEnglish': 'English',
      'languageMalayalam': 'Malayalam',
      'languageHindi': 'Hindi',
      'languageTamil': 'Tamil',
      'languageKannada': 'Kannada',
      'notificationSettings': 'Notification Settings',
      'notificationSubtitle':
          'Local toggles for the alerts you want to see on your device.',
      'gardenPreferences': 'Garden Preferences',
      'gardenPreferencesSubtitle':
          'Fine-tune your preferred garden style and plant categories.',
      'preferredGardenType': 'Preferred Garden Type',
      'preferredGardenTypeSubtitle': 'Choose the main garden style you prefer.',
      'preferredPlantCategory': 'Preferred Plant Category',
      'preferredPlantCategorySubtitle':
          'Choose the category of plants you want to focus on.',
      'iotSettings': 'IoT Settings',
      'iotSettingsSubtitle':
          'Frontend placeholders for the future ESP32, Flask, and database connection status.',
      'futureConnectDevice': 'Future Connect Device',
      'security': 'Security',
      'securitySubtitle':
          'Security and account actions are available as frontend placeholders.',
      'backupRestore': 'Backup & Restore',
      'backupRestoreSubtitle':
          'Export and import options for future user preference management.',
      'aboutApplication': 'About Application',
      'aboutApplicationSubtitle':
          'Basic app information shown here for quick reference.',
      'changePassword': 'Change Password',
      'privacyPolicy': 'Privacy Policy',
      'termsConditions': 'Terms & Conditions',
      'deleteAccount': 'Delete Account',
      'applicationName': 'Application Name',
      'version': 'Version',
      'developer': 'Developer',
      'project': 'Project',
      'goodMorning': 'Good Morning',
      'guestUser': 'Guest User',
      'exploreFeatures': 'Explore Features',
      'featuresSubtitle': 'Premium tools for modern garden care.',
      'home': 'Home',
      'notifications': 'Notifications',
      'profile': 'Profile',
      'helpSupport': 'Help & Support',
    },
    'ml': {
      'appTitle': 'ಫ್ಲೋರಾಮೈಂಡ್ AI',
      'settings': 'ಸೆಟ್ಟಿಂಗ್ಗಳು',
      'customizeExperience': 'ನಿಮ್ಮ FloraMind AI ಅನುಭವವನ್ನು ಕಸ್ಟಮೈಸ್ ಮಾಡಿ.',
      'appearance': 'ದೃಶ್ಯ ರೂಪ',
      'appearanceSubtitle':
          'ನಿಮ್ಮ ಸಾಧನದಲ್ಲಿ FloraMind AI ಹೇಗಿರಬೇಕು ಎಂದು ಆರಿಸಿ.',
      'lightTheme': 'ಲೈಟ್ ಥೀಮ್',
      'darkTheme': 'ಡಾರ್ಕ್ ಥೀಮ್',
      'systemTheme': 'ಸಿಸ್ಟಮ್ ಥೀಮ್',
      'language': 'ಭಾಷೆ',
      'languageSubtitle': 'ಅ್ಯಪ್ ಇಂಟರ್ಫೇಸ್‌ನಲ್ಲಿ ಬಳಸುವ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ.',
      'appLanguage': 'ಅ್ಯಪ್ ಭಾಷೆ',
      'languageEnglish': 'ಇಂಗ್ಲಿಷ್',
      'languageMalayalam': 'ಮಲಯಾಳಂ',
      'languageHindi': 'ಹಿಂದಿ',
      'languageTamil': 'ತಮಿಳು',
      'languageKannada': 'ಕನ್ನಡ',
      'notificationSettings': 'ಅಧಿಸೂಚನೆ ಸೆಟ್ಟಿಂಗ್ಗಳು',
      'notificationSubtitle':
          'ನಿಮ್ಮ ಸಾಧನದಲ್ಲಿ ಕಾಣಬೇಕಾದ ಎಚ್ಚರಿಕೆಗಳ ಸ್ಥಳೀಯ ಟಾಗಲ್‌ಗಳು.',
      'gardenPreferences': 'ತೋಟದ ಆದ್ಯತೆಗಳು',
      'gardenPreferencesSubtitle':
          'ನಿಮ್ಮ ಇಷ್ಟದ ತೋಟ ಶೈಲಿ ಮತ್ತು ಸಸ್ಯ ವರ್ಗಗಳನ್ನು ಸೂಕ್ಷ್ಮವಾಗಿ ಹೊಂದಿಸಿ.',
      'preferredGardenType': 'ಆದ್ಯತೆಯ ತೋಟದ ವಿಧ',
      'preferredGardenTypeSubtitle': 'ನೀವು ಇಷ್ಟಪಡುವ ಮುಖ್ಯ ತೋಟ ಶೈಲಿಯನ್ನು ಆರಿಸಿ.',
      'preferredPlantCategory': 'ಆದ್ಯತೆಯ ಸಸ್ಯ ವರ್ಗ',
      'preferredPlantCategorySubtitle':
          'ನೀವು ಗಮನಹರಿಸಲು ಬಯಸುವ ಸಸ್ಯ ವರ್ಗವನ್ನು ಆರಿಸಿ.',
      'iotSettings': 'IoT ಸೆಟ್ಟಿಂಗ್ಗಳು',
      'iotSettingsSubtitle':
          'ಭವಿಷ್ಯದ ESP32, Flask ಮತ್ತು ಡೇಟಾಬೇಸ್ ಸಂಪರ್ಕ ಸ್ಥಿತಿಗಾಗಿ ಫ್ರಂಟ್‌ಎಂಡ್ ಪ್ಲೇಸ್‌ಹೋಲ್ಡರ್‌ಗಳು.',
      'futureConnectDevice': 'ಭವಿಷ್ಯದ ಸಾಧನ ಸಂಪರ್ಕ',
      'security': 'ಭದ್ರತೆ',
      'securitySubtitle':
          'ಭದ್ರತಾ ಮತ್ತು ಖಾತೆ ಕ್ರಮಗಳು ಫ್ರಂಟ್‌ಎಂಡ್ ಪ್ಲೇಸ್‌ಹೋಲ್ಡರ್‌ಗಳಾಗಿ ಲಭ್ಯವಿವೆ.',
      'backupRestore': 'ಬ್ಯಾಕಪ್ ಮತ್ತು ಪುನಃಸ್ಥಾಪನೆ',
      'backupRestoreSubtitle':
          'ಭವಿಷ್ಯದ ಬಳಕೆದಾರ ಆದ್ಯತೆ ನಿರ್ವಹಣೆಗೆ ರಫ್ತು ಮತ್ತು ಆಮದು ಆಯ್ಕೆಗಳು.',
      'aboutApplication': 'ಅ್ಯಪ್ ಬಗ್ಗೆ',
      'aboutApplicationSubtitle':
          'ತ್ವರಿತ ಉಲ್ಲೇಖಕ್ಕಾಗಿ ಮೂಲ ಅಪ್ಲಿಕೇಶನ್ ಮಾಹಿತಿ ಇಲ್ಲಿ ತೋರಿಸಲಾಗಿದೆ.',
      'changePassword': 'ಪಾಸ್ವರ್ಡ್ ಬದಲಿಸಿ',
      'privacyPolicy': 'ಗೌಪ್ಯತಾ ನೀತಿ',
      'termsConditions': 'ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳು',
      'deleteAccount': 'ಖಾತೆ ಅಳಿಸಿ',
      'applicationName': 'ಅಪ್ಲಿಕೇಶನ್ ಹೆಸರು',
      'version': 'ಆವೃತ್ತಿ',
      'developer': 'ಡೆವಲಪರ್',
      'project': 'ಪ್ರಾಜೆಕ್ಟ್',
      'goodMorning': 'ಶುಭೋದಯ',
      'guestUser': 'ಅತಿಥಿ ಬಳಕೆದಾರ',
      'exploreFeatures': 'ವೈಶಿಷ್ಟ್ಯಗಳನ್ನು ಅನ್ವೇಷಿಸಿ',
      'featuresSubtitle': 'ಆಧುನಿಕ ತೋಟಗಾರಿಕೆಯಿಗಾಗಿ ಪ್ರೀಮಿಯಂ ಸಾಧನಗಳು.',
      'home': 'ಮುಖಪುಟ',
      'notifications': 'ಅಧಿಸೂಚನೆಗಳು',
      'profile': 'ಪ್ರೊಫೈಲ್',
      'helpSupport': 'ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ',
    },
    'hi': {
      'appTitle': 'FloraMind AI',
      'settings': 'सेटिंग्स',
      'customizeExperience': 'अपने FloraMind AI अनुभव को अनुकूलित करें।',
      'appearance': 'रूप-रंग',
      'appearanceSubtitle': 'अपने डिवाइस पर FloraMind AI कैसा दिखे, यह चुनें।',
      'lightTheme': 'लाइट थीम',
      'darkTheme': 'डार्क थीम',
      'systemTheme': 'सिस्टम थीम',
      'language': 'भाषा',
      'languageSubtitle': 'ऐप इंटरफ़ेस में उपयोग की जाने वाली भाषा चुनें।',
      'appLanguage': 'ऐप भाषा',
      'languageEnglish': 'अंग्रेज़ी',
      'languageMalayalam': 'मलयालम',
      'languageHindi': 'हिंदी',
      'languageTamil': 'तमिल',
      'languageKannada': 'कन्नड़',
      'notificationSettings': 'सूचना सेटिंग्स',
      'notificationSubtitle':
          'आपके डिवाइस पर दिखने वाले अलर्ट के लिए स्थानीय टॉगल।',
      'gardenPreferences': 'बगीचे की प्राथमिकताएँ',
      'gardenPreferencesSubtitle':
          'अपनी पसंद के बगीचे के स्टाइल और पौधों की श्रेणियाँ तय करें।',
      'preferredGardenType': 'पसंदीदा बगीचे का प्रकार',
      'preferredGardenTypeSubtitle': 'अपनी पसंद की मुख्य बगीचे शैली चुनें।',
      'preferredPlantCategory': 'पसंदीदा पौधों की श्रेणी',
      'preferredPlantCategorySubtitle':
          'उस पौधों की श्रेणी का चयन करें जिस पर आप ध्यान देना चाहते हैं।',
      'iotSettings': 'IoT सेटिंग्स',
      'iotSettingsSubtitle':
          'भविष्य के ESP32, Flask और डेटाबेस कनेक्शन स्थिति के लिए फ़्रंटएंड प्लेसहोल्डर।',
      'futureConnectDevice': 'भविष्य में डिवाइस कनेक्ट करें',
      'security': 'सुरक्षा',
      'securitySubtitle':
          'सुरक्षा और खाता क्रियाएँ अभी फ़्रंटएंड प्लेसहोल्डर हैं।',
      'backupRestore': 'बैकअप और पुनर्स्थापना',
      'backupRestoreSubtitle':
          'भविष्य में उपयोगकर्ता प्राथमिकता प्रबंधन के लिए निर्यात और आयात विकल्प।',
      'aboutApplication': 'ऐप के बारे में',
      'aboutApplicationSubtitle': 'त्वरित संदर्भ के लिए बुनियादी ऐप जानकारी।',
      'changePassword': 'पासवर्ड बदलें',
      'privacyPolicy': 'गोपनीयता नीति',
      'termsConditions': 'नियम और शर्तें',
      'deleteAccount': 'खाता हटाएँ',
      'applicationName': 'एप्लिकेशन नाम',
      'version': 'संस्करण',
      'developer': 'डेवलपर',
      'project': 'प्रोजेक्ट',
      'goodMorning': 'सुप्रभात',
      'guestUser': 'अतिथि उपयोगकर्ता',
      'exploreFeatures': 'विशेषताओं को देखें',
      'featuresSubtitle': 'आधुनिक बागवानी देखभाल के लिए प्रीमियम टूल।',
      'home': 'होम',
      'notifications': 'सूचनाएँ',
      'profile': 'प्रोफ़ाइल',
      'helpSupport': 'सहायता और समर्थन',
    },
    'ta': {
      'appTitle': 'FloraMind AI',
      'settings': 'அமைப்புகள்',
      'customizeExperience':
          'உங்கள் FloraMind AI அனுபவத்தை தனிப்பயனாக்குங்கள்.',
      'appearance': 'தோற்றம்',
      'appearanceSubtitle':
          'உங்கள் சாதனத்தில் FloraMind AI எப்படி தோன்ற வேண்டும் என்பதை தேர்வு செய்யவும்.',
      'lightTheme': 'ஒளி தீம்',
      'darkTheme': 'இருள் தீம்',
      'systemTheme': 'கணினி தீம்',
      'language': 'மொழி',
      'languageSubtitle':
          'பயன்பாட்டு இடைமுகத்தில் பயன்படுத்தப்படும் மொழியைத் தேர்ந்தெடுக்கவும்.',
      'appLanguage': 'பயன்பாட்டு மொழி',
      'languageEnglish': 'ஆங்கிலம்',
      'languageMalayalam': 'மலையாளம்',
      'languageHindi': 'இந்தி',
      'languageTamil': 'தமிழ்',
      'languageKannada': 'கன்னடம்',
      'notificationSettings': 'அறிவிப்பு அமைப்புகள்',
      'notificationSubtitle':
          'உங்கள் சாதனத்தில் காண விரும்பும் எச்சரிக்கைகளுக்கான உள்ளூர் மாற்றுகள்.',
      'gardenPreferences': 'தோட்ட விருப்பங்கள்',
      'gardenPreferencesSubtitle':
          'உங்கள் விருப்பமான தோட்ட பாணி மற்றும் தாவர வகைகளை நுட்பமாக அமைக்கவும்.',
      'preferredGardenType': 'விருப்பமான தோட்ட வகை',
      'preferredGardenTypeSubtitle':
          'நீங்கள் விரும்பும் முதன்மை தோட்ட பாணியைத் தேர்ந்தெடுக்கவும்.',
      'preferredPlantCategory': 'விருப்பமான தாவர வகை',
      'preferredPlantCategorySubtitle':
          'நீங்கள் கவனம் செலுத்த விரும்பும் தாவர வகையைத் தேர்ந்தெடுக்கவும்.',
      'iotSettings': 'IoT அமைப்புகள்',
      'iotSettingsSubtitle':
          'எதிர்கால ESP32, Flask மற்றும் தரவுத்தள இணைப்பு நிலைக்கான முன்னணி இடமாற்றிகள்.',
      'futureConnectDevice': 'எதிர்கால சாதன இணைப்பு',
      'security': 'பாதுகாப்பு',
      'securitySubtitle':
          'பாதுகாப்பு மற்றும் கணக்கு செயல்கள் முன்னணி இடமாற்றிகளாக உள்ளன.',
      'backupRestore': 'காப்புப்பிரதி மற்றும் மீட்டமைப்பு',
      'backupRestoreSubtitle':
          'எதிர்கால பயனர் விருப்ப மேலாண்மைக்கான ஏற்றுமதி மற்றும் இறக்குமதி விருப்பங்கள்.',
      'aboutApplication': 'பயன்பாடு பற்றி',
      'aboutApplicationSubtitle':
          'விரைவு குறிப்புக்காக அடிப்படை பயன்பாட்டு தகவல் இங்கே காட்டப்பட்டுள்ளது.',
      'changePassword': 'கடவுச்சொல்லை மாற்று',
      'privacyPolicy': 'தனியுரிமைக் கொள்கை',
      'termsConditions': 'விதிமுறைகள் மற்றும் நிபந்தனைகள்',
      'deleteAccount': 'கணக்கை நீக்கு',
      'applicationName': 'பயன்பாட்டு பெயர்',
      'version': 'பதிப்பு',
      'developer': 'டெவலப்பர்',
      'project': 'திட்டம்',
      'goodMorning': 'காலை வணக்கம்',
      'guestUser': 'விருந்தினர் பயனர்',
      'exploreFeatures': 'அம்சங்களை ஆராயுங்கள்',
      'featuresSubtitle': 'நவீன தோட்ட பராமரிப்புக்கான பிரீமியம் கருவிகள்.',
      'home': 'முகப்பு',
      'notifications': 'அறிவிப்புகள்',
      'profile': 'சுயவிவரம்',
      'helpSupport': 'உதவி மற்றும் ஆதரவு',
    },
    'kn': {
      'appTitle': 'FloraMind AI',
      'settings': 'ಸೆಟ್ಟಿಂಗ್ಗಳು',
      'customizeExperience': 'ನಿಮ್ಮ FloraMind AI ಅನುಭವವನ್ನು ಕಸ್ಟಮೈಸ್ ಮಾಡಿ.',
      'appearance': 'ದೃಶ್ಯ ರೂಪ',
      'appearanceSubtitle':
          'ನಿಮ್ಮ ಸಾಧನದಲ್ಲಿ FloraMind AI ಹೇಗಿರಬೇಕು ಎಂದು ಆರಿಸಿ.',
      'lightTheme': 'ಲೈಟ್ ಥೀಮ್',
      'darkTheme': 'ಡಾರ್ಕ್ ಥೀಮ್',
      'systemTheme': 'ಸಿಸ್ಟಮ್ ಥೀಮ್',
      'language': 'ಭಾಷೆ',
      'languageSubtitle': 'ಅ್ಯಪ್ ಇಂಟರ್ಫೇಸ್‌ನಲ್ಲಿ ಬಳಸುವ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ.',
      'appLanguage': 'ಅ್ಯಪ್ ಭಾಷೆ',
      'languageEnglish': 'ಇಂಗ್ಲಿಷ್',
      'languageMalayalam': 'ಮಲಯಾಳಂ',
      'languageHindi': 'ಹಿಂದಿ',
      'languageTamil': 'ತಮಿಳು',
      'languageKannada': 'ಕನ್ನಡ',
      'notificationSettings': 'ಅಧಿಸೂಚನೆ ಸೆಟ್ಟಿಂಗ್ಗಳು',
      'notificationSubtitle':
          'ನಿಮ್ಮ ಸಾಧನದಲ್ಲಿ ಕಾಣಬೇಕಾದ ಎಚ್ಚರಿಕೆಗಳ ಸ್ಥಳೀಯ ಟಾಗಲ್‌ಗಳು.',
      'gardenPreferences': 'ತೋಟದ ಆದ್ಯತೆಗಳು',
      'gardenPreferencesSubtitle':
          'ನಿಮ್ಮ ಇಷ್ಟದ ತೋಟ ಶೈಲಿ ಮತ್ತು ಸಸ್ಯ ವರ್ಗಗಳನ್ನು ಸೂಕ್ಷ್ಮವಾಗಿ ಹೊಂದಿಸಿ.',
      'preferredGardenType': 'ಆದ್ಯತೆಯ ತೋಟದ ವಿಧ',
      'preferredGardenTypeSubtitle': 'ನೀವು ಇಷ್ಟಪಡುವ ಮುಖ್ಯ ತೋಟ ಶೈಲಿಯನ್ನು ಆರಿಸಿ.',
      'preferredPlantCategory': 'ಆದ್ಯತೆಯ ಸಸ್ಯ ವರ್ಗ',
      'preferredPlantCategorySubtitle':
          'ನೀವು ಗಮನಹರಿಸಲು ಬಯಸುವ ಸಸ್ಯ ವರ್ಗವನ್ನು ಆರಿಸಿ.',
      'iotSettings': 'IoT ಸೆಟ್ಟಿಂಗ್ಗಳು',
      'iotSettingsSubtitle':
          'ಭವಿಷ್ಯದ ESP32, Flask ಮತ್ತು ಡೇಟಾಬೇಸ್ ಸಂಪರ್ಕ ಸ್ಥಿತಿಗಾಗಿ ಫ್ರಂಟ್‌ಎಂಡ್ ಪ್ಲೇಸ್‌ಹೋಲ್ಡರ್‌ಗಳು.',
      'futureConnectDevice': 'ಭವಿಷ್ಯದ ಸಾಧನ ಸಂಪರ್ಕ',
      'security': 'ಭದ್ರತೆ',
      'securitySubtitle':
          'ಭದ್ರತಾ ಮತ್ತು ಖಾತೆ ಕ್ರಮಗಳು ಫ್ರಂಟ್‌ಎಂಡ್ ಪ್ಲೇಸ್‌ಹೋಲ್ಡರ್‌ಗಳಾಗಿ ಲಭ್ಯವಿವೆ.',
      'backupRestore': 'ಬ್ಯಾಕಪ್ ಮತ್ತು ಪುನಃಸ್ಥಾಪನೆ',
      'backupRestoreSubtitle':
          'ಭವಿಷ್ಯದ ಬಳಕೆದಾರ ಆದ್ಯತೆ ನಿರ್ವಹಣೆಗೆ ರಫ್ತು ಮತ್ತು ಆಮದು ಆಯ್ಕೆಗಳು.',
      'aboutApplication': 'ಅ್ಯಪ್ ಬಗ್ಗೆ',
      'aboutApplicationSubtitle':
          'ತ್ವರಿತ ಉಲ್ಲೇಖಕ್ಕಾಗಿ ಮೂಲ ಅಪ್ಲಿಕೇಶನ್ ಮಾಹಿತಿ ಇಲ್ಲಿ ತೋರಿಸಲಾಗಿದೆ.',
      'changePassword': 'ಪಾಸ್ವರ್ಡ್ ಬದಲಿಸಿ',
      'privacyPolicy': 'ಗೌಪ್ಯತಾ ನೀತಿ',
      'termsConditions': 'ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳು',
      'deleteAccount': 'ಖಾತೆ ಅಳಿಸಿ',
      'applicationName': 'ಅಪ್ಲಿಕೇಶನ್ ಹೆಸರು',
      'version': 'ಆವೃತ್ತಿ',
      'developer': 'ಡೆವಲಪರ್',
      'project': 'ಪ್ರಾಜೆಕ್ಟ್',
      'goodMorning': 'ಶುಭೋದಯ',
      'guestUser': 'ಅತಿಥಿ ಬಳಕೆದಾರ',
      'exploreFeatures': 'ವೈಶಿಷ್ಟ್ಯಗಳನ್ನು ಅನ್ವೇಷಿಸಿ',
      'featuresSubtitle': 'ಆಧುನಿಕ ತೋಟಗಾರಿಕೆಯಿಗಾಗಿ ಪ್ರೀಮಿಯಂ ಸಾಧನಗಳು.',
      'home': 'ಮುಖಪುಟ',
      'notifications': 'ಅಧಿಸೂಚನೆಗಳು',
      'profile': 'ಪ್ರೊಫೈಲ್',
      'helpSupport': 'ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ',
    },
  };

  static const Map<String, String> _malayalamValues = {
    'appTitle': 'FloraMind AI',
    'settings': 'ക്രമീകരണങ്ങൾ',
    'customizeExperience':
        'നിങ്ങളുടെ FloraMind AI അനുഭവം ഇഷ്ടാനുസരണം ക്രമീകരിക്കുക.',
    'appearance': 'രൂപഭാവം',
    'appearanceSubtitle':
        'നിങ്ങളുടെ ഉപകരണത്തിൽ FloraMind AI എങ്ങനെ കാണണമെന്ന് തിരഞ്ഞെടുക്കുക.',
    'lightTheme': 'ലൈറ്റ് തീം',
    'darkTheme': 'ഡാർക്ക് തീം',
    'systemTheme': 'സിസ്റ്റം തീം',
    'language': 'ഭാഷ',
    'languageSubtitle': 'ആപ്പ് ഇന്റർഫേസിൽ ഉപയോഗിക്കേണ്ട ഭാഷ തിരഞ്ഞെടുക്കുക.',
    'appLanguage': 'ആപ്പ് ഭാഷ',
    'languageEnglish': 'ഇംഗ്ലീഷ്',
    'languageMalayalam': 'മലയാളം',
    'languageHindi': 'ഹിന്ദി',
    'languageTamil': 'തമിഴ്',
    'languageKannada': 'കന്നഡ',
    'notificationSettings': 'അറിയിപ്പ് ക്രമീകരണങ്ങൾ',
    'notificationSubtitle':
        'നിങ്ങളുടെ ഉപകരണത്തിൽ കാണിക്കേണ്ട അലേർട്ടുകൾ തിരഞ്ഞെടുക്കുക.',
    'gardenPreferences': 'തോട്ട മുൻഗണനകൾ',
    'gardenPreferencesSubtitle':
        'നിങ്ങൾക്ക് ഇഷ്ടമുള്ള തോട്ട ശൈലിയും സസ്യ വിഭാഗങ്ങളും ക്രമീകരിക്കുക.',
    'preferredGardenType': 'ഇഷ്ടപ്പെട്ട തോട്ടത്തിന്റെ തരം',
    'preferredGardenTypeSubtitle': 'നിങ്ങൾക്ക് ഇഷ്ടമുള്ള പ്രധാന തോട്ട ശൈലി തിരഞ്ഞെടുക്കുക.',
    'preferredPlantCategory': 'ഇഷ്ടപ്പെട്ട സസ്യ വിഭാഗം',
    'preferredPlantCategorySubtitle':
        'നിങ്ങൾ ശ്രദ്ധിക്കാനാഗ്രഹിക്കുന്ന സസ്യ വിഭാഗം തിരഞ്ഞെടുക്കുക.',
    'iotSettings': 'IoT ക്രമീകരണങ്ങൾ',
    'iotSettingsSubtitle': 'ESP32, Flask, ഡാറ്റാബേസ് കണക്ഷൻ ക്രമീകരണങ്ങൾ.',
    'futureConnectDevice': 'ഭാവിയിൽ ഉപകരണം ബന്ധിപ്പിക്കുക',
    'security': 'സുരക്ഷ',
    'securitySubtitle': 'നിങ്ങളുടെ അക്കൗണ്ട് സുരക്ഷാ ക്രമീകരണങ്ങൾ നിയന്ത്രിക്കുക.',
    'backupRestore': 'ബാക്കപ്പ്, പുനഃസ്ഥാപനം',
    'backupRestoreSubtitle': 'നിങ്ങളുടെ മുൻഗണനകൾ ബാക്കപ്പ് ചെയ്യുകയും പുനഃസ്ഥാപിക്കുകയും ചെയ്യുക.',
    'aboutApplication': 'ആപ്പിനെക്കുറിച്ച്',
    'aboutApplicationSubtitle': 'FloraMind AI-യെക്കുറിച്ചുള്ള അടിസ്ഥാന വിവരങ്ങൾ.',
    'changePassword': 'പാസ്‌വേഡ് മാറ്റുക',
    'privacyPolicy': 'സ്വകാര്യതാ നയം',
    'termsConditions': 'നിബന്ധനകളും വ്യവസ്ഥകളും',
    'deleteAccount': 'അക്കൗണ്ട് ഇല്ലാതാക്കുക',
    'applicationName': 'ആപ്പിന്റെ പേര്',
    'version': 'പതിപ്പ്',
    'developer': 'ഡെവലപ്പർ',
    'project': 'പ്രോജക്റ്റ്',
    'goodMorning': 'സുപ്രഭാതം',
    'guestUser': 'അതിഥി ഉപയോക്താവ്',
    'exploreFeatures': 'സവിശേഷതകൾ പര്യവേക്ഷണം ചെയ്യുക',
    'featuresSubtitle': 'ആധുനിക തോട്ടപരിപാലനത്തിനുള്ള മികച്ച ഉപകരണങ്ങൾ.',
    'home': 'ഹോം',
    'notifications': 'അറിയിപ്പുകൾ',
    'profile': 'പ്രൊഫൈൽ',
    'helpSupport': 'സഹായവും പിന്തുണയും',
  };

  String _value(String key) {
    final code = locale.languageCode;
    if (code == 'ml') {
      return _malayalamValues[key] ?? _values['en']![key]!;
    }
    return _values[code]?[key] ?? _values['en']![key]!;
  }

  String get appTitle => _value('appTitle');
  String get settings => _value('settings');
  String get customizeExperience => _value('customizeExperience');
  String get appearance => _value('appearance');
  String get appearanceSubtitle => _value('appearanceSubtitle');
  String get lightTheme => _value('lightTheme');
  String get darkTheme => _value('darkTheme');
  String get systemTheme => _value('systemTheme');
  String get language => _value('language');
  String get languageSubtitle => _value('languageSubtitle');
  String get appLanguage => _value('appLanguage');
  String get languageEnglish => _value('languageEnglish');
  String get languageMalayalam => _value('languageMalayalam');
  String get languageHindi => _value('languageHindi');
  String get languageTamil => _value('languageTamil');
  String get languageKannada => _value('languageKannada');
  String get notificationSettings => _value('notificationSettings');
  String get notificationSubtitle => _value('notificationSubtitle');
  String get gardenPreferences => _value('gardenPreferences');
  String get gardenPreferencesSubtitle => _value('gardenPreferencesSubtitle');
  String get preferredGardenType => _value('preferredGardenType');
  String get preferredGardenTypeSubtitle =>
      _value('preferredGardenTypeSubtitle');
  String get preferredPlantCategory => _value('preferredPlantCategory');
  String get preferredPlantCategorySubtitle =>
      _value('preferredPlantCategorySubtitle');
  String get iotSettings => _value('iotSettings');
  String get iotSettingsSubtitle => _value('iotSettingsSubtitle');
  String get futureConnectDevice => _value('futureConnectDevice');
  String get security => _value('security');
  String get securitySubtitle => _value('securitySubtitle');
  String get backupRestore => _value('backupRestore');
  String get backupRestoreSubtitle => _value('backupRestoreSubtitle');
  String get aboutApplication => _value('aboutApplication');
  String get aboutApplicationSubtitle => _value('aboutApplicationSubtitle');
  String get changePassword => _value('changePassword');
  String get privacyPolicy => _value('privacyPolicy');
  String get termsConditions => _value('termsConditions');
  String get deleteAccount => _value('deleteAccount');
  String get applicationName => _value('applicationName');
  String get version => _value('version');
  String get developer => _value('developer');
  String get project => _value('project');
  String get goodMorning => _value('goodMorning');
  String get guestUser => _value('guestUser');
  String get exploreFeatures => _value('exploreFeatures');
  String get featuresSubtitle => _value('featuresSubtitle');
  String get home => _value('home');
  String get notifications => _value('notifications');
  String get profile => _value('profile');
  String get helpSupport => _value('helpSupport');
}
