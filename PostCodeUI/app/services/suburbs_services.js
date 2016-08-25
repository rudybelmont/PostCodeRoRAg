angular.module('myApp.suburbs.service', [])
.service('suburbsService', ['$http', '$q', 'roragConfig',
    function ($http, $q, roragConfig) {
      var suburbsService = {

        getSuburbsList: function () {
          var deferred = $q.defer();
          $http({
            url: roragConfig.apiUrl.suburbs + '/list',
            method: "GET"
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
