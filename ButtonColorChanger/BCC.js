const button = document.getElementById("colorButton");
button.addEventListener("click", function() {
    const colors = ["light-blue", "lavender", "pink", "red", "green", "yellow", "plum"];
    const randColor = colors[Math.floor(Math.random() * colors.length)];
    document.getElementById("colorBox").style.backgroundColor = randColor;
});