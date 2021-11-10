window.addEventListener("message", function (event) {
  let item = event.data;

  if (item.response == "openTarget") {
    $(".target-label").html("");
    $(".target-wrapper").show();
    $(".target-eye").css("color", "black");
  } else if (item.response == "closeTarget") {
    $(".target-label").html("");
    $(".target-wrapper").hide();
  } else if (item.response == "validTarget") {
    $(".target-label").html("");

    Object.values(item.data).forEach((item, index) => {
      $(".target-label").append(
        "<div class='target-item' id='" +
          index +
          "'<li><i class='" +
          item.icon +
          " fa-fw fa-pull-left target-icon'></i>" +
          item.label +
          "</li></div>"
      );
      $("#target-" + index).hover((e) => {
        $("#target-" + index).css(
          "color",
          e.type === "mouseenter" ? "rgb(98, 135, 236)" : "white"
        );
      });
      $("#" + index).css("padding-top", "0.75vh");
    });

    $(".target-eye").css("color", "rgba(255, 255, 255, 0.8)");
  } else if (item.response == "leftTarget") {
    $(".target-label").html("");
    $(".target-eye").css("color", "black");
  }
});

$(document).on("mousedown", (event) => {
  let element = event.target;
  $(".target-label").html("");
  $(".target-wrapper").hide();
  switch (event.which) {
    case 1: {
      $.post("https://qtarget/selectTarget", JSON.stringify(element.id + 1));
      break;
    }
    case 3: {
      $.post("https://qtarget/closeTarget");
      break;
    }
  }
});
