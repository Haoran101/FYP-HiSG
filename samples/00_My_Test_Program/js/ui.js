EXPAND_MORE = "assets/outline_expand_more_black_48dp.png";
EXPAND_LESS = "assets/outline_expand_less_black_48dp.png";

function expand() {
    wrap = document.getElementById("wrap-collabsible");
    console.log("clicked");
    
    var content = document.getElementsByClassName("coll-content");
    var expand_button = document.getElementById("expand_more");
    document.getElementById("filter").classList.toggle("active");
    Array.from(content).forEach((x) => {
    if (x.style.visibility == "visible") {
        x.style.visibility = "hidden";
        wrap.className = "wrap-collabsible";
        expand_button.src = EXPAND_LESS;

    } else {
        x.style.visibility = "visible";
        wrap.className = "wrap-expanded";
        expand_button.src = EXPAND_MORE;
        World.closePanel();
    }
    
})
}