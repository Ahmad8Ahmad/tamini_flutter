import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  // ── Common ──────────────────────────────────────────────────
  String get appName => isArabic ? 'طعميني' : 'Tamini';
  String get loading => isArabic ? 'جاري التحميل...' : 'Loading...';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get done => isArabic ? 'تم' : 'Done';
  String get back => isArabic ? 'رجوع' : 'Back';
  String get next => isArabic ? 'التالي' : 'Next';
  String get or => isArabic ? 'أو' : 'or';
  String get requiredField => isArabic ? 'هذا الحقل مطلوب' : 'This field is required';

  // ── Auth ────────────────────────────────────────────────────
  String get login => isArabic ? 'تسجيل الدخول' : 'Login';
  String get register => isArabic ? 'إنشاء حساب' : 'Register';
  String get logout => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get confirmPassword => isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get username => isArabic ? 'اسم المستخدم' : 'Username';
  String get phone => isArabic ? 'الهاتف' : 'Phone';
  String get phoneOptional => isArabic ? 'الهاتف (اختياري)' : 'Phone (optional)';
  String get welcomeBack => isArabic ? 'مرحباً بعودتك' : 'Welcome Back';
  String get signInToContinue => isArabic ? 'سجّل دخولك للمتابعة' : 'Sign in to continue';
  String get dontHaveAccount => isArabic ? 'ليس لديك حساب؟' : "Don't have an account?";
  String get alreadyHaveAccount => isArabic ? 'لديك حساب بالفعل؟' : 'Already have an account?';
  String get createAccount => isArabic ? 'إنشاء حساب جديد' : 'Create New Account';
  String get registerAs => isArabic ? 'أنا...' : 'I am a...';
  String get customer => isArabic ? 'عميل' : 'Customer';
  String get restaurantOwner => isArabic ? 'صاحب مطعم' : 'Restaurant Owner';
  String get deliveryDriver => isArabic ? 'سائق توصيل' : 'Delivery Driver';
  String get loginFailed => isArabic ? 'فشل تسجيل الدخول. تحقق من بياناتك.' : 'Login failed. Check credentials.';
  String get registerFailed => isArabic ? 'فشل التسجيل. حاول مرة أخرى.' : 'Registration failed. Try again.';
  String get passwordMin6 => isArabic ? '6 أحرف على الأقل' : 'Min 6 characters';
  String get passwordsDontMatch => isArabic ? 'كلمتا المرور غير متطابقتين' : "Passwords don't match";
  String get enterValidEmail => isArabic ? 'أدخل بريداً إلكترونياً صالحاً' : 'Enter valid email';

  // ── OTP ─────────────────────────────────────────────────────
  String get verifyEmail => isArabic ? 'التحقق من البريد' : 'Verify Email';
  String get enterVerificationCode => isArabic ? 'أدخل رمز التحقق' : 'Enter Verification Code';
  String get otpSentTo => isArabic ? 'أرسلنا رمز مكون من 6 أرقام إلى' : 'We sent a 6-digit code to';
  String get verify => isArabic ? 'تحقق' : 'Verify';
  String get invalidOtp => isArabic ? 'رمز غير صالح أو منتهي الصلاحية.' : 'Invalid or expired OTP.';

  // ── Home ────────────────────────────────────────────────────
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get searchFood => isArabic ? 'ابحث عن طعام...' : 'Search food...';
  String get restaurants => isArabic ? 'المطاعم' : 'Restaurants';
  String get trendy => isArabic ? 'رائج' : 'Trendy';
  String get viewAll => isArabic ? 'عرض الكل' : 'View All';
  String get addToCart => isArabic ? 'أضف للسلة' : 'Add to Cart';
  String get addedToCart => isArabic ? 'تمت الإضافة للسلة' : 'Added to cart';
  String get categories => isArabic ? 'الأقسام' : 'Categories';
  String get popularItems => isArabic ? 'الأكثر طلباً' : 'Popular Items';

  // ── Restaurant ──────────────────────────────────────────────
  String get menu => isArabic ? 'القائمة' : 'Menu';
  String get rating => isArabic ? 'تقييم' : 'rating';
  String get description => isArabic ? 'الوصف' : 'Description';

  // ── Cart ────────────────────────────────────────────────────
  String get myCart => isArabic ? 'سلتي' : 'My Cart';
  String get cartEmpty => isArabic ? 'سلتك فارغة' : 'Your cart is empty';
  String get checkout => isArabic ? 'إتمام الطلب' : 'Checkout';
  String get items => isArabic ? 'عنصر' : 'items';
  String get each => isArabic ? 'لكل' : 'each';
  String get total => isArabic ? 'المجموع' : 'Total';
  String get deliveryFee => isArabic ? 'رسوم التوصيل' : 'Delivery Fee';
  String get subtotal => isArabic ? 'المجموع الفرعي' : 'Subtotal';

  // ── Checkout ────────────────────────────────────────────────
  String get deliveryDetails => isArabic ? 'تفاصيل التوصيل' : 'Delivery Details';
  String get yourName => isArabic ? 'اسمك' : 'Your Name';
  String get deliveryAddress => isArabic ? 'عنوان التوصيل' : 'Delivery Address';
  String get orderSummary => isArabic ? 'ملخص الطلب' : 'Order Summary';
  String get placeOrder => isArabic ? 'تأكيد الطلب' : 'Place Order';
  String get orderPlaced => isArabic ? 'تم تأكيد الطلب بنجاح!' : 'Order placed successfully!';
  String get orderFailed => isArabic ? 'فشل تأكيد الطلب. حاول مرة أخرى.' : 'Failed to place order. Try again.';
  String get cartEmptyLogin => isArabic ? 'سلتك فارغة' : 'Your cart is empty';

  // ── Orders ──────────────────────────────────────────────────
  String get myOrders => isArabic ? 'طلباتي' : 'My Orders';
  String get noOrdersYet => isArabic ? 'لا توجد طلبات بعد' : 'No orders yet';
  String get orderNumber => isArabic ? 'طلب #' : 'Order #';

  // ── Profile ─────────────────────────────────────────────────
  String get profile => isArabic ? 'الحساب' : 'Profile';
  String get notLoggedIn => isArabic ? 'لم تسجّل الدخول' : 'Not logged in';
  String get address => isArabic ? 'العنوان' : 'Address';

  // ── Support / Contact ───────────────────────────────────────
  String get contactUs => isArabic ? 'تواصل معنا' : 'Contact Us';
  String get contactSubtitle => isArabic ? 'نحن هنا لمساعدتك' : "We're here to help";
  String get subject => isArabic ? 'الموضوع' : 'Subject';
  String get yourNameField => isArabic ? 'الاسم' : 'Your Name';
  String get subjectHint => isArabic ? 'ملخص المشكلة' : 'Brief summary';
  String get descriptionHint => isArabic ? 'اشرح المشكلة بالتفصيل...' : 'Describe the issue in detail...';
  String get send => isArabic ? 'إرسال' : 'Send';
  String get ticketSent => isArabic ? 'تم إرسال طلبك بنجاح!' : 'Your request was sent successfully!';
  String get ticketFailed => isArabic ? 'فشل الإرسال. حاول مرة أخرى.' : 'Failed to send. Try again.';
  String get callUs => isArabic ? 'اتصل بنا' : 'Call Us';
  String get emailUs => isArabic ? 'راسلنا' : 'Email Us';
  String get whatsapp => isArabic ? 'واتساب' : 'WhatsApp';
  String get contactInfo => isArabic ? 'معلومات التواصل' : 'Contact Info';
  String get followUs => isArabic ? 'تابعنا' : 'Follow Us';

  // ── Status ──────────────────────────────────────────────────
  String statusText(String status) {
    if (!isArabic) return status;
    switch (status) {
      case 'Pending': return 'قيد الانتظار';
      case 'Confirmed': return 'تم التأكيد';
      case 'Preparing': return 'جاري التحضير';
      case 'Out for Delivery': return 'خرج للتوصيل';
      case 'Delivered': return 'تم التوصيل';
      case 'Cancelled': return 'تم الإلغاء';
      default: return status;
    }
  }

  String formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
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
