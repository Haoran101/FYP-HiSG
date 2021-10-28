/*
    Information about server communication. This sample webservice is provided by Wikitude and returns random dummy
    Places near given location.
 */

    https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyAJRn-a8TdDAA22Vgh1HVfdm62enaq7OfY&location=1.2372390405371851%2C103.60725402832033&type=point_of_interest&radius=1600&language=en-US
var ServerInformation = {
    POIDATA_SERVER: "https://maps.googleapis.com/maps/api/place/nearbysearch/json",
    POIDATA_SERVER_KEY : "key",
    PLACES_API_KEY : "AIzaSyAJRn-a8TdDAA22Vgh1HVfdm62enaq7OfY",
    POIDATA_SERVER_LOCATION : "location",
    POIDATA_SERVER_RADIUS: "radius", 
    POIDATA_SERVER_LAN: "language", 
};

var defaultCategory = ["tourist_attraction", "restaurant", "atm", "transit_station", "supermarket"];

/* Implementation of AR-Experience (aka "World"). */

var World = {

    /* You may request new data from server periodically, however: in this sample data is only requested once. */
    isRequestingData: true,

    /* True once data was fetched. */
    initiallyLoadedData: false,

    /* Different POI-Marker assets. */
    markerDrawableIdle: null,
    markerDrawableSelected: null,
    markerDrawableDirectionIndicator: null,

    /* List of AR.GeoObjects that are currently shown in the scene / World. */
    markerList: [],

    /* the last selected marker. */
    currentMarker: null,

    currentlocPoiResult: new Object(),

    filterPOIdataBasedOnCat: function filterPOIdataBasedOnCatFn(){
        var results = [];
        var cats = (World.categorySelected.size===0)? defaultCategory : World.categorySelected;
        for (var cat of cats){
            var resOfCat = World.currentlocPoiResult[cat];
            results = results.concat(resOfCat.slice(0, Math.min(3, resOfCat.length)));
        }
        console.log(results.length);
        return results;
    },

    categorySelected: new Set(),

    categorySelectDefault: function categorySelectDefaultFn(){
        // World.categorySelected = new Set();
        // World.loadPoisFromJsonData(World.filterPOIdataBasedOnCat());
        // console.log(World.markerList.length);
        World.loadPoisFromJsonData([]);
    },

    categorySelector: function categorySelectorFn(ele) {
        var category = ele.id;
        if (ele.className.includes("selected")){
            //deselect
            World.categorySelected.delete(category);
            ele.className = ele.className.replace(" selected", "");
        } else {
            //select
            World.categorySelected.add(category);
            ele.className += " selected";
        }
        console.log(JSON.stringify(World.categorySelected));
        World.loadPoisFromJsonData(World.filterPOIdataBasedOnCat());
        console.log(World.markerList.length);
    },

    /* Called to inject new POI data. */
    loadPoisFromJsonData: function loadPoisFromJsonDataFn(poiData) {

        /* Empty list of visible markers. */
        World.markerList = [];

        /* Start loading marker assets. */
        World.markerDrawableIdle = new AR.ImageResource("assets/poi_blue.png", {
            onError: World.onError
        });
        World.markerDrawableSelected = new AR.ImageResource("assets/poi.png", {
            onError: World.onError
        });
        World.markerDrawableDirectionIndicator = new AR.ImageResource("assets/indi.png", {
            onError: World.onError
        });

        /* Loop through POI-information and create an AR.GeoObject (=Marker) per POI. */
        for (var currentPlaceNr = 0; currentPlaceNr < poiData.length; currentPlaceNr++) {
            var singlePoi = {
                "id": poiData[currentPlaceNr].place_id,
                "latitude": parseFloat(poiData[currentPlaceNr].geometry.location.lat),
                "longitude": parseFloat(poiData[currentPlaceNr].geometry.location.lng),
                "altitude": 100.0 + (Math.random() * 10),
                "title": poiData[currentPlaceNr].name,
                "description": poiData[currentPlaceNr].vicinity
            };

            World.markerList.push(new Marker(singlePoi));
        }

        World.updateStatusMessage(currentPlaceNr + ' places loaded');
    },

    /* Updates status message shown in small "i"-button aligned bottom center. */
    updateStatusMessage: function updateStatusMessageFn(message, isWarning) {
        document.getElementById("popupButtonImage").src = isWarning ? "assets/warning_icon.png" : "assets/info_icon.png";
        document.getElementById("popupButtonTooltip").innerHTML = message;
    },

    /* User clicked "More" button in POI-detail panel -> fire event to open native screen. */
    onPoiDetailMoreButtonClicked: function onPoiDetailMoreButtonClickedFn() {
        var currentMarker = World.currentMarker;
        var markerSelectedJSON = {
            action: "present_poi_details",
            id: currentMarker.poiData.id,
            title: currentMarker.poiData.title,
            description: currentMarker.poiData.description
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
    locationChanged: function locationChangedFn(lat, lon, alt, acc) {

        /* Request data if not already present. */
        if (!World.initiallyLoadedData) {
            World.requestDataFromServer(lat, lon);
            var results = World.filterPOIdataBasedOnCat();
            console.log(results.length);
            World.loadPoisFromJsonData(results);
            World.initiallyLoadedData = true;
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
        if (World.currentMarker) {
            World.currentMarker.setDeselected(World.currentMarker);
        }
        World.currentMarker = null;
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
    requestDataFromServer: function requestDataFromServerFn(lat, lon) {

        /* Set helper var to avoid requesting places while loading. */
        World.isRequestingData = true;
        World.updateStatusMessage('Requesting places from web-service');

        /* Server-url to JSON content provider. */
        for (var i = 0; i < defaultCategory.length; i++){
            let cat = defaultCategory[i];
            let serverUrl = ServerInformation.POIDATA_SERVER + "?" +
            "type=" + cat +
            "&key=" + ServerInformation.PLACES_API_KEY + "&location=" +
            lat + "," + lon + "&radius=1000&" +
            "language=en-US";

        /* Use GET request to fetch the JSON data from the server */
            let xhr = new XMLHttpRequest();
            xhr.open('GET', serverUrl, true);
            xhr.responseType = 'json';
            xhr.send();
            xhr.onreadystatechange = function() {
                let status = xhr.status;
                console.log(cat);
                if (status != 200) {
                    World.updateStatusMessage("Invalid web-service response.", true);
                } else {
                    let res = xhr.response["results"];
                    World.currentlocPoiResult[cat] = res;
                    console.log(Object.keys(World.currentlocPoiResult));
                }
            }
        }
        World.isRequestingData = false;
    },

    onError: function onErrorFn(error) {
        alert(error);
    }
};

/* Forward locationChanges to custom function. */
AR.context.onLocationChanged = World.locationChanged;

/* Forward clicks in empty area to World. */
AR.context.onScreenClick = World.onScreenClick;