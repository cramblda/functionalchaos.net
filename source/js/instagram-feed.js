
var userFeed = new Instafeed({
    get: 'user',
    userId: '2007402176',
    accessToken: '2007402176.1677ed0.68c78b6fda7544349f562a84676bc26d',
    resolution: 'standard_resolution',
    limit: 6,
    sortBy: 'most-recent',
    template: '<div class="col-xs-4 col-md-2 instafeed-col"><a href="{{link}}" target="_blank"><img class="instafeed" src="{{image}}" /></a></div>'
});
userFeed.run();
