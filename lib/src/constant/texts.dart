class SMText {
  static bool isEnglish = true;
  static String languageCode = isEnglish ? "en" : "ar";

  static String get payWithCard => isEnglish ? "Pay By Card" : "ادفع عبر بطاقتك المصرفية";

  static String get somethingWentWrong => isEnglish ? "Something went wrong!!" : "حدث خطأ ما!!";

  static String get writeYourMessageHere => isEnglish ? "Write your message here ..." : "اكتب رسالتك هنا...";

  static String get attachFromLibrary => isEnglish ? "Attach from library" : "ارفاق من الملفات";
  static String get attachFromGallery => isEnglish ? "Attach from gallery" : "ارفاق من المعرض";

  static String get attachFile => isEnglish ? "Attach File" : "إرفاق ملف";

  static String get attachFromCamera => isEnglish ? "Picture from camera" : "صورة من الكاميرا";

  static String get reviewSentSuccessfully => isEnglish
      ? "Thank you for sharing, your review has been sent successfully"
      : "شكرًا لمشاركتك، تم إرسال تقييمك بنجاح";

  static String get rateTheConversation => isEnglish ? "Rate the conversation!" : "تقيم المحادثة!";

  static String get rateTheConversationDescription => isEnglish
      ? "We would like to know your opinion! Please rate your experience with our support service to help us improve our services."
      : "نود معرفة رأيك! من فضلك قيّم تجربتك مع خدمة الدعم لدينا لتساعدنا في تحسين خدماتنا.";

  static String get skipRating => isEnglish ? "Skip Rating" : "تخطي التقيم";

  static String get attached => isEnglish ? "Attached" : "مرفق";

  static String get cantReopenChat => isEnglish
      ? "7 days have passed !! The conversation cannot be reopened"
      : "لقد مر ٧ ايام !! لا يمكن اعادة فتح المحادثة";

  static String get reopen => isEnglish ? "Reopen" : "اعادة فتح";

  static String get supportAndHelp => isEnglish ? "Support & Help" : "الدعم والمساعدة";

  static String get supportAndHelpDescription => isEnglish
      ? "Your satisfaction is our priority. Contact us and you will receive a response as quickly as possible."
      : "خدمتك أولويتنا ، تواصل معنا وسيصلك الرد في أسرع وقت";

  static String get howCanWeHelpYou => isEnglish ? "How can we help you?" : "كيف يمكننا مساعدتك؟";

  static String get myMessages => isEnglish ? "My Messages" : "رسائلي";

  static String get startChat => isEnglish ? "Start Chat!" : "ابدأ المحادثة!";

  static String get workingHoursFrom => isEnglish ? "Working hours from" : "مواعيد العمل من";

  static String get startChatDescription => isEnglish ? "Start Conversation!" : "ابدأ المحادثة!";

  static String get online => isEnglish ? "Online" : "متصل الان";

  static String get noChats => isEnglish ? "No chats" : "لا يوجد محادثات";
  static String get repliedOn => isEnglish ? "replied on" : "إعادة الرد على";
  static String get supportTeam => isEnglish ? "Support Team" : "فريق المساعدة";

  /// Error Strings
  static String get badRequestError =>
      isEnglish ? 'Invalid request. Please check your input.' : 'طلب غير صحيح. يرجى التحقق من البيانات المدخلة.';
  static String get noContent => isEnglish ? 'No content available.' : 'لا يوجد محتوى متاح.';
  static String get forbiddenError =>
      isEnglish ? 'Access denied. You don\'t have permission.' : 'تم رفض الوصول. ليس لديك صلاحية.';
  static String get unauthorizedError =>
      isEnglish ? 'Authentication required. Please sign in.' : 'مطلوب تسجيل الدخول. يرجى تسجيل الدخول.';
  static String get notFoundError => isEnglish ? 'The requested resource was not found.' : 'المورد المطلوب غير موجود.';
  static String get conflictError =>
      isEnglish ? 'A conflict occurred. Please try again.' : 'حدث تضارب. يرجى المحاولة مرة أخرى.';
  static String get internalServerError =>
      isEnglish ? 'Server error. Please try again later.' : 'خطأ في الخادم. يرجى المحاولة لاحقاً.';
  static String get unknownError => isEnglish ? 'An unknown error occurred.' : 'حدث خطأ غير معروف.';
  static String get timeoutError =>
      isEnglish ? 'Connection timeout. Please check your internet.' : 'انتهت مهلة الاتصال. يرجى التحقق من الإنترنت.';
  static String get defaultError =>
      isEnglish ? 'Something went wrong. Please try again.' : 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';
  static String get cacheError => isEnglish ? 'Cache error occurred.' : 'حدث خطأ في التخزين المؤقت.';
  static String get noInternetError => isEnglish
      ? 'No internet connection. Please check your network.'
      : 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';
  static String get loadingMessage => isEnglish ? 'Loading...' : 'جاري التحميل...';
  static String get retryAgainMessage => isEnglish ? 'Retry' : 'إعادة المحاولة';
  static String get ok => isEnglish ? 'OK' : 'موافق';
  static String get tooManyRequests => isEnglish
      ? 'Too many requests. Please wait and try again.'
      : 'طلبات كثيرة جداً. يرجى الانتظار والمحاولة مرة أخرى.';

  // Additional error messages for session management
  static String get sessionStartError => isEnglish
      ? 'Failed to start chat session. Please try again.'
      : 'فشل في بدء جلسة المحادثة. يرجى المحاولة مرة أخرى.';
  static String get networkConnectionError => isEnglish
      ? 'Network connection failed. Please check your internet connection.'
      : 'فشل الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت.';
  static String get serverNotResponding =>
      isEnglish ? 'Server is not responding. Please try again later.' : 'الخادم لا يستجيب. يرجى المحاولة لاحقاً.';
  static String get dataParsingError => isEnglish
      ? 'Invalid data received from server. Please try again.'
      : 'تم استلام بيانات غير صحيحة من الخادم. يرجى المحاولة مرة أخرى.';
  static String get missingDataError =>
      isEnglish ? 'Required data is missing from server response.' : 'البيانات المطلوبة مفقودة من استجابة الخادم.';

  static String get formatError => isEnglish ? "Error in Data Format" : "خطأ في تنسيق البيانات";

  // Login requirement messages
  static String get loginRequired => isEnglish ? "Please login!" : "يرجى تسجل الدخول!";
  static String get loginRequiredMessage => isEnglish
      ? "For continued access to messages and all our services, please login to your account."
      : "للاستمرار في عرض الرسائل  والاستفادة من جميع خدماتنا، يرجى تسجيل الدخول إلى حسابك.";
  static String get login => isEnglish ? "Login" : "تسجيل الدخول";
  static String get loginNow => isEnglish ? "Login Now" : "تسجيل الدخول الآن";
  static String get loginNow2 => isEnglish ? "Login Now" : "سجل الدخول الآن";

  static String get dontHaveAccount => isEnglish ? "Don't have an account," : "ليس لدي حساب,";
  static String get createNewAccount => isEnglish ? "Create New Account" : "إنشاء حساب جديد";

  static String get weWillSendYouAVerificationCodeInATextMessage =>
      isEnglish ? "We will send you a verification code in a text message" : "سنرسل لك رمز التحقق في رسالة نصية";

  static String get chooseTheCountry => isEnglish ? "Choose the country" : "اختر الدولة";
  static String get apply => isEnglish ? "Apply" : "اعتماد";

  static String get searchForTheCountry => isEnglish ? "Search for the country" : "ابحث عن الدولة";

  static String get noAccount => isEnglish ? "No account?" : "لا يوجد حساب؟";

  static String get confirmIdentity => isEnglish ? "Confirm Identity!" : "تأكيد الهوية!";

  static String get enterTheVerificationCodeSentToYourPhone =>
      isEnglish ? "Enter the verification code sent to your phone" : "قم بإدخال رمز التحقق المرسل إلى هاتفك";

  static String get remainingTime => isEnglish ? "Remaining Time:" : "الوقت المتبقي:";

  static String get second => isEnglish ? "second" : "ثانية";

  static String get didNotReceiveTheCode => isEnglish ? "Did not receive the code?" : "لم يصلني الرمز؟";

  static String get sendNewCode => isEnglish ? "Send New Code" : "أرسل رمز جديد";

  static String get ensuringProtectionAndSafetyForASafeUsageExperience => isEnglish
      ? "Ensuring protection and safety for a safe usage experience."
      : "ضمان الحماية والأمان لتجربة استخدام آمنة.";

  static String get wrongVerificationCode =>
      isEnglish ? "Wrong verification code, try again." : "رمز التحقق المدخل خاطئ, حاول مجدداً.";

  static String get thereIsAnAccount => isEnglish ? "There is an account?" : "يوجد لديك حساب؟";

  static String get loginToYourAccount => isEnglish ? "Login to your account" : "سجل دخول";

  static String get registerNow => isEnglish ? "Register Now" : "سجّل الآن!";

  static String get confirmIdentityToCompleteTheProcess =>
      isEnglish ? "Confirm Identity to complete the process" : "تأكيد الهوية لاستكمال العملية";

  static String get identityConfirmed => isEnglish ? "Identity Confirmed" : "تم توثيق الهوية";

  static String get identityNotConfirmed => isEnglish ? "Identity Not Confirmed" : "فشل في توثيق الهوية";

  static String get tellUsMoreAboutYourExperience =>
      isEnglish ? "Tell us more about your experience.." : "أخبرنا بالمزيد عن تجربتك..";

  static String get submitRating => isEnglish ? "Submit Rating" : "اعتمد التقييم";

  static String get closedSessions => isEnglish ? "Session closed" : "تم إغلاق الجلسة";

  static String get reopenSession => isEnglish ? "Session reopened" : "تم إعادة فتح الجلسة";

  static String get sessionClosedBySystem => isEnglish ? "Session closed by system" : "تم إغلاق الجلسة بواسطة النظام";

  static String get hour => isEnglish ? "hr" : "ساعة";

  static String get minute => isEnglish ? "min" : "دقيقة";

  static String get day => isEnglish ? "d" : "يوم";

  static String get month => isEnglish ? "mo" : "شهر";

  static String get year => isEnglish ? "y" : "سنة";

  static String get s => isEnglish ? "s" : "s";

  // Media message strings
  static String get video => isEnglish ? "Video" : "فيديو";
  static String get audioMessage => isEnglish ? "Audio Message" : "رسالة صوتية";
  static String get uploading => isEnglish ? "Uploading..." : "جاري الرفع...";
  static String get tapToPlay => isEnglish ? "Tap to play" : "اضغط للتشغيل";
  static String get unsupportedAttachment => isEnglish ? "Unsupported attachment" : "مرفق غير مدعوم";

  // Video player strings
  static String get videoPlayer => isEnglish ? "Video Player" : "مشغل الفيديو";
  static String get loadingVideo => isEnglish ? "Loading video..." : "جاري تحميل الفيديو...";
  static String get failedToLoadVideo => isEnglish ? "Failed to load video" : "فشل تحميل الفيديو";
  static String get retry => isEnglish ? "Retry" : "إعادة المحاولة";
  static String get videoPlayerNotAvailable => isEnglish ? "Video player not available" : "مشغل الفيديو غير متاح";
}
