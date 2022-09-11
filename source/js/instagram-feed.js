const userFeed = new Instafeed({
  accessToken: '[token-here]',
  limit: 6,
  template: '<div class="col-xs-4 col-md-2 instafeed-col"><a href="{{link}}" target="_blank"><img class="instafeed" src="{{image}}" /></a></div>'
});
userFeed.run();
