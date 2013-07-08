// Generated by CoffeeScript 1.6.3
(function() {
  var duration, homeLinks, info, initializePosition, mousePos, movementDur, movementStats, pan, prevX, prevY, returnHome, sizeHome, _moveToElement, _movementTimeout, _positionStageOn, _setStageOriginTo, _sizeHome;

  duration = 2000;

  prevX = false;

  prevY = false;

  mousePos = false;

  $(function() {
    sizeHome();
    initializePosition();
    homeLinks();
    returnHome();
    pan();
    info();
    return movementStats();
  });

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

  homeLinks = function() {
    return $("body").on("click", "#home ul a", function(e) {
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
      if ($(e.target).closest("#home").length || $("#stage").hasClass("animating")) {
        return;
      }
      $("#stage").addClass("panning");
      prevX = false;
      return prevY = false;
    });
    $("body").on("mouseup", function(e) {
      if ($(e.target).closest("#home").length || $("#stage").hasClass("animating")) {
        return;
      }
      return $("#stage").removeClass("panning");
    });
    return $("body").on("mousemove", function(e) {
      var currentPos, deltaX, deltaY, maxX, maxY, newX, newY, padding;
      if (!$("#stage").hasClass("panning")) {
        return;
      }
      currentPos = $("#stage").position();
      if ((prevX != null) && (prevY != null) && prevX !== false && prevY !== false) {
        deltaX = e.pageX - prevX;
        deltaY = e.pageY - prevY;
        newX = currentPos.left + deltaX;
        newY = currentPos.top + deltaY;
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
        $("#stage").css({
          top: newY,
          left: newX
        });
      }
      prevX = e.pageX;
      return prevY = e.pageY;
    });
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

  movementStats = function() {
    $("body").on("mousemove", function(e) {
      return mousePos = e;
    });
    return _movementTimeout();
  };

  movementDur = 250;

  _movementTimeout = function() {
    return setTimeout(function() {
      console.log(mousePos);
      return _movementTimeout();
    }, movementDur);
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
    returnLink = $("#fixed-return-home");
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
        return $("#fixed-return-home").animate({
          opacity: 1
        }, duration / 2);
      }, duration + 500);
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
