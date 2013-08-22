// Generated by CoffeeScript 1.3.3
(function() {
  var copyHomeMenu, duration, endCoords, info, initializePosition, movementDuration, movementDurationTimeout, pan, prevX, prevY, returnHome, sizeHome, startCoords, workLinks, _counter, _moveToElement, _panMax, _positionStageOn, _setStageOriginTo, _setTimer, _sizeHome;

  duration = 2000;

  prevX = false;

  prevY = false;

  startCoords = {};

  endCoords = {};

  movementDuration = 0;

  movementDurationTimeout = null;

  $(function() {
    copyHomeMenu();
    sizeHome();
    initializePosition();
    workLinks();
    returnHome();
    pan();
    return info();
  });

  copyHomeMenu = function() {
    var menu;
    if ($("#fixed-menu ul").length) {
      return;
    }
    menu = $("#home ul").clone();
    return $("#fixed-menu h1").after(menu);
  };

  sizeHome = function() {
    _sizeHome();
    return $(window).resize(function() {
      return _sizeHome();
    });
  };

  _sizeHome = function() {
    $("#home").outerWidth($(window).width());
    return $("#home").outerHeight($(window).height());
  };

  initializePosition = function() {
    return _setStageOriginTo($("#home"));
  };

  workLinks = function() {
    return $("body").on("click", "ul.work-links a", function(e) {
      var target;
      e.preventDefault();
      target = $("#" + ($(e.target).data("target")));
      _moveToElement(target);
      return $("#home .return-home").show();
    });
  };

  returnHome = function() {
    return $("body").on("click", ".return-home", function(e) {
      $("#home .return-home").hide();
      return _moveToElement($("#home"));
    });
  };

  pan = function() {
    $("body").on("mousedown", function(e) {
      if ($("#stage").hasClass("animating") || $(e.target).closest("#home").length || $(e.target).closest("a").length || $(e.target).closest("img").length || $(e.target).closest("#fixed-menu").length) {
        return;
      }
      $("#stage").stop(true).addClass("panning");
      prevX = false;
      prevY = false;
      startCoords.x = e.pageX;
      startCoords.y = e.pageY;
      movementDuration = 0;
      return _setTimer();
    });
    $("body").on("mouseup", function(e) {
      var deltaX, deltaY, distance, distanceTraveled, maxDistance, maxSpeed, maxxedCoords, newX, newY, pos, slope, speed, xTravel, yTravel;
      if ($(e.target).closest("#home").length || $("#stage").hasClass("animating")) {
        return;
      }
      if (!$("#stage").hasClass("panning")) {
        return;
      }
      $("#stage").removeClass("panning");
      clearTimeout(movementDurationTimeout);
      endCoords.x = e.pageX;
      endCoords.y = e.pageY;
      xTravel = endCoords.x - startCoords.x;
      yTravel = (endCoords.y - startCoords.y) * -1;
      slope = xTravel === 0 ? 100 : yTravel / xTravel;
      distanceTraveled = Math.sqrt(xTravel * xTravel + yTravel * yTravel);
      speed = ((distanceTraveled / movementDuration) * 1000) || 0;
      maxSpeed = 20000;
      maxDistance = 800;
      distance = (speed * maxDistance) / maxSpeed;
      deltaX = distance / (Math.sqrt(slope * slope + 1));
      if (xTravel < 0) {
        deltaX = deltaX * -1;
      }
      deltaY = slope * deltaX;
      pos = $("#stage").position();
      newX = pos.left + deltaX;
      newY = pos.top - deltaY;
      maxxedCoords = _panMax(newX, newY);
      if (speed > 700) {
        return $("#stage").addClass("momentum").animate({
          top: maxxedCoords[1],
          left: maxxedCoords[0]
        }, 1000, "easeOutQuint", function() {
          return $("#stage").removeClass("momentum");
        });
      }
    });
    return $("body").on("mousemove", function(e) {
      var currentPos, deltaX, deltaY, maxxedCoords, newX, newY;
      if (!$("#stage").hasClass("panning")) {
        return;
      }
      currentPos = $("#stage").position();
      if ((prevX != null) && (prevY != null) && prevX !== false && prevY !== false) {
        deltaX = e.pageX - prevX;
        deltaY = e.pageY - prevY;
        newX = currentPos.left + deltaX;
        newY = currentPos.top + deltaY;
        maxxedCoords = _panMax(newX, newY);
        $("#stage").css({
          top: maxxedCoords[1],
          left: maxxedCoords[0]
        });
      }
      prevX = e.pageX;
      return prevY = e.pageY;
    });
  };

  _setTimer = function() {
    return movementDurationTimeout = setTimeout(_counter, 1);
  };

  _counter = function() {
    movementDuration++;
    return _setTimer();
  };

  info = function() {
    $("body").on("mouseenter", ".test", function(e) {
      var text, title, year;
      title = $(this).data("title");
      year = $(this).data("year");
      text = $(this).data("text");
      $("#info").hide().empty().append("<h1>" + title + "</h1>\n<h2>" + year + "</h2>\n<div class=\"text\">" + text + "</div>");
      return $("#info").stop(true, true).fadeIn();
    });
    return $("body").on("mouseleave", ".test", function(e) {
      return $("#info").stop(true, true).fadeOut();
    });
  };

  _moveToElement = function(el) {
    var returnLink;
    _setStageOriginTo(el);
    $("#stage").addClass("zoomed-out animating");
    _positionStageOn(el);
    setTimeout(function() {
      return $("#stage").removeClass("zoomed-out");
    }, duration / 2);
    setTimeout(function() {
      return $("#stage").removeClass("animating");
    }, duration * 2);
    returnLink = $("#fixed-menu");
    if (el.attr("id") === "home") {
      return returnLink.animate({
        opacity: 0
      }, duration / 2, function() {
        return returnLink.hide();
      });
    } else {
      return setTimeout(function() {
        returnLink.show().css({
          opacity: 0
        });
        return returnLink.animate({
          opacity: 1
        }, duration / 2);
      }, duration);
    }
  };

  _setStageOriginTo = function(el) {
    var elCoords;
    elCoords = $(el).centerCoords();
    return $("#stage").transformOrigin("" + elCoords.left + " " + elCoords.top);
  };

  _positionStageOn = function(el) {
    var left, pos, top;
    pos = $(el).position();
    top = pos.top * -1 + ($(window).height() - el.outerHeight()) / 2;
    left = pos.left * -1 + ($(window).width() - el.outerWidth()) / 2;
    return $("#stage").css({
      top: top,
      left: left
    });
  };

  jQuery.fn.centerCoords = function(percent) {
    var left, pos, suffix, top;
    if (percent == null) {
      percent = false;
    }
    pos = $(this).position();
    top = $(this).outerHeight() / 2 + pos.top;
    left = $(this).outerWidth() / 2 + pos.left;
    suffix = "px";
    if (percent) {
      top = (top * 100) / $("#stage").height();
      left = (left * 100) / $("#stage").width();
      suffix = "%";
    }
    return {
      top: top + suffix,
      left: left + suffix
    };
  };

  _panMax = function(newX, newY) {
    var maxX, maxY, padding;
    padding = 20;
    maxX = ($("#stage").width() - $(window).width()) * -1 - padding;
    maxY = ($("#stage").height() - $(window).height()) * -1 - padding;
    if (newX > padding) {
      newX = padding;
    }
    if (newY > padding) {
      newY = padding;
    }
    if (newX < maxX) {
      newX = maxX;
    }
    if (newY < maxY) {
      newY = maxY;
    }
    return [newX, newY];
  };

  jQuery.fn.transform = function(args) {
    return $(this).css({
      "-webkit-transform": args,
      "-moz-transform": args,
      "transform": args
    });
  };

  jQuery.fn.transformOrigin = function(args) {
    return $(this).css({
      "-webkit-transform-origin": args,
      "-moz-transform-origin": args,
      "-ms-transform-origin": args,
      "-o-transform-origin": args,
      "transform-origin": args
    });
  };

}).call(this);
