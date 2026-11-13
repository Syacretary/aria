/// Conservative classifier for apps whose time belongs in ARIA's social
/// metrics. Unknown apps are excluded rather than guessed, so a browser or
/// work messenger never quietly becomes "social media".
abstract final class SocialApps {
  static const _packages = <String>{
    'com.zhiliaoapp.musically', // TikTok
    'com.ss.android.ugc.trill',
    'com.instagram.android',
    'com.facebook.katana',
    'com.twitter.android',
    'com.reddit.frontpage',
    'com.snapchat.android',
    'com.google.android.youtube',
    'com.pinterest',
  };

  static bool contains(String packageName) => _packages.contains(packageName);

  static String labelFor(String packageName) => switch (packageName) {
    'com.zhiliaoapp.musically' || 'com.ss.android.ugc.trill' => 'TikTok',
    'com.instagram.android' => 'Instagram',
    'com.facebook.katana' => 'Facebook',
    'com.twitter.android' => 'X',
    'com.reddit.frontpage' => 'Reddit',
    'com.snapchat.android' => 'Snapchat',
    'com.google.android.youtube' => 'YouTube',
    'com.pinterest' => 'Pinterest',
    _ => packageName,
  };
}
