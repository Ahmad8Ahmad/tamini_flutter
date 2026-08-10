import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  static const Map<String, String> _en = {
    'appName': 'Tamini',
    'loading': 'Loading...',
    'retry': 'Retry',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'save': 'Save',
    'done': 'Done',
    'back': 'Back',
    'next': 'Next',
    'or': 'or',
    'requiredField': 'This field is required',
    'refresh': 'Refresh',
    'language': 'Language',
    'arabic': 'Arabic',
    'english': 'English',
    'swedish': 'Swedish',
    'approved': 'Approved',
    'manage': 'Manage',
    'login': 'Login',
    'register': 'Register',
    'logout': 'Logout',
    'email': 'Email',
    'password': 'Password',
    'confirmPassword': 'Confirm Password',
    'username': 'Username',
    'phone': 'Phone',
    'phoneOptional': 'Phone (optional)',
    'welcomeBack': 'Welcome Back',
    'signInToContinue': 'Sign in to continue',
    'dontHaveAccount': "Don't have an account?",
    'alreadyHaveAccount': 'Already have an account?',
    'createAccount': 'Create New Account',
    'registerAs': 'I am a...',
    'customer': 'Customer',
    'restaurantOwner': 'Restaurant Owner',
    'deliveryDriver': 'Delivery Driver',
    'loginFailed': 'Login failed. Check credentials.',
    'registerFailed': 'Registration failed. Try again.',
    'passwordMin6': 'Min 6 characters',
    'passwordsDontMatch': "Passwords don't match",
    'enterValidEmail': 'Enter valid email',
    'verifyEmail': 'Verify Email',
    'enterVerificationCode': 'Enter Verification Code',
    'otpSentTo': 'We sent a 6-digit code to',
    'verify': 'Verify',
    'invalidOtp': 'Invalid or expired OTP.',
    'debugOtpLabel': 'Debug code:',
    'home': 'Home',
    'searchFood': 'Search food...',
    'restaurants': 'Restaurants',
    'trendy': 'Trendy',
    'viewAll': 'View All',
    'addToCart': 'Add to Cart',
    'addedToCart': 'Added to cart',
    'categories': 'Categories',
    'popularItems': 'Popular Items',
    'dashboardSubtitle': 'Go to your control panel',
    'trendyRestaurants': 'Trendy Restaurants',
    'meals': 'Meals',
    'noMealsFound': 'No meals found',
    'tryDifferentSearch': 'Try a different search',
    'searchRestaurants': 'Search restaurants...',
    'trySearchingForFood': 'Try searching for food',
    'menu': 'Menu',
    'rating': 'rating',
    'description': 'Description',
    'emptyMenu': 'Menu is empty',
    'noMenuItemsAvailable': 'No menu items available',
    'addToCartFailed': 'Failed to add to cart',
    'myCart': 'My Cart',
    'cartEmpty': 'Your cart is empty',
    'cartEmptyHint': 'Add some delicious dishes',
    'checkout': 'Checkout',
    'items': 'items',
    'each': 'each',
    'total': 'Total',
    'deliveryFee': 'Delivery Fee',
    'subtotal': 'Subtotal',
    'deliveryDetails': 'Delivery Details',
    'yourName': 'Your Name',
    'deliveryAddress': 'Delivery Address',
    'orderSummary': 'Order Summary',
    'placeOrder': 'Place Order',
    'orderPlaced': 'Order placed successfully!',
    'orderFailed': 'Failed to place order. Try again.',
    'cartEmptyLogin': 'Your cart is empty',
    'myOrders': 'My Orders',
    'noOrdersYet': 'No orders yet',
    'orderNumber': 'Order #',
    'ordersWillAppearHere': 'Your orders will appear here',
    'profile': 'Profile',
    'myDashboard': 'My Dashboard',
    'notLoggedIn': 'Not logged in',
    'address': 'Address',
    'createAccountShort': 'Create Account',
    'contactUs': 'Contact Us',
    'contactSubtitle': "We're here to help",
    'subject': 'Subject',
    'yourNameField': 'Your Name',
    'subjectHint': 'Brief summary',
    'descriptionHint': 'Describe the issue in detail...',
    'send': 'Send',
    'ticketSent': 'Your request was sent successfully!',
    'ticketFailed': 'Failed to send. Try again.',
    'callUs': 'Call Us',
    'emailUs': 'Email Us',
    'whatsapp': 'WhatsApp',
    'contactInfo': 'Contact Info',
    'followUs': 'Follow Us',
    'manageRestaurant': 'Manage Restaurant',
    'menuItems': 'Menu Items',
    'offers': 'Offers',
    'myRestaurants': 'My Restaurants',
    'noRestaurants': 'No restaurants found',
    'noRestaurantLinked': 'No restaurant linked to your account',
    'welcomeBackHello': 'Welcome back 👋',
    'offerPriceLessThanOriginal': 'Offer price must be less than the original price',
    'addMeal': 'Add Meal',
    'editMeal': 'Edit Meal',
    'mealName': 'Meal Name',
    'mealPrice': 'Price',
    'offerPrice': 'Offer Price (optional)',
    'offerPriceHint': 'Less than the original price',
    'mealDescription': 'Description (optional)',
    'chooseCategory': 'Choose Category',
    'chooseMealImage': 'Choose meal image',
    'changeImage': 'Change Image',
    'availableForOrder': 'Available for order',
    'notAvailable': 'Not available',
    'deleteMeal': 'Delete Meal',
    'noItemsYet': 'No items yet',
    'noItemsYetHint': 'Add your first meal to the menu',
    'noOffersYet': 'No offers yet',
    'noOffersYetHint': 'Add a discount to one of your meals',
    'addOffer': 'Add Offer',
    'editOffer': 'Edit Offer',
    'chooseMeal': 'Choose Meal',
    'removeOffer': 'Remove Offer',
    'removeOfferConfirm': 'Remove the offer from this meal?',
    'savedSuccessfully': 'Saved successfully',
    'deleteConfirmTitle': 'Confirm Delete',
    'deleteMealConfirm': 'Are you sure you want to delete this meal?',
    'deleted': 'Deleted',
    'offerSaved': 'Offer saved',
    'offerRemoved': 'Offer removed',
    'errorOccurred': 'Something went wrong. Try again.',
    'restaurantNotApproved': 'Your restaurant is under review',
    'deliveryDashboard': 'Delivery Dashboard',
    'availableDeliveries': 'Available',
    'myDeliveries': 'My Deliveries',
    'noAvailableDeliveries': 'No available deliveries right now',
    'noAvailableDeliveriesHint': 'New requests will appear here when an order is ready',
    'noMyDeliveries': 'No deliveries yet',
    'noMyDeliveriesHint': 'Accept a request from the first tab',
    'accept': 'Accept',
    'acceptDelivery': 'Accept Delivery',
    'completeDelivery': 'Complete Delivery',
    'completeDeliveryConfirm': 'Did you deliver the order successfully?',
    'distanceLabel': 'Distance',
    'km': 'km',
    'fromLabel': 'From',
    'toLabel': 'To',
    'customerLabel': 'Customer',
    'inProgress': 'In Progress',
    'deliveredLabel': 'Delivered',
    'completedCount': 'Trips',
    'totalEarnings': 'Earnings',
    'driverPendingApproval': 'Your account is pending admin approval',
    'driverPendingApprovalHint': 'You can start delivering once your account is approved',
    'accountUnderReview': 'Your account is under review',
    'underReviewBody':
        'We received your details. Our team is reviewing them and your account will be activated within 24 hours.',
    'contactWhatsapp': 'Contact us on WhatsApp',
    'contactEmail': 'Contact us by email',
    'backToHome': 'Back to Home',
    'checkStatus': 'Check account status',
    'joinThanks': 'Thanks for joining our family',
    'acceptedSuccess': 'Delivery accepted!',
    'completedSuccess': 'Delivery completed!',
    'updateAvailable': 'New update available',
    'updateMessage':
        'A new version of Tamini is available. Download it now to get the latest features and fixes.',
    'updateNow': 'Update Now',
    'later': 'Later',
    'installPromptTitle': 'Tamini App',
    'installPromptBody':
        'Get the best experience and fastest ordering through the Tamini app 🚀',
    'downloadAppNow': 'Download the App Now',
    'continueInBrowser': 'Continue in Browser',
  };

  static const Map<String, String> _ar = {
    'appName': 'طعميني',
    'loading': 'جاري التحميل...',
    'retry': 'إعادة المحاولة',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'save': 'حفظ',
    'done': 'تم',
    'back': 'رجوع',
    'next': 'التالي',
    'or': 'أو',
    'requiredField': 'هذا الحقل مطلوب',
    'refresh': 'تحديث',
    'language': 'اللغة',
    'arabic': 'العربية',
    'english': 'الإنجليزية',
    'swedish': 'السويدية',
    'approved': 'مقبول',
    'manage': 'إدارة',
    'login': 'تسجيل الدخول',
    'register': 'إنشاء حساب',
    'logout': 'تسجيل الخروج',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'confirmPassword': 'تأكيد كلمة المرور',
    'username': 'اسم المستخدم',
    'phone': 'الهاتف',
    'phoneOptional': 'الهاتف (اختياري)',
    'welcomeBack': 'مرحباً بعودتك',
    'signInToContinue': 'سجّل دخولك للمتابعة',
    'dontHaveAccount': 'ليس لديك حساب؟',
    'alreadyHaveAccount': 'لديك حساب بالفعل؟',
    'createAccount': 'إنشاء حساب جديد',
    'registerAs': 'أنا...',
    'customer': 'عميل',
    'restaurantOwner': 'صاحب مطعم',
    'deliveryDriver': 'سائق توصيل',
    'loginFailed': 'فشل تسجيل الدخول. تحقق من بياناتك.',
    'registerFailed': 'فشل التسجيل. حاول مرة أخرى.',
    'passwordMin6': '6 أحرف على الأقل',
    'passwordsDontMatch': 'كلمتا المرور غير متطابقتين',
    'enterValidEmail': 'أدخل بريداً إلكترونياً صالحاً',
    'verifyEmail': 'التحقق من البريد',
    'enterVerificationCode': 'أدخل رمز التحقق',
    'otpSentTo': 'أرسلنا رمز مكون من 6 أرقام إلى',
    'verify': 'تحقق',
    'invalidOtp': 'رمز غير صالح أو منتهي الصلاحية.',
    'debugOtpLabel': 'رمز التحقق (تجريبي):',
    'home': 'الرئيسية',
    'searchFood': 'ابحث عن طعام...',
    'restaurants': 'المطاعم',
    'trendy': 'رائج',
    'viewAll': 'عرض الكل',
    'addToCart': 'أضف للسلة',
    'addedToCart': 'تمت الإضافة للسلة',
    'categories': 'الأقسام',
    'popularItems': 'الأكثر طلباً',
    'dashboardSubtitle': 'ادخل إلى لوحة التحكم الخاصة بك',
    'trendyRestaurants': 'مطاعم رائجة',
    'meals': 'الوجبات',
    'noMealsFound': 'لا توجد وجبات',
    'tryDifferentSearch': 'جرّب بحثاً آخر',
    'searchRestaurants': 'ابحث عن مطاعم...',
    'trySearchingForFood': 'جرّب البحث عن طعام',
    'menu': 'القائمة',
    'rating': 'تقييم',
    'description': 'الوصف',
    'emptyMenu': 'القائمة فارغة',
    'noMenuItemsAvailable': 'لم نتمكن من إيجاد أي عناصر',
    'addToCartFailed': 'تعذر إضافة الطبق للسلة',
    'myCart': 'سلتي',
    'cartEmpty': 'سلتك فارغة',
    'cartEmptyHint': 'أضف بعض الأطباق اللذيذة',
    'checkout': 'إتمام الطلب',
    'items': 'عنصر',
    'each': 'لكل',
    'total': 'المجموع',
    'deliveryFee': 'رسوم التوصيل',
    'subtotal': 'المجموع الفرعي',
    'deliveryDetails': 'تفاصيل التوصيل',
    'yourName': 'اسمك',
    'deliveryAddress': 'عنوان التوصيل',
    'orderSummary': 'ملخص الطلب',
    'placeOrder': 'تأكيد الطلب',
    'orderPlaced': 'تم تأكيد الطلب بنجاح!',
    'orderFailed': 'فشل تأكيد الطلب. حاول مرة أخرى.',
    'cartEmptyLogin': 'سلتك فارغة',
    'myOrders': 'طلباتي',
    'noOrdersYet': 'لا توجد طلبات بعد',
    'orderNumber': 'طلب #',
    'ordersWillAppearHere': 'ستظهر طلباتك هنا',
    'profile': 'الحساب',
    'myDashboard': 'لوحتي',
    'notLoggedIn': 'لم تسجّل الدخول',
    'address': 'العنوان',
    'createAccountShort': 'إنشاء حساب',
    'contactUs': 'تواصل معنا',
    'contactSubtitle': 'نحن هنا لمساعدتك',
    'subject': 'الموضوع',
    'yourNameField': 'الاسم',
    'subjectHint': 'ملخص المشكلة',
    'descriptionHint': 'اشرح المشكلة بالتفصيل...',
    'send': 'إرسال',
    'ticketSent': 'تم إرسال طلبك بنجاح!',
    'ticketFailed': 'فشل الإرسال. حاول مرة أخرى.',
    'callUs': 'اتصل بنا',
    'emailUs': 'راسلنا',
    'whatsapp': 'واتساب',
    'contactInfo': 'معلومات التواصل',
    'followUs': 'تابعنا',
    'manageRestaurant': 'إدارة المطعم',
    'menuItems': 'الأصناف',
    'offers': 'العروض',
    'myRestaurants': 'مطاعمي',
    'noRestaurants': 'لا توجد مطاعم',
    'noRestaurantLinked': 'لم يتم ربط مطعم بحسابك بعد',
    'welcomeBackHello': 'مرحباً بك 👋',
    'offerPriceLessThanOriginal': 'سعر العرض يجب أن يكون أقل من السعر الأصلي',
    'addMeal': 'إضافة وجبة',
    'editMeal': 'تعديل الوجبة',
    'mealName': 'اسم الوجبة',
    'mealPrice': 'السعر',
    'offerPrice': 'سعر العرض (اختياري)',
    'offerPriceHint': 'أقل من السعر الأصلي',
    'mealDescription': 'الوصف (اختياري)',
    'chooseCategory': 'اختر القسم',
    'chooseMealImage': 'اختر صورة الوجبة',
    'changeImage': 'تغيير الصورة',
    'availableForOrder': 'متاح للطلب',
    'notAvailable': 'غير متوفر',
    'deleteMeal': 'حذف الوجبة',
    'noItemsYet': 'لا توجد أصناف بعد',
    'noItemsYetHint': 'أضف أول وجبة إلى قائمتك',
    'noOffersYet': 'لا توجد عروض حالياً',
    'noOffersYetHint': 'أضف خصماً على إحدى وجباتك',
    'addOffer': 'إضافة عرض',
    'editOffer': 'تعديل العرض',
    'chooseMeal': 'اختر الوجبة',
    'removeOffer': 'إزالة العرض',
    'removeOfferConfirm': 'هل تريد إزالة العرض من هذه الوجبة؟',
    'savedSuccessfully': 'تم الحفظ بنجاح',
    'deleteConfirmTitle': 'تأكيد الحذف',
    'deleteMealConfirm': 'هل أنت متأكد من حذف هذه الوجبة؟',
    'deleted': 'تم الحذف',
    'offerSaved': 'تم حفظ العرض',
    'offerRemoved': 'تمت إزالة العرض',
    'errorOccurred': 'حدث خطأ. حاول مرة أخرى.',
    'restaurantNotApproved': 'مطعمك قيد المراجعة',
    'deliveryDashboard': 'لوحة التوصيل',
    'availableDeliveries': 'متاح للتوصيل',
    'myDeliveries': 'توصيلاتي',
    'noAvailableDeliveries': 'لا توجد طلبات متاحة حالياً',
    'noAvailableDeliveriesHint': 'ستظهر الطلبات هنا فور خروجها للتوصيل',
    'noMyDeliveries': 'لا توجد توصيلات بعد',
    'noMyDeliveriesHint': 'اقبل طلباً من التبويب الأول',
    'accept': 'قبول',
    'acceptDelivery': 'قبول التوصيل',
    'completeDelivery': 'تأكيد التوصيل',
    'completeDeliveryConfirm': 'هل سلمت الطلب للعميل بنجاح؟',
    'distanceLabel': 'المسافة',
    'km': 'كم',
    'fromLabel': 'من',
    'toLabel': 'إلى',
    'customerLabel': 'العميل',
    'inProgress': 'قيد التوصيل',
    'deliveredLabel': 'تم التوصيل',
    'completedCount': 'توصيلة',
    'totalEarnings': 'الأرباح',
    'driverPendingApproval': 'حسابك قيد المراجعة من الإدارة',
    'driverPendingApprovalHint': 'ستتمكن من استلام التوصيلات بعد الموافقة على حسابك',
    'accountUnderReview': 'حسابك قيد المراجعة',
    'underReviewBody':
        'استلمنا بياناتك، فريقنا يقوم حالياً بمراجعة التفاصيل وسيتم تفعيل حسابك خلال 24 ساعة كحد أقصى.',
    'contactWhatsapp': 'تواصل معنا عبر واتساب',
    'contactEmail': 'تواصل معنا عبر البريد الإلكتروني',
    'backToHome': 'العودة للرئيسية',
    'checkStatus': 'تحقق من حالة الحساب',
    'joinThanks': 'شكراً لانضمامك لعائلتنا',
    'acceptedSuccess': 'تم قبول التوصيل!',
    'completedSuccess': 'تم إكمال التوصيل!',
    'updateAvailable': 'يتوفر تحديث جديد',
    'updateMessage': 'يتوفر إصدار جديد من تطبيق طعميني. حمّله الآن للحصول على أحدث الميزات والتحسينات.',
    'updateNow': 'تحديث الآن',
    'later': 'لاحقاً',
    'installPromptTitle': 'تطبيق طعميني',
    'installPromptBody': 'احصل على أفضل تجربة وسرعة في الطلب عبر تطبيق طعميني 🚀',
    'downloadAppNow': 'تحميل التطبيق الآن',
    'continueInBrowser': 'المتابعة عبر المتصفح',
  };

  static const Map<String, String> _sv = {
    'appName': 'Tamini',
    'loading': 'Laddar...',
    'retry': 'Försök igen',
    'cancel': 'Avbryt',
    'confirm': 'Bekräfta',
    'save': 'Spara',
    'done': 'Klar',
    'back': 'Tillbaka',
    'next': 'Nästa',
    'or': 'eller',
    'requiredField': 'Detta fält krävs',
    'refresh': 'Uppdatera',
    'language': 'Språk',
    'arabic': 'Arabiska',
    'english': 'Engelska',
    'swedish': 'Svenska',
    'approved': 'Godkänd',
    'manage': 'Hantera',
    'login': 'Logga in',
    'register': 'Registrera dig',
    'logout': 'Logga ut',
    'email': 'E-post',
    'password': 'Lösenord',
    'confirmPassword': 'Bekräfta lösenord',
    'username': 'Användarnamn',
    'phone': 'Telefon',
    'phoneOptional': 'Telefon (valfritt)',
    'welcomeBack': 'Välkommen tillbaka',
    'signInToContinue': 'Logga in för att fortsätta',
    'dontHaveAccount': 'Har du inget konto?',
    'alreadyHaveAccount': 'Har du redan ett konto?',
    'createAccount': 'Skapa nytt konto',
    'registerAs': 'Jag är...',
    'customer': 'Kund',
    'restaurantOwner': 'Restaurangägare',
    'deliveryDriver': 'Leveransförare',
    'loginFailed': 'Inloggningen misslyckades. Kontrollera dina uppgifter.',
    'registerFailed': 'Registreringen misslyckades. Försök igen.',
    'passwordMin6': 'Minst 6 tecken',
    'passwordsDontMatch': 'Lösenorden matchar inte',
    'enterValidEmail': 'Ange en giltig e-postadress',
    'verifyEmail': 'Verifiera e-post',
    'enterVerificationCode': 'Ange verifieringskod',
    'otpSentTo': 'Vi skickade en 6-siffrig kod till',
    'verify': 'Verifiera',
    'invalidOtp': 'Ogiltig eller utgången kod.',
    'debugOtpLabel': 'Felsökningskod:',
    'home': 'Hem',
    'searchFood': 'Sök mat...',
    'restaurants': 'Restauranger',
    'trendy': 'Trendig',
    'viewAll': 'Visa alla',
    'addToCart': 'Lägg i varukorg',
    'addedToCart': 'Lades till i varukorgen',
    'categories': 'Kategorier',
    'popularItems': 'Populära rätter',
    'dashboardSubtitle': 'Gå till din kontrollpanel',
    'trendyRestaurants': 'Trendiga restauranger',
    'meals': 'Måltider',
    'noMealsFound': 'Inga måltider hittades',
    'tryDifferentSearch': 'Prova en annan sökning',
    'searchRestaurants': 'Sök restauranger...',
    'trySearchingForFood': 'Prova att söka efter mat',
    'menu': 'Meny',
    'rating': 'betyg',
    'description': 'Beskrivning',
    'emptyMenu': 'Menyn är tom',
    'noMenuItemsAvailable': 'Inga menyalternativ finns',
    'addToCartFailed': 'Kunde inte lägga till i varukorgen',
    'myCart': 'Min varukorg',
    'cartEmpty': 'Din varukorg är tom',
    'cartEmptyHint': 'Lägg till några goda rätter',
    'checkout': 'Kassan',
    'items': 'artiklar',
    'each': 'st',
    'total': 'Totalt',
    'deliveryFee': 'Leveransavgift',
    'subtotal': 'Delsumma',
    'deliveryDetails': 'Leveransuppgifter',
    'yourName': 'Ditt namn',
    'deliveryAddress': 'Leveransadress',
    'orderSummary': 'Ordersammanfattning',
    'placeOrder': 'Lägg order',
    'orderPlaced': 'Ordern har lagts!',
    'orderFailed': 'Det gick inte att lägga ordern. Försök igen.',
    'cartEmptyLogin': 'Din varukorg är tom',
    'myOrders': 'Mina ordrar',
    'noOrdersYet': 'Inga ordrar ännu',
    'orderNumber': 'Order #',
    'ordersWillAppearHere': 'Dina ordrar visas här',
    'profile': 'Profil',
    'myDashboard': 'Min panel',
    'notLoggedIn': 'Inte inloggad',
    'address': 'Adress',
    'createAccountShort': 'Skapa konto',
    'contactUs': 'Kontakta oss',
    'contactSubtitle': 'Vi finns här för att hjälpa dig',
    'subject': 'Ämne',
    'yourNameField': 'Ditt namn',
    'subjectHint': 'Kort sammanfattning',
    'descriptionHint': 'Beskriv problemet i detalj...',
    'send': 'Skicka',
    'ticketSent': 'Din förfrågan skickades!',
    'ticketFailed': 'Det gick inte att skicka. Försök igen.',
    'callUs': 'Ring oss',
    'emailUs': 'E-posta oss',
    'whatsapp': 'WhatsApp',
    'contactInfo': 'Kontaktinformation',
    'followUs': 'Följ oss',
    'manageRestaurant': 'Hantera restaurang',
    'menuItems': 'Menyartiklar',
    'offers': 'Erbjudanden',
    'myRestaurants': 'Mina restauranger',
    'noRestaurants': 'Inga restauranger hittades',
    'noRestaurantLinked': 'Ingen restaurang är kopplad till ditt konto',
    'welcomeBackHello': 'Välkommen tillbaka 👋',
    'offerPriceLessThanOriginal': 'Erbjudandepriset måste vara lägre än originalpriset',
    'addMeal': 'Lägg till måltid',
    'editMeal': 'Redigera måltid',
    'mealName': 'Måltidens namn',
    'mealPrice': 'Pris',
    'offerPrice': 'Erbjudandepris (valfritt)',
    'offerPriceHint': 'Lägre än originalpriset',
    'mealDescription': 'Beskrivning (valfritt)',
    'chooseCategory': 'Välj kategori',
    'chooseMealImage': 'Välj bild för måltiden',
    'changeImage': 'Byt bild',
    'availableForOrder': 'Tillgänglig för beställning',
    'notAvailable': 'Inte tillgänglig',
    'deleteMeal': 'Ta bort måltid',
    'noItemsYet': 'Inga artiklar ännu',
    'noItemsYetHint': 'Lägg till din första måltid i menyn',
    'noOffersYet': 'Inga erbjudanden för närvarande',
    'noOffersYetHint': 'Lägg till ett rabatterbjudande på en av dina måltider',
    'addOffer': 'Lägg till erbjudande',
    'editOffer': 'Redigera erbjudande',
    'chooseMeal': 'Välj måltid',
    'removeOffer': 'Ta bort erbjudande',
    'removeOfferConfirm': 'Ta bort erbjudandet från denna måltid?',
    'savedSuccessfully': 'Sparat',
    'deleteConfirmTitle': 'Bekräfta borttagning',
    'deleteMealConfirm': 'Är du säker på att du vill ta bort denna måltid?',
    'deleted': 'Borttagen',
    'offerSaved': 'Erbjudandet sparat',
    'offerRemoved': 'Erbjudandet borttaget',
    'errorOccurred': 'Något gick fel. Försök igen.',
    'restaurantNotApproved': 'Din restaurang granskas',
    'deliveryDashboard': 'Leveranspanel',
    'availableDeliveries': 'Tillgängliga',
    'myDeliveries': 'Mina leveranser',
    'noAvailableDeliveries': 'Inga tillgängliga leveranser just nu',
    'noAvailableDeliveriesHint': 'Nya förfrågningar visas här när en order är redo',
    'noMyDeliveries': 'Inga leveranser ännu',
    'noMyDeliveriesHint': 'Acceptera en förfrågan från den första fliken',
    'accept': 'Acceptera',
    'acceptDelivery': 'Acceptera leverans',
    'completeDelivery': 'Slutför leverans',
    'completeDeliveryConfirm': 'Levererade du ordern till kunden?',
    'distanceLabel': 'Avstånd',
    'km': 'km',
    'fromLabel': 'Från',
    'toLabel': 'Till',
    'customerLabel': 'Kund',
    'inProgress': 'Pågår',
    'deliveredLabel': 'Levererad',
    'completedCount': 'Resor',
    'totalEarnings': 'Intäkter',
    'driverPendingApproval': 'Ditt konto väntar på administratörsgodkännande',
    'driverPendingApprovalHint': 'Du kan börja leverera när kontot är godkänt',
    'accountUnderReview': 'Ditt konto granskas',
    'underReviewBody':
        'Vi har tagit emot dina uppgifter. Vårt team granskar dem och ditt konto aktiveras inom max 24 timmar.',
    'contactWhatsapp': 'Kontakta oss via WhatsApp',
    'contactEmail': 'Kontakta oss via e-post',
    'backToHome': 'Tillbaka till start',
    'checkStatus': 'Kontrollera kontostatus',
    'joinThanks': 'Tack för att du gick med i vår familj',
    'acceptedSuccess': 'Leveransen accepterades!',
    'completedSuccess': 'Leveransen slutfördes!',
    'updateAvailable': 'Ny uppdatering finns',
    'updateMessage':
        'En ny version av Tamini finns tillgänglig. Ladda ner den nu för de senaste funktionerna och förbättringarna.',
    'updateNow': 'Uppdatera nu',
    'later': 'Senare',
    'installPromptTitle': 'Tamini-appen',
    'installPromptBody':
        'Få den bästa upplevelsen och snabbare beställning med Tamini-appen 🚀',
    'downloadAppNow': 'Ladda ner appen nu',
    'continueInBrowser': 'Fortsätt i webbläsaren',
  };

  Map<String, String> get _s {
    switch (locale.languageCode) {
      case 'ar':
        return _ar;
      case 'sv':
        return _sv;
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
  String get swedish => _t('swedish');
  String get approved => _t('approved');
  String get manage => _t('manage');

  String copiedText(String label) {
    switch (locale.languageCode) {
      case 'ar':
        return 'تم نسخ $label';
      case 'sv':
        return '$label kopierad';
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

  // ── Checkout ────────────────────────────────────────────────
  String get deliveryDetails => _t('deliveryDetails');
  String get yourName => _t('yourName');
  String get deliveryAddress => _t('deliveryAddress');
  String get orderSummary => _t('orderSummary');
  String get placeOrder => _t('placeOrder');
  String get orderPlaced => _t('orderPlaced');
  String get orderFailed => _t('orderFailed');
  String get cartEmptyLogin => _t('cartEmptyLogin');

  // ── Orders ──────────────────────────────────────────────────
  String get myOrders => _t('myOrders');
  String get noOrdersYet => _t('noOrdersYet');
  String get orderNumber => _t('orderNumber');
  String get ordersWillAppearHere => _t('ordersWillAppearHere');

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

  static const Map<String, String> _arDeliveryStatus = {
    'searching': 'متاح',
    'onway': 'قيد التوصيل',
    'pickedup': 'تم الاستلام',
    'delivered': 'تم التوصيل',
  };

  static const Map<String, String> _svDeliveryStatus = {
    'searching': 'Tillgänglig',
    'onway': 'På väg',
    'pickedup': 'Hämtad',
    'delivered': 'Levererad',
  };

  String deliveryStatusText(String status) {
    final key = _normalizeStatus(status);
    switch (locale.languageCode) {
      case 'ar':
        return _arDeliveryStatus[key] ?? status;
      case 'sv':
        return _svDeliveryStatus[key] ?? status;
      default:
        return status;
    }
  }

  static const Map<String, String> _arStatus = {
    'pending': 'قيد الانتظار',
    'confirmed': 'تم التأكيد',
    'preparing': 'جاري التحضير',
    'outfordelivery': 'خرج للتوصيل',
    'delivered': 'تم التوصيل',
    'cancelled': 'تم الإلغاء',
    'canceled': 'تم الإلغاء',
  };

  static const Map<String, String> _svStatus = {
    'pending': 'Väntar',
    'confirmed': 'Bekräftad',
    'preparing': 'Förbereds',
    'outfordelivery': 'Ute för leverans',
    'delivered': 'Levererad',
    'cancelled': 'Avbruten',
    'canceled': 'Avbruten',
  };

  // ── Status ──────────────────────────────────────────────────
  String statusText(String status) {
    final key = _normalizeStatus(status);
    switch (locale.languageCode) {
      case 'ar':
        return _arStatus[key] ?? status;
      case 'sv':
        return _svStatus[key] ?? status;
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

  /// Translates known single-language backend strings to the current locale.
  /// Returns the original text when no translation is available.
  String backendText(String? text) {
    if (text == null || text.isEmpty) return text ?? '';
    if (!isArabic) return text;
    final key = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9% ]'), '').trim();
    return _backendArabic[key] ?? text;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en', 'sv'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
