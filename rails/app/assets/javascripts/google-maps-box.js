var shiftClicked = false;
var map;
var dragging = false;
var rect;
var pos1, pos2;
function initMap(selector) {
  var latlng = new google.maps.LatLng(0,0);
  var settings = {
      zoom: 2,
      center: latlng,
      mapTypeControl: true,
      navigationControl: true,
      streetViewControl: false,
      mapTypeControl: false,
      scaleControl: false,
      overviewMapControl: false,
      disableDefaultUI: true,
      navigationControlOptions: {
          style: google.maps.NavigationControlStyle.SMALL
      },
      mapTypeId: google.maps.MapTypeId.ROADMAP
  }
  var mapElem = $(selector);
  map = new google.maps.Map(mapElem[0], settings);
  rect = new google.maps.Rectangle({
              map: map,
              fillColor: '#496BBE',
              strokeColor: "#496BBE",
              strokeOpacity: 1.0,
              strokeWeight: 2,
              editable: true
          });

  google.maps.event.addListener(rect, 'bounds_changed', function(mEvent) {
    updateLocationVal();
  });

  google.maps.event.addListener(map, 'mousedown', function(mEvent) {
    e = window.event;
    if (e.shiftKey) {
      map.draggable = false;
      latlng1 = mEvent.latLng;
      dragging = true;
      pos1 = mEvent.pixel;
    };
  });

  google.maps.event.addListener(map, 'mousemove', function(mEvent) {
    map.draggable = true;
    latlng2 = mEvent.latLng;
    // console.log(mEvent);
    showRect();
  });

  google.maps.event.addListener(map, 'mouseup', function(mEvent) {
    map.draggable = true;
    dragging = false;
  });

  google.maps.event.addListener(rect, 'mouseup', function(data) {
    map.draggable = true;
    dragging = false;
  });

}

function updateLocationVal() {
  var minLat = roundTo(rect.getBounds().getSouthWest().lat(), 3);
  var maxLat = roundTo(rect.getBounds().getNorthEast().lat(), 3);
  var minLng = roundTo(rect.getBounds().getSouthWest().lng(), 3);
  var maxLng = roundTo(rect.getBounds().getNorthEast().lng(), 3);
  $('#latlon').val(minLng+","+maxLat+","+maxLng+","+minLat);
}

function roundTo(val, place) {
  return Math.round(val*Math.pow(10,place))/Math.pow(10,place);
}

function showRect() {
  if (dragging){
    if (rect === undefined) {
      rect = new google.maps.Rectangle({
        map: map,
        fillColor: '#496BBE',
        strokeColor: "#FF0000",
        strokeOpacity: 1.0,
        strokeWeight: 2,
        editable: true
      });
    };
    var latLngBounds = new google.maps.LatLngBounds(latlng1, latlng2);
    rect.setBounds(latLngBounds);
    updateLocationVal();
  };
}
