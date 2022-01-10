const directionsService = new google.maps.DirectionsService();

var request_map = {
    origin: "1.3483,103.6831",
    destination: "1.3386,103.7058",
    travelMode: "WALKING"

};
var route = directionsService.route(request_map,
    (response, status)=>{
        if (status !== "OK"){
            console.log("Failed to get route from Google Directions API.");
        } else {
            var duration = response.routes[0].legs[0].duration;
            console.log(duration);
            var distance = response.routes[0].legs[0].distance;
            console.log(distance);
            var steps = response.routes[0].legs[0].steps;
            console.log(steps);
        }
    });