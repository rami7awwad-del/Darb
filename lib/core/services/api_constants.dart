/// Base url and endpoint paths of the API.
class ApiConstants {
  static const String baseUrl =
      'https://training.tamkeen-dev.com/dareb/public/api';

  static const String login = '/auth/login';
  static const String resend = '/auth/resend';
  static const String active = '/auth/active';
  static const String logout = '/auth/logout';
  static const String deleteAccount = '/auth/delete';

  static const String profile = '/profile/get';
  static const String profilePoints = '/profile/points';
  static const String profileMedals = '/profile/medals';
  static const String profileCups = '/profile/cups';

  static const String usersEdit = '/users/edit';
  static const String userUpdate = '/users/update';
  static const String userUpdateImage = '/users/update-image';
  static const String topUsers = '/users/top';
  static const String topUserDetails = '/users/top-user-details';

  static const String homePageIndex = '/home-page/index';
  static const String homePageSearch = '/home-page/search';

  static const String slidersAll = '/sliders/all';
  static const String slidersPaginate = '/sliders/paginate';

  static const String newsAll = '/news/all';
  static const String newsPaginate = '/news/paginate';

  static const String galleriesAll = '/galleries/all';
  static const String galleriesPaginate = '/galleries/paginate';

  static const String governoratesAll = '/governorates/all';
  static const String schoolsAll = '/schools/all';

  static const String paymentMethodsAll = '/payment-methods/all';
  static const String stagesAll = '/stages/all';
  static const String branchesAll = '/branches/all';

  static const String subjectsAll = '/subjects/all';
  static const String subjectsPaginate = '/subjects/paginate';
  static const String subjectsDetails = '/subjects/details';

  static const String coursesPaginate = '/courses/paginate';
  static const String coursesDetails = '/courses/details';

  static const String lessonsDetails = '/lessions/details';
  static const String ytDlp = '/yt-dlp';
  static const String ytDlp720Audio = '/yt-dlp-720-audio';
  static const String lessonsAttend = '/lessions/attend-lession';
  static const String lessonsLastAttend =
      '/lessions/last-attend-lession';

  static const String packagesAll = '/packages/all';
  static const String packagesDetails = '/packages/details';

  static const String commentsGetByLession = '/comments/get-by-lession';
  static const String commentsAddComment = '/comments/add-comment';

  static const String examsMy = '/exams/my';
  static const String examsResult = '/exams/result';
  static const String examsAttend = '/exams/attend-exam';

  static const String dailyActivitiesMy = '/daily-activities/my';

  static const String subscriptionsMy = '/subscriptions/my';
  static const String subscriptionsCheckOutCode =
      '/subscriptions/check-out-code';
  static const String subscriptionsAdd = '/subscriptions/add';

  static const String notificationsGet = '/notifications/get';

  static const String faqsAll = '/faqs/all';

  static const String settingsAll = '/settings/all';
  static const String infosAll = '/infos/all';

  static const String contactUsAdd = '/contact-us/add';

  static const String pagesAll = '/pages/all';
  static const String pagesPrivacyPolicy = '/pages/privacy-policy';
  static const String pagesTermsConditions = '/pages/terms-conditions';
  static const String pagesAboutApplication = '/pages/about-application';
}
