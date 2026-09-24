class ApiConstants {
  static const String baseUrl = 'https://training.tamkeen-dev.com/dareb/public/api';

  // Auth
  static const String login = '/auth/login'; // POST
  static const String resend = '/auth/resend'; // POST
  static const String active = '/auth/active'; // POST
  static const String logout = '/auth/logout'; // GET
  static const String deleteAccount = '/auth/delete'; // POST

  // Profile
  static const String profile = '/profile/get'; // GET
  static const String profilePoints = '/profile/points'; // GET
  static const String profileMedals = '/profile/medals'; // GET
  static const String profileCups = '/profile/cups'; // GET

  // Users
  static const String userEdit = '/users/edit'; // POST
  static const String userUpdate = '/users/update'; // POST
  static const String userUpdateImage = '/users/update-image'; // POST
  static const String topUsers = '/users/top'; // GET
  static const String topUserDetails = '/users/top-user-details'; // GET

  // Home
  static const String homePageIndex = '/home-page/index'; // GET
  static const String homePageSearch = '/home-page/search'; // GET

  // Sliders
  static const String slidersAll = '/sliders/all'; // GET
  static const String slidersPaginate = '/sliders/paginate'; // GET

  // News
  static const String newsAll = '/news/all'; // GET
  static const String newsPaginate = '/news/paginate'; // GET

  // Gallery
  static const String galleriesAll = '/galleries/all'; // GET
  static const String galleriesPaginate = '/galleries/paginate'; // GET

  // Schools
  static const String governoratesAll = '/governorates/all'; // GET
  static const String schoolsAll = '/schools/all'; // GET

  // Lookups
  static const String paymentMethodsAll = '/payment-methods/all'; // GET
  static const String stagesAll = '/stages/all'; // GET
  static const String branchesAll = '/branches/all'; // GET

  // Subjects
  static const String subjectsAll = '/subjects/all'; // GET
  static const String subjectsPaginate = '/subjects/paginate'; // GET
  static const String subjectsDetails = '/subjects/details'; // GET

  // Courses
  static const String coursesPaginate = '/courses/paginate'; // GET
  static const String coursesDetails = '/courses/details'; // GET

  // Lessons
  static const String lessonsDetails = '/lessions/details'; // GET
  static const String ytDlp = '/yt-dlp'; // GET
  static const String ytDlp720Audio = '/yt-dlp-720-audio'; // GET
  static const String lessonsAttend = '/lessions/attend-lession'; // POST
  static const String lessonsLastAttend = '/lessions/last-attend-lession'; // POST

  // Packages
  static const String packagesAll = '/packages/all'; // GET
  static const String packagesDetails = '/packages/details'; // GET

  // Comments
  static const String commentsGetByLession = '/comments/get-by-lession'; // GET
  static const String commentsAddComment = '/comments/add-comment'; // POST

  // Exams
  static const String examsMy = '/exams/my'; // GET
  static const String examsResult = '/exams/result'; // GET
  static const String examsAttend = '/exams/attend-exam'; // POST

  // Daily activities
  static const String dailyActivitiesMy = '/daily-activities/my'; // GET

  // Subscriptions
  static const String subscriptionsMy = '/subscriptions/my'; // GET
  static const String subscriptionsCheckOutCode = '/subscriptions/check-out-code'; // GET
  static const String subscriptionsAdd = '/subscriptions/add'; // POST

  // Notifications
  static const String notificationsGet = '/notifications/get'; // GET

  // Faqs
  static const String faqsAll = '/faqs/all'; // GET

  // Settings
  static const String settingsAll = '/settings/all'; // GET
  static const String infosAll = '/infos/all'; // GET

  // Contact
  static const String contactUsAdd = '/contact-us/add'; // POST

  // Pages
  static const String pagesAll = '/pages/all'; // GET
  static const String pagesPrivacyPolicy = '/pages/privacy-policy'; // GET
  static const String pagesTermsConditions = '/pages/terms-conditions'; // GET
  static const String pagesAboutApplication = '/pages/about-application'; // GET
}