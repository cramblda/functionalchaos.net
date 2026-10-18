// InstagramToken comes from the Instant Tokens token.js script (site.instagram.token_url). If that script fails
// (expired subscription, de-authorized account), the token is missing and the section stays hidden.
(function () {
  if (typeof InstagramToken === 'undefined' || !InstagramToken) {
    console.warn('Instagram feed: no token from Instant Tokens; feed hidden.');
    return;
  }

  const userFeed = new Instafeed({
    accessToken: InstagramToken,
    limit: 6,
    template: '<div class="col-4 col-lg-2 instafeed-col"><a href="{{link}}" target="_blank"><img class="instafeed" src="{{image}}" /></a></div>',
    after: function () {
      if (document.getElementById('instafeed').children.length) {
        document.getElementById('instagram-section').style.display = '';
      }
    },
    error: function (err) {
      console.warn('Instagram feed: ' + err.message + '; feed hidden.');
    }
  });
  userFeed.run();
})();
