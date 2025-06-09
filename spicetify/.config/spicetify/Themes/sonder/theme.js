
function apply() {
    console.log("My custom JS is running!");
    source = document.querySelector(".Bdcf5g__Rug3TGqSdbiy");
    
    // Example: Modify CSS variables
    color = source.style.getPropertyValue("--background-base");
    target = document.querySelector(".main-trackList-trackListHeaderStuck");

    if (target)
        target.style.setProperty('--background-highlight', color);
}

// theme.js
document.addEventListener("DOMContentLoaded", function() {
    console.log("DOM is ready!");
    apply();
});