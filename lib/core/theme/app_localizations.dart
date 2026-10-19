import 'package:flutter/material.dart';

part 'app_localizations_data.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  Map<String, String> get _s {
    switch (locale.languageCode) {
      case 'ar':
        return _ar;
      default:
        return _en;
    }
  }

  String _t(String key) => _s[key] ?? _en[key] ?? key;

  // ── Common ──────────────────────────────────────────────────
  String get appName => _t('appName');
  String get loading => _t('loading');
  String get retry => _t('retry');
  String get cancel => _t('cancel');
  String get confirm => _t('confirm');
  String get save => _t('save');
  String get done => _t('done');
  String get back => _t('back');
  String get next => _t('next');
  String get or => _t('or');
  String get requiredField => _t('requiredField');
  String get refresh => _t('refresh');
  String get language => _t('language');
  String get arabic => _t('arabic');
  String get english => _t('english');
  String get approved => _t('approved');
  String get manage => _t('manage');

  String copiedText(String label) {
    switch (locale.languageCode) {
      case 'ar':
        return 'تم نسخ $label';
      default:
        return '$label copied';
    }
  }

  // ── Auth ────────────────────────────────────────────────────
  String get login => _t('login');
  String get register => _t('register');
  String get logout => _t('logout');
  String get email => _t('email');
  String get password => _t('password');
  String get confirmPassword => _t('confirmPassword');
  String get username => _t('username');
  String get phone => _t('phone');
  String get phoneOptional => _t('phoneOptional');
  String get welcomeBack => _t('welcomeBack');
  String get signInToContinue => _t('signInToContinue');
  String get dontHaveAccount => _t('dontHaveAccount');
  String get alreadyHaveAccount => _t('alreadyHaveAccount');
  String get createAccount => _t('createAccount');
  String get registerAs => _t('registerAs');
  String get customer => _t('customer');
  String get restaurantOwner => _t('restaurantOwner');
  String get deliveryDriver => _t('deliveryDriver');
  String get loginFailed => _t('loginFailed');
  String get invalidCredentials => _t('invalidCredentials');
  String get registerFailed => _t('registerFailed');
  String get passwordMin6 => _t('passwordMin6');
  String get passwordsDontMatch => _t('passwordsDontMatch');
  String get enterValidEmail => _t('enterValidEmail');

  // ── OTP ─────────────────────────────────────────────────────
  String get verifyEmail => _t('verifyEmail');
  String get enterVerificationCode => _t('enterVerificationCode');
  String get otpSentTo => _t('otpSentTo');
  String get verify => _t('verify');
  String get invalidOtp => _t('invalidOtp');
  String get debugOtpLabel => _t('debugOtpLabel');

  // ── Home ────────────────────────────────────────────────────
  String get home => _t('home');
  String get searchFood => _t('searchFood');
  String get restaurants => _t('restaurants');
  String get trendy => _t('trendy');
  String get viewAll => _t('viewAll');
  String get addToCart => _t('addToCart');
  String get addedToCart => _t('addedToCart');
  String get categories => _t('categories');
  String get popularItems => _t('popularItems');
  String get dashboardSubtitle => _t('dashboardSubtitle');
  String get trendyRestaurants => _t('trendyRestaurants');
  String get meals => _t('meals');
  String get noMealsFound => _t('noMealsFound');
  String get tryDifferentSearch => _t('tryDifferentSearch');
  String get searchRestaurants => _t('searchRestaurants');
  String get trySearchingForFood => _t('trySearchingForFood');

  // ── Restaurant ──────────────────────────────────────────────
  String get menu => _t('menu');
  String get rating => _t('rating');
  String get description => _t('description');
  String get emptyMenu => _t('emptyMenu');
  String get noMenuItemsAvailable => _t('noMenuItemsAvailable');
  String get addToCartFailed => _t('addToCartFailed');

  // ── Cart ────────────────────────────────────────────────────
  String get myCart => _t('myCart');
  String get cartEmpty => _t('cartEmpty');
  String get cartEmptyHint => _t('cartEmptyHint');
  String get checkout => _t('checkout');
  String get items => _t('items');
  String get each => _t('each');
  String get total => _t('total');
  String get deliveryFee => _t('deliveryFee');
  String get subtotal => _t('subtotal');
  String get serviceFee => _t('serviceFee');
  String get deliveryLocation => _t('deliveryLocation');
  String get setLocationOnMap => _t('setLocationOnMap');
  String get tapMapToSelectLocation => _t('tapMapToSelectLocation');

  // ── Checkout ────────────────────────────────────────────────
  String get deliveryDetails => _t('deliveryDetails');
  String get yourName => _t('yourName');
  String get deliveryAddress => _t('deliveryAddress');
  String get orderSummary => _t('orderSummary');
  String get placeOrder => _t('placeOrder');
  String get paymentMethod => _t('paymentMethod');
  String get cashOnDelivery => _t('cashOnDelivery');
  String get cashOnDeliveryHint => _t('cashOnDeliveryHint');
  String get cardPayment => _t('cardPayment');
  String get cardPaymentHint => _t('cardPaymentHint');
  String get paymentRedirecting => _t('paymentRedirecting');
  String get orderPlaced => _t('orderPlaced');
  String get orderFailed => _t('orderFailed');
  String get cartEmptyLogin => _t('cartEmptyLogin');

  // ── Orders ──────────────────────────────────────────────────
  String get myOrders => _t('myOrders');
  String get noOrdersYet => _t('noOrdersYet');
  String get orderNumber => _t('orderNumber');
  String get ordersWillAppearHere => _t('ordersWillAppearHere');
  String get track => _t('track');
  String get tracking => _t('tracking');
  String get liveTracking => _t('liveTracking');
  String get trackingUnavailable => _t('trackingUnavailable');
  String get waitingForDriver => _t('waitingForDriver');
  String get driverOnTheWay => _t('driverOnTheWay');
  String get driverInfo => _t('driverInfo');
  String get callDriver => _t('callDriver');
  String get openInMaps => _t('openInMaps');
  String get restaurant => _t('restaurant');
  String get yourOrder => _t('yourOrder');

  // ── Profile ─────────────────────────────────────────────────
  String get profile => _t('profile');
  String get myDashboard => _t('myDashboard');
  String get notLoggedIn => _t('notLoggedIn');
  String get address => _t('address');
  String get createAccountShort => _t('createAccountShort');

  // ── Support / Contact ───────────────────────────────────────
  String get contactUs => _t('contactUs');
  String get contactSubtitle => _t('contactSubtitle');
  String get subject => _t('subject');
  String get yourNameField => _t('yourNameField');
  String get subjectHint => _t('subjectHint');
  String get descriptionHint => _t('descriptionHint');
  String get send => _t('send');
  String get ticketSent => _t('ticketSent');
  String get ticketFailed => _t('ticketFailed');
  String get callUs => _t('callUs');
  String get emailUs => _t('emailUs');
  String get whatsapp => _t('whatsapp');
  String get contactInfo => _t('contactInfo');
  String get followUs => _t('followUs');

  // ── Restaurant Owner Management ─────────────────────────────
  String get manageRestaurant => _t('manageRestaurant');
  String get menuItems => _t('menuItems');
  String get offers => _t('offers');
  String get myRestaurants => _t('myRestaurants');
  String get noRestaurants => _t('noRestaurants');
  String get noRestaurantLinked => _t('noRestaurantLinked');
  String get open => _t('open');
  String get closed => _t('closed');
  String get restaurantOpenHint => _t('restaurantOpenHint');
  String get restaurantClosedHint => _t('restaurantClosedHint');
  String get welcomeBackHello => _t('welcomeBackHello');
  String get offerPriceLessThanOriginal => _t('offerPriceLessThanOriginal');
  String get addMeal => _t('addMeal');
  String get editMeal => _t('editMeal');
  String get mealName => _t('mealName');
  String get mealPrice => _t('mealPrice');
  String get offerPrice => _t('offerPrice');
  String get offerPriceHint => _t('offerPriceHint');
  String get mealDescription => _t('mealDescription');
  String get chooseCategory => _t('chooseCategory');
  String get chooseMealImage => _t('chooseMealImage');
  String get changeImage => _t('changeImage');
  String get availableForOrder => _t('availableForOrder');
  String get notAvailable => _t('notAvailable');
  String get deleteMeal => _t('deleteMeal');
  String get noItemsYet => _t('noItemsYet');
  String get noItemsYetHint => _t('noItemsYetHint');
  String get noOffersYet => _t('noOffersYet');
  String get noOffersYetHint => _t('noOffersYetHint');
  String get addOffer => _t('addOffer');
  String get editOffer => _t('editOffer');
  String get chooseMeal => _t('chooseMeal');
  String get removeOffer => _t('removeOffer');
  String get removeOfferConfirm => _t('removeOfferConfirm');
  String get savedSuccessfully => _t('savedSuccessfully');
  String get deleteConfirmTitle => _t('deleteConfirmTitle');
  String get deleteMealConfirm => _t('deleteMealConfirm');
  String get deleted => _t('deleted');
  String get offerSaved => _t('offerSaved');
  String get offerRemoved => _t('offerRemoved');
  String get errorOccurred => _t('errorOccurred');
  String get restaurantNotApproved => _t('restaurantNotApproved');

  // ── Restaurant Edit ─────────────────────────────────────────
  String get editRestaurant => _t('editRestaurant');
  String get restaurantInfo => _t('restaurantInfo');
  String get restaurantName => _t('restaurantName');
  String get restaurantDescription => _t('restaurantDescription');
  String get restaurantPhone => _t('restaurantPhone');
  String get chooseLogo => _t('chooseLogo');
  String get chooseCoverImage => _t('chooseCoverImage');
  String get changeLogo => _t('changeLogo');
  String get changeCoverImage => _t('changeCoverImage');

  // ── Restaurant Orders ───────────────────────────────────────
  String get orders => _t('orders');
  String get orderDetails => _t('orderDetails');
  String get newOrderReceived => _t('newOrderReceived');
  String get confirmOrder => _t('confirmOrder');
  String get startPreparing => _t('startPreparing');
  String get outForDeliveryAction => _t('outForDeliveryAction');
  String get markCompleted => _t('markCompleted');
  String get cancelOrder => _t('cancelOrder');
  String get live => _t('live');
  String get offline => _t('offline');
  String get reconnecting => _t('reconnecting');
  String get deliveries => _t('deliveries');
  String get liveDelivery => _t('liveDelivery');
  String get selectOrder => _t('selectOrder');
  String get noDeliveriesYet => _t('noDeliveriesYet');
  String get noDeliveriesHint => _t('noDeliveriesHint');
  String get kitchenMode => _t('kitchenMode');
  String get kitchenModeHint => _t('kitchenModeHint');
  String get staffManagement => _t('staffManagement');
  String get staff => _t('staff');
  String get addStaff => _t('addStaff');
  String get staffName => _t('staffName');
  String get temporaryPassword => _t('temporaryPassword');
  String get staffAdded => _t('staffAdded');
  String get noStaffYet => _t('noStaffYet');
  String get noStaffHint => _t('noStaffHint');

  // ── Sales Dashboard ────────────────────────────────────────
  String get sales => _t('sales');
  String get salesDashboard => _t('salesDashboard');
  String get todayOrders => _t('todayOrders');
  String get todayRevenue => _t('todayRevenue');
  String get totalOrders => _t('totalOrders');
  String get totalRevenue => _t('totalRevenue');
  String get avgOrderValue => _t('avgOrderValue');
  String get topItems => _t('topItems');
  String get statusBreakdown => _t('statusBreakdown');
  String get revenueTrend => _t('revenueTrend');
  String get pending => _t('pending');
  String get completedOrders => _t('completedOrders');
  String get cancelledOrders => _t('cancelledOrders');
  String get noDataYet => _t('noDataYet');

  // ── Delivery Settings ──────────────────────────────────────
  String get deliverySettings => _t('deliverySettings');
  String get deliverySettingsHint => _t('deliverySettingsHint');
  String get flatDeliveryFee => _t('flatDeliveryFee');
  String get deliveryFeePerKm => _t('deliveryFeePerKm');
  String get minOrderAmount => _t('minOrderAmount');
  String get deliveryRadius => _t('deliveryRadius');
  String get hasOwnDelivery => _t('hasOwnDelivery');
  String get hasOwnDeliveryHint => _t('hasOwnDeliveryHint');

  // ── Delivery Dashboard ──────────────────────────────────────
  String get deliveryDashboard => _t('deliveryDashboard');
  String get availableDeliveries => _t('availableDeliveries');
  String get myDeliveries => _t('myDeliveries');
  String get noAvailableDeliveries => _t('noAvailableDeliveries');
  String get noAvailableDeliveriesHint => _t('noAvailableDeliveriesHint');
  String get noMyDeliveries => _t('noMyDeliveries');
  String get noMyDeliveriesHint => _t('noMyDeliveriesHint');
  String get accept => _t('accept');
  String get acceptDelivery => _t('acceptDelivery');
  String get completeDelivery => _t('completeDelivery');
  String get completeDeliveryConfirm => _t('completeDeliveryConfirm');
  String get distanceLabel => _t('distanceLabel');
  String get km => _t('km');
  String get fromLabel => _t('fromLabel');
  String get toLabel => _t('toLabel');
  String get customerLabel => _t('customerLabel');
  String get inProgress => _t('inProgress');
  String get deliveredLabel => _t('deliveredLabel');
  String get completedCount => _t('completedCount');
  String get totalEarnings => _t('totalEarnings');
  String get driverPendingApproval => _t('driverPendingApproval');
  String get driverPendingApprovalHint => _t('driverPendingApprovalHint');
  String get accountUnderReview => _t('accountUnderReview');
  String get underReviewBody => _t('underReviewBody');
  String get contactWhatsapp => _t('contactWhatsapp');
  String get contactEmail => _t('contactEmail');
  String get backToHome => _t('backToHome');
  String get checkStatus => _t('checkStatus');
  String get joinThanks => _t('joinThanks');
  String get acceptedSuccess => _t('acceptedSuccess');
  String get completedSuccess => _t('completedSuccess');
  String get activeDelivery => _t('activeDelivery');
  String get reject => _t('reject');
  String get rejectedSuccess => _t('rejectedSuccess');
  String get cancelDeliveryConfirm => _t('cancelDeliveryConfirm');
  String get earnings => _t('earnings');
  String get dailyEarnings => _t('dailyEarnings');
  String get weeklyEarnings => _t('weeklyEarnings');
  String get totalTrips => _t('totalTrips');
  String get avgEarningPerTrip => _t('avgEarningPerTrip');
  String get pickup => _t('pickup');
  String get noEarningsYet => _t('noEarningsYet');
  String get noEarningsHint => _t('noEarningsHint');

  // ── Update ───────────────────────────────────────────────────
  String get updateAvailable => _t('updateAvailable');
  String get updateMessage => _t('updateMessage');
  String get updateNow => _t('updateNow');
  String get later => _t('later');

  // ── Install prompt ───────────────────────────────────────────
  String get installPromptTitle => _t('installPromptTitle');
  String get installPromptBody => _t('installPromptBody');
  String get downloadAppNow => _t('downloadAppNow');
  String get continueInBrowser => _t('continueInBrowser');

  // ── Forgot Password / Google / Verification ─────────────────
  String get forgotPassword => _t('forgotPassword');
  String get forgotPasswordSubtitle => _t('forgotPasswordSubtitle');
  String get resetPassword => _t('resetPassword');
  String get emailSent => _t('emailSent');
  String get checkYourEmail => _t('checkYourEmail');
  String get googleSignIn => _t('googleSignIn');
  String get orContinueWith => _t('orContinueWith');
  String get verificationEmailSent => _t('verificationEmailSent');
  String get checkInboxVerify => _t('checkInboxVerify');
  String get resendVerification => _t('resendVerification');
  String get emailVerifiedSuccess => _t('emailVerifiedSuccess');
  String get emailNotVerified => _t('emailNotVerified');
  String get googleSignInFailed => _t('googleSignInFailed');
  String get resetPasswordFailed => _t('resetPasswordFailed');
  String get registrationFailed => _t('registrationFailed');
  String get emailAlreadyInUse => _t('emailAlreadyInUse');
  String get weakPassword => _t('weakPassword');
  String get invalidEmail => _t('invalidEmail');
  String get operationNotAllowed => _t('operationNotAllowed');
  String get networkRequestFailed => _t('networkRequestFailed');
  String get genericAuthError => _t('genericAuthError');

  // ── Settings ────────────────────────────────────────────────
  String get settings => _t('settings');
  String get account => _t('account');
  String get preferences => _t('preferences');
  String get notifications => _t('notifications');
  String get helpAndSupport => _t('helpAndSupport');
  String get legal => _t('legal');
  String get about => _t('about');
  String get deleteAccount => _t('deleteAccount');
  String get signInSettings => _t('signInSettings');
  String get editProfile => _t('editProfile');
  String get changePassword => _t('changePassword');
  String get addressOptional => _t('addressOptional');
  String get profileUpdated => _t('profileUpdated');
  String get profileUpdateFailed => _t('profileUpdateFailed');
  String get theme => _t('theme');
  String get lightTheme => _t('lightTheme');
  String get darkTheme => _t('darkTheme');
  String get systemTheme => _t('systemTheme');
  String get orderUpdates => _t('orderUpdates');
  String get promotions => _t('promotions');
  String get emailNotifications => _t('emailNotifications');
  String get preferencesSaved => _t('preferencesSaved');
  String get preferencesSaveFailed => _t('preferencesSaveFailed');
  String get newTicket => _t('newTicket');
  String get myTickets => _t('myTickets');
  String get noTicketsYet => _t('noTicketsYet');
  String get ticketsLoadFailed => _t('ticketsLoadFailed');
  String get termsOfService => _t('termsOfService');
  String get privacyPolicy => _t('privacyPolicy');
  String get legalUnavailable => _t('legalUnavailable');
  String get appVersion => _t('appVersion');
  String get deleteAccountTitle => _t('deleteAccountTitle');
  String get deleteAccountWarning => _t('deleteAccountWarning');
  String get passwordToConfirm => _t('passwordToConfirm');
  String get deleteAccountConfirm => _t('deleteAccountConfirm');
  String get accountDeleted => _t('accountDeleted');
  String get deleteVerifyFailed => _t('deleteVerifyFailed');
  String get deleteNotYours => _t('deleteNotYours');
  String get deleteWrongPassword => _t('deleteWrongPassword');
  String get deleteTooManyAttempts => _t('deleteTooManyAttempts');
  String get deleteAccountFailed => _t('deleteAccountFailed');
  String get oldPasswordIncorrect => _t('oldPasswordIncorrect');
  String get passwordChanged => _t('passwordChanged');
  String get passwordChangeFailed => _t('passwordChangeFailed');
  String get newPasswordRule => _t('newPasswordRule');

  // ── Bottom navigation ───────────────────────────────────────
  String get navHome => _t('navHome');
  String get navRestaurants => _t('navRestaurants');
  String get navCart => _t('navCart');
  String get navOrders => _t('navOrders');
  String get navProfile => _t('navProfile');

  String ticketStatus(String status) {
    switch (status) {
      case 'in_progress':
        return _t('ticketInProgress');
      case 'resolved':
        return _t('ticketResolved');
      case 'closed':
        return _t('ticketClosed');
      default:
        return _t('ticketOpen');
    }
  }

  static const Map<String, String> _arDeliveryStatus = {
    'searching': 'متاح',
    'onway': 'قيد التوصيل',
    'pickedup': 'تم الاستلام',
    'delivered': 'تم التوصيل',
  };

  String deliveryStatusText(String status) {
    final key = _normalizeStatus(status);
    switch (locale.languageCode) {
      case 'ar':
        return _arDeliveryStatus[key] ?? status;
      default:
        return status;
    }
  }

  static const Map<String, String> _arStatus = {
    'pending': 'قيد الانتظار',
    'confirmed': 'تم التأكيد',
    'preparing': 'جاري التحضير',
    'inprogress': 'قيد التنفيذ',
    'outfordelivery': 'خرج للتوصيل',
    'delivered': 'تم التوصيل',
    'completed': 'مكتمل',
    'cancelled': 'تم الإلغاء',
    'canceled': 'تم الإلغاء',
  };

  // ── Status ──────────────────────────────────────────────────
  String statusText(String status) {
    final key = _normalizeStatus(status);
    switch (locale.languageCode) {
      case 'ar':
        return _arStatus[key] ?? status;
      default:
        return status;
    }
  }

  String _normalizeStatus(String status) =>
      status.trim().toLowerCase().replaceAll(RegExp(r'[_\s\-]+'), '');

  String formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ── Backend-provided content (single-language) ──────────────
  static const Map<String, String> _backendArabic = {
    'welcome': 'مرحباً',
    'welcome back': 'مرحباً بعودتك',
    'register here': 'سجّل الآن',
    'register now': 'سجّل الآن',
    'register now and get 20% off your first order':
        'سجّل الآن واحصل على خصم 20% على طلبك الأول',
    'o you who believe in the oneness of allah islamic monotheism eat of the lawful things that we have provided you with and be grateful to allah if it is indeed he whom you worship':
        'يَا أَيُّهَا الَّذِينَ آمَنُوا كُلُوا مِن طَيِّبَاتِ مَا رَزَقْنَاكُمْ وَاشْكُرُوا لِلَّهِ إِن كُنتُمْ إِيَّاهُ تَعْبُدُونَ',
  };

  /// Strips Arabic diacritics and normalizes alef variants so that backend
  /// strings still match their translation keys despite minor spelling
  /// differences between the site settings and this app.
  static String _normalizeArabic(String s) {
    final b = StringBuffer();
    for (final code in s.trim().runes) {
      if (code >= 0x064B && code <= 0x065F) continue; // harakat / tashkeel
      if (code == 0x0640 || code == 0x0670) {
        continue; // tatweel / superscript alef
      }
      if (code == 0x0622 || code == 0x0623 || code == 0x0625) {
        b.writeCharCode(0x0627); // alef variants → plain alef
        continue;
      }
      if (code == 0x200F) continue; // right-to-left mark
      b.writeCharCode(code);
    }
    return b.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _arabicKey(String s) => _normalizeArabic(s);

  static final Map<String, String> _backendEnglish = {
    _arabicKey('أهلاً بك في طعميني'): 'Welcome to Tamini',
    _arabicKey('سجل الأن'): 'Register now',
    _arabicKey('سجل الأن و إحصل على 20% خصم على اول طلب'):
        'Register now and get 20% off your first order',
    _arabicKey('سجل هنا'): 'Register here',
    _arabicKey(
      'يَا أَيُّهَا الَّذِينَ آمَنُوا كُلُوا مِن طَيِّبَاتِ مَا رَزَقْنَاكُمْ وَاشْكُرُوا لِلَّهِ إِن كُنتُمْ إِيَّاهُ تَعْبُدُونَ',
    ): 'O you who believe! Eat of the lawful things that We have provided you with, and be grateful to Allah, if it is indeed Him that you worship.',
  };

  /// Translates known single-language backend strings to the current locale.
  /// Returns the original text when no translation is available.
  String backendText(String? text) {
    if (text == null || text.isEmpty) return text ?? '';
    final trimmed = text.trim();
    final isArabicContent = RegExp(r'[\u0600-\u06FF]').hasMatch(trimmed);
    if (isArabicContent) {
      if (isArabic) return trimmed;
      final key = _arabicKey(trimmed);
      return _backendEnglish[key] ?? trimmed;
    }
    if (isArabic) {
      final key = trimmed
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9% ]'), '')
          .trim();
      return _backendArabic[key] ?? trimmed;
    }
    return trimmed;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
