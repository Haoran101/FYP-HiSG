/*
    Information about server communication. This sample webservice is provided by Wikitude and returns random dummy
    Places near given location.
*/

var World = {

    /* You may request new data from server periodically, however: in this sample data is only requested once. */
    isRequestingData: false,

    /* True once data was fetched. */
    initiallyLoadedData: false,

    /* Different POI-Marker assets. */
    markerDrawableIdle: null,
    markerDrawableSelected: null,
    markerDrawableDirectionIndicator: null,

    destinLat: 1.343212,
    destinLon: 103.682586,
    route: null,
    markerList: [],

    /* the last selected marker. */
    currentMarker: null,
    currentDistance: null,
    currentDuration: null,

    /* Called to inject new POI data. */
    loadMarkersFromRoute: function loadMarkersFromRouteFn() {

        World.markerList.forEach((m) => { m.markerObject.destroy(); }
        );
        /* Empty list of visible markers. */
        World.markerList = [];

        /* Start loading marker assets. */
        World.markerDrawableIdle = new AR.ImageResource("assets/empty.png", {
            onError: World.onError
        });
        World.markerDrawableSelected = new AR.ImageResource("assets/poi.png", {
            onError: World.onError,
            innerHeight: 5
        });
        World.markerDrawableDirectionIndicator = new AR.ImageResource("assets/indi.png", {
            onError: World.onError
        });

        routeData = World.route;
        /* Loop through POI-information and create an AR.GeoObject (=Marker) per POI. */
        for (var currentPlaceNr = 0; currentPlaceNr < routeData.length; currentPlaceNr++) {

            var singlePoi = {
                "id": currentPlaceNr,
                "latitude": parseFloat(routeData[currentPlaceNr].end_point.lat()),
                "longitude": parseFloat(routeData[currentPlaceNr].end_point.lng()),
                "altitude": 100.0,
                "instruction": routeData[currentPlaceNr].instructions,
                "distance": routeData[currentPlaceNr].distance.value,
                "duration": routeData[currentPlaceNr].duration.value,
                "speed": routeData[currentPlaceNr].distance.value / routeData[currentPlaceNr].duration.value,
                "details": routeData[currentPlaceNr]
            };
            World.markerList.push(new Marker(singlePoi));
        }

        World.switchInstructions(0);
        World.updateStatusMessage('Route loaded from Google Maps.');
    },

    /*on received destination info from Architect Widget*/
    initializeDestination: function initializeDestinationFn(destinationJSON){
        print(destinationJSON);
    },

    /* updates status message as total duration remaining */
    updateTotalStatusMessage: function updateTotalStatusFn(){
        if (World.markerList.length == 0) return;
        var startId = World.currentMarker.poiData.id + 1;
        var sumDistance = World.currentDistance;
        var sumDuration = World.currentDuration;
        while (startId < World.markerList.length){
            sumDistance += World.markerList[startId].poiData.distance;
            sumDuration += World.markerList[startId].poiData.duration;
        }
        var distanceDisplay = sumDistance < 1000? Math.round(sumDistance) + " m" : (sumDistance/1000).toFixed(2) + " km";
        var durationDisplay = Math.ceil(sumDuration / 60) + " min";
        World.updateStatusMessage("Remaining Distance: " + distanceDisplay + ", Remaining Time: " + durationDisplay);
    },

    /* Updates status message shown in small "i"-button aligned bottom center. */
    updateStatusMessage: function updateStatusMessageFn(message, isWarning) {
        document.getElementById("popupButtonImage").src = isWarning ? "assets/warning_icon.png" : "assets/info_icon.png";
        document.getElementById("popupButtonTooltip").innerHTML = message;
    },

    /* Updates instruction message */
    updateInstructionMessage: function updateInstructionMessageFn(instruction) {
        document.getElementById("instruction").innerHTML = instruction;
    },

    /* Updates Distance and Duration display */
    updateDistanceAndDurationDisplay: function updateDistanceAndDurationDisplayFn(distance, duration) {
        var distanceDisplay = distance < 1000? Math.round(distance) + " m" : (distance/1000).toFixed(2) + " km";
        var durationDisplay = Math.ceil(duration / 60) + " min";
        document.getElementById("distance").innerHTML = distanceDisplay;
        document.getElementById("duration").innerHTML = durationDisplay;
    },

    /* get Updated Distance and Duration values */
    fetchUpdatedDistanceAndDuration: function fetchUpdatedDistanceAndDurationFn(lat, lon){
        var distance = getDistanceFromLatLonInM(lat, lon, World.currentMarker.poiData.latitude, World.currentMarker.poiData.longitude);
        if (distance < 15){
            World.switchInstructions(World.currentMarker.id + 1);
        } else {
            World.currentDistance = distance;
            World.currentDuration = distance / World.currentMarker.poiData.speed;
        }
    },

    /* Switch to next marker */
    switchInstructions: function switchInstructionsFn(nextId){
        if (World.currentMarker != null){
            World.currentMarker.setDeselected(World.currentMarker);
        }
        var nextMarker = World.markerList[nextId];
        nextMarker.setSelected(nextMarker);
        World.currentMarker = nextMarker;
        World.updateInstructionMessage(World.currentMarker.poiData.instruction);
        World.currentDistance = World.currentMarker.poiData.distance;
        World.currentDuration = World.currentMarker.poiData.duration;
    },

    /* User clicked "More" button in POI-detail panel -> fire event to open native screen. */
    onPoiDetailMoreButtonClicked: function onPoiDetailMoreButtonClickedFn() {
        var currentMarker = World.currentMarker;
        var markerSelectedJSON = {
            action: "present_poi_details",
            place_id: currentMarker.poiData.id,
            name: currentMarker.poiData.title,
            types: [currentMarker.poiData.description,],
        };
        /*
            The sendJSONObject method can be used to send data from javascript to the native code.
        */
        AR.platform.sendJSONObject(markerSelectedJSON);
    },

    /*
        Location updates, fired every time you call architectView.setLocation() in native environment
        Note: You may set 'AR.context.onLocationChanged = null' to no longer receive location updates in
        World.locationChanged.
     */
    locationChanged: function locationChangedFn(lat, lon) {

        /* Request data if not already present. */
        if (!World.initiallyLoadedData) {
            World.requestDataFromServer(lat, lon, World.destinLat, World.destinLon);
            function waitForElement(){
                if( World.isRequestingData === false){
                    World.loadMarkersFromRoute();
                    World.initiallyLoadedData = true;
                    World.updateDistanceAndDurationDisplay(World.currentDistance, World.currentDuration);
                }
                else{
                    console.log("Waiting for querying data from Google");
                    setTimeout(waitForElement, 200);
                }
            }
            waitForElement();
        } else {
            //TODO: if location is near next turing point
            World.fetchUpdatedDistanceAndDuration(lat, lon);
            World.updateDistanceAndDurationDisplay(World.currentDistance, World.currentDuration);
            World.updateTotalStatusMessage();
        }

},

    /* Fired when user pressed maker in cam. */
    onMarkerSelected: function onMarkerSelectedFn(marker) {
        World.closePanel();

        World.currentMarker = marker;

        /*
            In this sample a POI detail panel appears when pressing a cam-marker (the blue box with title &
            description), compare index.html in the sample's directory.
        */
        /* Update panel values. */
        document.getElementById("poiDetailTitle").innerHTML = marker.poiData.title;
        document.getElementById("poiDetailDescription").innerHTML = marker.poiData.description;

        /*
            It's ok for AR.Location subclass objects to return a distance of `undefined`. In case such a distance
            was calculated when all distances were queried in `updateDistanceToUserValues`, we recalculate this
            specific distance before we update the UI.
         */
        if (undefined === marker.distanceToUser) {
            marker.distanceToUser = marker.markerObject.locations[0].distanceToUser();
        }

        /*
            Distance and altitude are measured in meters by the SDK. You may convert them to miles / feet if
            required.
        */
        var distanceToUserValue = (marker.distanceToUser > 999) ?
            ((marker.distanceToUser / 1000).toFixed(2) + " km") :
            (Math.round(marker.distanceToUser) + " m");

        document.getElementById("poiDetailDistance").innerHTML = distanceToUserValue;

        /* Show panel. */
        document.getElementById("panelPoiDetail").style.visibility = "visible";
    },

        closePanel: function closePanel() {
            /* Hide panels. */
            document.getElementById("panelPoiDetail").style.visibility = "hidden";

            if (World.currentMarker != null) {
                /* Deselect AR-marker when user exits detail screen div. */
                World.currentMarker.setDeselected(World.currentMarker);
                World.currentMarker = null;
            }
        },

/* Screen was clicked but no geo-object was hit. */
onScreenClick: function onScreenClickFn() {
    // if (World.currentMarker) {
    //     World.currentMarker.setDeselected(World.currentMarker);
    // }
    // World.currentMarker = null;
},

/*
    JavaScript provides a number of tools to load data from a remote origin.
    It is highly recommended to use the JSON format for POI information. Requesting and parsing is done in a
    few lines of code.
    Use e.g. 'AR.context.onLocationChanged = World.locationChanged;' to define the method invoked on location
    updates.
    In this sample POI information is requested after the very first location update.

    This sample uses a test-service of Wikitude which randomly delivers geo-location data around the passed
    latitude/longitude user location.
    You have to update 'ServerInformation' data to use your own own server. Also ensure the JSON format is same
    as in previous sample's 'myJsonData.js'-file.
*/
/* Request POI data. */
requestDataFromServer: function requestDataFromServerFn(lat, lon, destinLat, destinLon) {

    /* Set helper var to avoid requesting places while loading. */
    World.isRequestingData = true;
    World.updateStatusMessage('Requesting route from Google Maps');

    const directionsService = new google.maps.DirectionsService();

    var origin = lat + "," + lon;
    var destination = destinLat + "," + destinLon;

    var request_map = {
        origin: origin,
        destination: destination,
        travelMode: "WALKING"
    };

    directionsService.route(request_map).then((result) => {
        World.route = result.routes[0].legs[0].steps;
        World.isRequestingData = false;
    }
    ).catch((e) => {
        World.updateStatusMessage('Route failed to request from Google Maps', true);
    });
},

onError: function onErrorFn(error) {
    alert(error);
}
};

/* Forward locationChanges to custom function. */
AR.context.onLocationChanged = World.locationChanged;

/* Forward clicks in empty area to World. */
AR.context.onScreenClick = World.onScreenClick;

function getDistanceFromLatLonInM(lat1,lon1,lat2,lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2-lat1);  // deg2rad below
    var dLon = deg2rad(lon2-lon1); 
    var a = 
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
      Math.sin(dLon/2) * Math.sin(dLon/2)
      ; 
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
    var d = R * c * 1000; // Distance in km
    return d;
  }
  
  function deg2rad(deg) {
    return deg * (Math.PI/180)
  }