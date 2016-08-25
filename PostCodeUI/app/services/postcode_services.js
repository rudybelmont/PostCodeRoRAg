angular.module('myApp.postcode.service', [])
.service('postcodeService', ['$http', '$q', 'roragConfig',
    function ($http, $q, roragConfig) {
      var suburbsService = {

        getPostCode: function (postcode) {
          var deferred = $q.defer();
          $http({
            url: roragConfig.apiUrl.postcode + '/search',
            method: "POST",
            data: {
              input: postcode
            }
          })
            .success(function (data) {
              deferred.resolve(data);
            })
            .error(function (xhr, StatusText, err) {
              deferred.reject(StatusText);
            });          
          return deferred.promise
        }

      };

      return suburbsService;
    }]);
