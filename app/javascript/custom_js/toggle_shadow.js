// Get the container element
const toggleShadow = () => {
  var btnContainer = document.getElementById("toggle-div");

  // Get all buttons with class="btn" inside the container
  var btns = btnContainer.getElementsByClassName("btn-toggle");

  // Loop through the buttons and add the active class to the current/clicked button
  for (var i = 0; i < btns.length; i++) {
    btns[i].addEventListener("click", function () {
      var current = document.getElementsByClassName("active");
      current[0].className = current[0].className.replace("active", "");
      this.className += "active";
    });
  }
}
export { toggleShadow };
