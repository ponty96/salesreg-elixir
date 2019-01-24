module.exports = {
  plugins: [
    require('autoprefixer')({
      browsers: [
        'Chrome >= 35', // Exact version number here is kinda arbitrary
        'Firefox >= 38', // Current Firefox Extended Support Release (ESR); https://www.mozilla.org/en-US/firefox/organizations/faq/
        'Edge >= 12',
        'Explorer >= 10',
        'iOS >= 8',
        'Safari >= 8',
        'Android 2.3',
        'Android >= 4',
        'Opera >= 12'
      ]
    }),
  ]
}
