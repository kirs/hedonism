function markerIcon() {
  return {
    path: google.maps.SymbolPath.CIRCLE,
    fillColor: 'red',
    fillOpacity: .6,
    scale: 4.5,
    strokeColor: 'white',
    strokeWeight: 1
  };
}

function codeAddress(map, address) {
  return new Promise(function(resolve, reject) {
    geocoder = new google.maps.Geocoder();
    geocoder.geocode( { address: address}, function(results, status) {
      if (status == 'OK') {
        resolve(results[0]);
        map.setCenter(results[0].geometry.location);
        var marker = new google.maps.Marker({
          map: map,
          position: results[0].geometry.location,
          icon: markerIcon(),
        });
      } else {
        reject('Geocode was not successful for the following reason: ' + status);
      }
    });
  });
}

function initMap() {
  var uluru = { lat: -25.363, lng: 131.044 };
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 4,
    center: uluru
  });
  initApp(map);
}

function countryFromResult(result) {
  var country;
  result.address_components.forEach(function(part) {
    if(part.types[0] == "country") {
      country = part.long_name;
    }
  })
  return country;
}

function createInfoWindow(map, marker, point) {
 var contentString = '<div id="content">'+
      '<a class="js-drop-marker" href="javascript:;" data-hash="' + point.hash + '">Delete</a>'+
      '</div>';

  var infowindow = new google.maps.InfoWindow({
    content: contentString
  });
  if(window.InfoWindowState) window.InfoWindowState.infoWindow.close();
  window.InfoWindowState = {
    marker: marker,
    infoWindow: infowindow,
  };
  infowindow.open(map, marker);
}

function loadMarkers(map) {
  fetch("/points").then(function(response) {
    return response.json();
  }).then(function(points) {
    window.markers = [];
    var bounds = new google.maps.LatLngBounds();
    points.forEach(function(point) {
      var marker = new google.maps.Marker({
        map: map,
        position: new google.maps.LatLng(point.lat, point.lng),
        title: point.full_address,
        icon: markerIcon(),
      });
      bounds.extend(marker.position);
      window.markers.push(marker);

      marker.addListener('click', function() {
        createInfoWindow(map, marker, point);
      });
    })
    map.fitBounds(bounds);
  });
}

function persistPoint(point, query) {
  var form_data = new FormData();
  form_data.append("query", query);
  form_data.append("lat", point.geometry.location.lat());
  form_data.append("lng", point.geometry.location.lng());
  form_data.append("country", countryFromResult(point));
  form_data.append("full_address", point.formatted_address);

  fetch('/submit', { method: 'POST', body: form_data });
}

function initApp(map) {
  var field = document.querySelector('.address-field');

  $(document).on("click", ".js-drop-marker", function(e) {
    window.InfoWindowState.infoWindow.close();
    window.InfoWindowState.marker.setMap(null);

    var hash = e.target.dataset['hash'];
    fetch("/points/" + hash, { method: 'DELETE' });
  });

  loadMarkers(map);
  field.onkeypress = function(e) {
    if(e.which == 13) { // enter
      field.disabled = true;
      var query = field.value;
      codeAddress(map, query).then(function(result) {
        field.disabled = false;
        field.value = "";
        field.focus();
        window.lastResult = result;
        persistPoint(result, query);
      }).catch(function(err) {
        field.disabled = false;
        field.focus();
        console.log(err);
      });
    }
  }
}
