EXPAND_MORE = "assets/outline_expand_more_black_48dp.png";
EXPAND_LESS = "assets/outline_expand_less_black_48dp.png";

function expand(element) {
    wrap = document.getElementById("wrap-collabsible");
    console.log("clicked");
    element.classList.toggle("active");
    var content = document.getElementsByClassName("coll-content");
    var expand_button = document.getElementById("expand_more");
    console.log(content);
    Array.from(content).forEach((x) => {
    if (x.style.display == "inline-block") {
        x.style.display = "none";
        wrap.className = "wrap-collabsible";
        expand_button.src = EXPAND_MORE;

    } else {
        x.style.display = "inline-block";
        wrap.className = "wrap-expanded";
        expand_button.src = EXPAND_LESS;
    }
})
}