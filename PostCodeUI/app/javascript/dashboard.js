'use strict';

angular.module('myApp.dashboard', ['ngRoute'])

  .config(['$routeProvider', function ($routeProvider) {
    $routeProvider.when('/dashboard', {
      templateUrl: 'views/dashboard.html',
      controller: 'DashboardCtrl'
    });
  }])

  .controller('DashboardCtrl', ['$scope', 'suburbsService', 'postcodeService', function ($scope, suburbsService, postcodeService) {
    function initialize() {
      var mapProp = {
        center: { lat: -23.9414689, lng: 133.5207984 },
        zoom: 4
      };

      var map = new google.maps.Map(document.getElementById("googleMap"), mapProp);

      map.data.setStyle({
        strokeColor: '#ff3333',
        strokeWeight: 2,
        clickable: true
      });
    }

    google.maps.event.addDomListener(window, 'load', initialize);

    var suburbsList = [];
    suburbsService.getSuburbsList().then(function (result) {
      $.each(result, function (index, item) {
        suburbsList.push({ label: item.table.name, value: item.table.postcode })

        if (suburbsList.length === result.length) {
          $('#postCodeBox').autocomplete({
            source: suburbsList
          });
        };

      });
    });

    $scope.searchByPostCode = function () {
      var inputValue = $('#postCodeBox').val().toString().trim().toLowerCase();

      if (inputValue.length !== 0) {
        postcodeService.getPostCode(inputValue).then(function (result) {
          var centerMap = new google.maps.LatLng(result.max_lat, result.max_lng)

          var mapProp = {
            center: centerMap,
            zoom: 12,
            mapTypeId: 'terrain'
          };

          var map = new google.maps.Map(document.getElementById("googleMap"), mapProp);

          // Define the LatLng coordinates for the polygon's path.
          var PolygonCoords = [];
          //PolygonCoords = result.boundary.geometry.coordinates;
          $.each(result.boundary.geometry.coordinates, function (index, item) {

            $.each(item, function (index, coor) {
              PolygonCoords.push({ lng: coor[0], lat: coor[1] })
            })
          });

        var PolygonCoordsNew = $.extend(true, [], PolygonCoords);
        
        var polygonDraw = new google.maps.Polygon({
            paths: PolygonCoordsNew,
            strokeColor: '#FF0000',
            strokeOpacity: 0.8,
            strokeWeight: 3,
            fillColor: '#FF0000',
            fillOpacity: 0.35
          });
          polygonDraw.setMap(map);

        });

      }
    }

  }]);
