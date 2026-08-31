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
    'placeOrder': 'Confirm Order and Pay',
    'paymentMethod': 'Payment Method',
    'cashOnDelivery': 'Cash on Delivery',
    'cashOnDeliveryHint': 'Pay in cash when your order arrives',
    'cardPayment': 'Pay by Card',
    'cardPaymentHint': 'Pay securely online with your card',
    'paymentRedirecting': 'Redirecting to secure payment...',
    'orderPlaced': 'Order placed successfully!',
    'orderFailed': 'Failed to place order. Try again.',
    'cartEmptyLogin': 'Your cart is empty',
    'myOrders': 'My Orders',
    'noOrdersYet': 'No orders yet',
    'orderNumber': 'Order #',
    'ordersWillAppearHere': 'Your orders will appear here',
    'track': 'Track',
    'tracking': 'Tracking',
    'liveTracking': 'Live Tracking',
    'trackingUnavailable': 'Tracking is not available for this order yet.',
    'waitingForDriver': 'Waiting for a driver to accept this order...',
    'driverOnTheWay': 'Your driver is on the way!',
    'driverInfo': 'Driver',
    'callDriver': 'Call driver',
    'openInMaps': 'Open in Maps',
    'restaurant': 'Restaurant',
    'yourOrder': 'Your order',
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
    'open': 'Open',
    'closed': 'Closed',
    'restaurantOpenHint': 'Customers can order from your restaurant',
    'restaurantClosedHint': 'Your restaurant is hidden from customers',
    'welcomeBackHello': 'Welcome back 👋',
    'offerPriceLessThanOriginal':
        'Offer price must be less than the original price',
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
    'editRestaurant': 'Edit Restaurant',
    'restaurantInfo': 'Restaurant Info',
    'restaurantName': 'Restaurant Name',
    'restaurantDescription': 'Description (optional)',
    'restaurantPhone': 'Phone (optional)',
    'chooseLogo': 'Choose Logo',
    'chooseCoverImage': 'Choose Cover Image',
    'changeLogo': 'Change Logo',
    'changeCoverImage': 'Change Cover Image',
    'orders': 'Orders',
    'orderDetails': 'Order Details',
    'newOrderReceived': 'New order received',
    'confirmOrder': 'Confirm Order',
    'startPreparing': 'Start Preparing',
    'outForDeliveryAction': 'Out for Delivery',
    'markCompleted': 'Mark Completed',
    'cancelOrder': 'Cancel Order',
    'live': 'Live',
    'offline': 'Offline',
    'reconnecting': 'Reconnecting...',
    'deliveries': 'Deliveries',
    'liveDelivery': 'Live Delivery Tracking',
    'selectOrder': 'Select an order',
    'noDeliveriesYet': 'No deliveries in transit right now',
    'noDeliveriesHint':
        'When an order is out for delivery, it will appear here',
    'kitchenMode': 'Kitchen Mode',
    'kitchenModeHint':
        'Large buttons, no prices — perfect for the kitchen screen',
    'sales': 'Sales',
    'salesDashboard': 'Sales Dashboard',
    'todayOrders': "Today's Orders",
    'todayRevenue': "Today's Revenue",
    'totalOrders': 'Total Orders',
    'totalRevenue': 'Total Revenue',
    'avgOrderValue': 'Avg Order Value',
    'topItems': 'Top Items',
    'statusBreakdown': 'Orders by Status',
    'revenueTrend': 'Last 7 Days',
    'pending': 'Pending',
    'completedOrders': 'Completed',
    'cancelledOrders': 'Cancelled',
    'noDataYet': 'No data yet',
    'deliverySettings': 'Delivery Settings',
    'deliverySettingsHint': 'These values apply to all your restaurants',
    'flatDeliveryFee': 'Flat Delivery Fee (SYP)',
    'deliveryFeePerKm': 'Delivery Fee per km (SYP)',
    'minOrderAmount': 'Minimum Order Amount (SYP)',
    'deliveryRadius': 'Delivery Radius (km)',
    'hasOwnDelivery': 'Use my own drivers',
    'hasOwnDeliveryHint': 'Assign deliveries to my own team',
    'deliveryDashboard': 'Delivery Dashboard',
    'availableDeliveries': 'Available',
    'myDeliveries': 'My Deliveries',
    'noAvailableDeliveries': 'No available deliveries right now',
    'noAvailableDeliveriesHint':
        'New requests will appear here when an order is ready',
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
    'driverPendingApprovalHint':
        'You can start delivering once your account is approved',
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
    'activeDelivery': 'Active Delivery',
    'reject': 'Reject',
    'rejectedSuccess': 'Delivery rejected',
    'cancelDeliveryConfirm': 'Reject this delivery request?',
    'earnings': 'Earnings',
    'dailyEarnings': "Today's Earnings",
    'weeklyEarnings': 'This Week',
    'totalTrips': 'Total Trips',
    'avgEarningPerTrip': 'Avg per Trip',
    'pickup': 'Pickup',
    'noEarningsYet': 'No earnings yet',
    'noEarningsHint': 'Complete deliveries to start earning',
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
    'staffManagement': 'Team Management',
    'staff': 'Staff',
    'addStaff': 'Add Staff Member',
    'staffName': 'Full Name',
    'temporaryPassword': 'Temporary Password',
    'staffAdded': 'Staff member added',
    'noStaffYet': 'No staff members yet',
    'noStaffHint':
        'Add your kitchen and service team. They sign in and manage orders from this app.',
    'forgotPassword': 'Forgot Password?',
    'forgotPasswordSubtitle': "Enter your email and we'll send you a reset link",
    'resetPassword': 'Reset Password',
    'emailSent': 'Email Sent',
    'checkYourEmail': 'Check your email for the reset link',
    'googleSignIn': 'Continue with Google',
    'orContinueWith': 'or continue with',
    'verificationEmailSent': 'Verification email sent',
    'checkInboxVerify': 'Check your inbox and verify your email, then tap below',
    'resendVerification': 'Resend Verification Email',
    'emailVerifiedSuccess': 'Email verified successfully!',
    'emailNotVerified': 'Email not verified yet. Check your inbox.',
    'googleSignInFailed': 'Google sign-in failed. Try again.',
    'resetPasswordFailed': 'Failed to send reset email. Try again.',
    'registrationFailed': 'Registration failed. Try again.',
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
    'placeOrder': 'تأكيد الطلب والدفع',
    'paymentMethod': 'طريقة الدفع',
    'cashOnDelivery': 'الدفع عند الاستلام',
    'cashOnDeliveryHint': 'ادفع نقداً عند استلام طلبك',
    'cardPayment': 'الدفع بالبطاقة',
    'cardPaymentHint': 'ادفع عبر الإنترنت ببطاقتك بشكل آمن',
    'paymentRedirecting': 'جارٍ فتح بوابة الدفع الآمنة...',
    'orderPlaced': 'تم تأكيد الطلب بنجاح!',
    'orderFailed': 'فشل تأكيد الطلب. حاول مرة أخرى.',
    'cartEmptyLogin': 'سلتك فارغة',
    'myOrders': 'طلباتي',
    'noOrdersYet': 'لا توجد طلبات بعد',
    'orderNumber': 'طلب #',
    'ordersWillAppearHere': 'ستظهر طلباتك هنا',
    'track': 'تتبّع',
    'tracking': 'تتبّع الطلب',
    'liveTracking': 'تتبّع مباشر',
    'trackingUnavailable': 'التتبّع غير متاح لهذا الطلب بعد.',
    'waitingForDriver': 'بانتظار قبول سائق لهذا الطلب...',
    'driverOnTheWay': 'سائقك في الطريق!',
    'driverInfo': 'السائق',
    'callDriver': 'اتصال بالسائق',
    'openInMaps': 'فتح في الخرائط',
    'restaurant': 'المطعم',
    'yourOrder': 'طلبك',
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
    'open': 'مفتوح',
    'closed': 'مغلق',
    'restaurantOpenHint': 'يمكن للعملاء الطلب من مطعمك',
    'restaurantClosedHint': 'مطعمك مخفي عن العملاء',
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
    'editRestaurant': 'تعديل المطعم',
    'restaurantInfo': 'معلومات المطعم',
    'restaurantName': 'اسم المطعم',
    'restaurantDescription': 'الوصف (اختياري)',
    'restaurantPhone': 'الهاتف (اختياري)',
    'chooseLogo': 'اختر الشعار',
    'chooseCoverImage': 'اختر صورة الغلاف',
    'changeLogo': 'تغيير الشعار',
    'changeCoverImage': 'تغيير صورة الغلاف',
    'orders': 'الطلبات',
    'orderDetails': 'تفاصيل الطلب',
    'newOrderReceived': 'وصل طلب جديد',
    'confirmOrder': 'تأكيد الطلب',
    'startPreparing': 'ابدأ التحضير',
    'outForDeliveryAction': 'خرج للتوصيل',
    'markCompleted': 'إتمام الطلب',
    'cancelOrder': 'إلغاء الطلب',
    'live': 'مباشر',
    'offline': 'غير متصل',
    'reconnecting': 'جارٍ إعادة الاتصال...',
    'deliveries': 'التوصيلات',
    'liveDelivery': 'تتبع التوصيل المباشر',
    'selectOrder': 'اختر طلباً',
    'noDeliveriesYet': 'لا توجد توصيلات قيد التنفيذ حالياً',
    'noDeliveriesHint': 'عند خروج طلب للتوصيل سيظهر هنا',
    'kitchenMode': 'وضع المطبخ',
    'kitchenModeHint': 'أزرار كبيرة بدون أسعار — مثالي لشاشة المطبخ',
    'sales': 'المبيعات',
    'salesDashboard': 'لوحة المبيعات',
    'todayOrders': 'طلبات اليوم',
    'todayRevenue': 'إيرادات اليوم',
    'totalOrders': 'إجمالي الطلبات',
    'totalRevenue': 'إجمالي الإيرادات',
    'avgOrderValue': 'متوسط قيمة الطلب',
    'topItems': 'الأصناف الأكثر طلباً',
    'statusBreakdown': 'الطلبات حسب الحالة',
    'revenueTrend': 'آخر 7 أيام',
    'pending': 'قيد الانتظار',
    'completedOrders': 'مكتملة',
    'cancelledOrders': 'ملغاة',
    'noDataYet': 'لا توجد بيانات بعد',
    'deliverySettings': 'إعدادات التوصيل',
    'deliverySettingsHint': 'تنطبق هذه القيم على جميع مطاعمك',
    'flatDeliveryFee': 'رسوم توصيل ثابتة (ل.س)',
    'deliveryFeePerKm': 'رسوم التوصيل لكل كيلومتر (ل.س)',
    'minOrderAmount': 'الحد الأدنى للطلب (ل.س)',
    'deliveryRadius': 'نطاق التوصيل (كم)',
    'hasOwnDelivery': 'استخدام سائقين خاصين بي',
    'hasOwnDeliveryHint': 'تعيين التوصيلات لفريقك الخاص',
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
    'driverPendingApprovalHint':
        'ستتمكن من استلام التوصيلات بعد الموافقة على حسابك',
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
    'activeDelivery': 'التوصيل النشط',
    'reject': 'رفض',
    'rejectedSuccess': 'تم رفض التوصيل',
    'cancelDeliveryConfirm': 'رفض طلب التوصيل هذا؟',
    'earnings': 'الأرباح',
    'dailyEarnings': 'أرباح اليوم',
    'weeklyEarnings': 'هذا الأسبوع',
    'totalTrips': 'إجمالي التوصيلات',
    'avgEarningPerTrip': 'متوسط لكل توصيلة',
    'pickup': 'الاستلام',
    'noEarningsYet': 'لا توجد أرباح بعد',
    'noEarningsHint': 'أكمل التوصيلات لبدء جني الأرباح',
    'updateAvailable': 'يتوفر تحديث جديد',
    'updateMessage':
        'يتوفر إصدار جديد من تطبيق طعميني. حمّله الآن للحصول على أحدث الميزات والتحسينات.',
    'updateNow': 'تحديث الآن',
    'later': 'لاحقاً',
    'installPromptTitle': 'تطبيق طعميني',
    'installPromptBody':
        'احصل على أفضل تجربة وسرعة في الطلب عبر تطبيق طعميني 🚀',
    'downloadAppNow': 'تحميل التطبيق الآن',
    'continueInBrowser': 'المتابعة عبر المتصفح',
    'staffManagement': 'إدارة الفريق',
    'staff': 'فريق العمل',
    'addStaff': 'إضافة عضو فريق',
    'staffName': 'الاسم الكامل',
    'temporaryPassword': 'كلمة مرور مؤقتة',
    'staffAdded': 'تمت إضافة العضو بنجاح',
    'noStaffYet': 'لا يوجد أعضاء في الفريق بعد',
    'noStaffHint':
        'أضف فريق المطبخ والخدمة. سيسجّلون الدخول ويديرون الطلبات من هذا التطبيق.',
    'forgotPassword': 'نسيت كلمة المرور؟',
    'forgotPasswordSubtitle': 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين',
    'resetPassword': 'إعادة تعيين كلمة المرور',
    'emailSent': 'تم إرسال البريد',
    'checkYourEmail': 'تحقق من بريدك الإلكتروني للحصول على رابط إعادة التعيين',
    'googleSignIn': 'المتابعة مع Google',
    'orContinueWith': 'أو تابع بـ',
    'verificationEmailSent': 'تم إرسال بريد التحقق',
    'checkInboxVerify': 'تحقق من صندوق بريدك وقم بالتحقق، ثم اضغط أدناه',
    'resendVerification': 'إعادة إرسال بريد التحقق',
    'emailVerifiedSuccess': 'تم التحقق من البريد بنجاح!',
    'emailNotVerified': 'لم يتم التحقق من البريد بعد. تحقق من صندوق بريدك.',
    'googleSignInFailed': 'فشل تسجيل الدخول عبر Google. حاول مرة أخرى.',
    'resetPasswordFailed': 'فشل إرسال بريد إعادة التعيين. حاول مرة أخرى.',
    'registrationFailed': 'فشل إنشاء الحساب. حاول مرة أخرى.',
  };

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
