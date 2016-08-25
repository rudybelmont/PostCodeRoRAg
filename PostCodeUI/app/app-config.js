'use strict';

angular.module('myApp.config', []).factory('roragConfig',
  function () {
    var baseApiUrl = 'http://' + window.location.hostname + ':3000';
    var baseClientUrl = 'http://' + window.location.host;

    var configService = {
      apiUrl: {

        suburbs: baseApiUrl + '/api/v1/suburbs',
        state: baseApiUrl + '/api/v1/state',
        admin: baseApiUrl + '/admin',
        postcode: baseApiUrl + '/api/v1/postcodes'
      },
    };

    return configService;
  });
