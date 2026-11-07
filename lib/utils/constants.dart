/// Students sign up with this domain.
const String studentEmailDomain = 'alustudent.com';

/// ALU staff sign up with this domain. These accounts become staff automatically.
const String staffEmailDomain = 'alueducation.com';

/// Email domains that are allowed to register and log in.
const List<String> allowedEmailDomains = [studentEmailDomain, staffEmailDomain];

/// The campus photo used in the banner and on the login screens.
const String campusPhotoAsset = 'assets/images/school_logo.png';

/// Cloudinary account that stores report photos (approved by the facilitator).
/// These two values are not secrets. The API secret must never be in the app.
const String cloudinaryCloudName = 'lszoxzxr';
const String cloudinaryUploadPreset = 'jedag547';
