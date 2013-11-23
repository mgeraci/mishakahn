// Generated by CoffeeScript 1.3.3
(function() {
  var clickNavigation, copyHomeMenu, hovercards, pan, resizeFunction, setSizeAndResize;

  $(function() {
    copyHomeMenu();
    setSizeAndResize();
    clickNavigation.initialize();
    pan.initialize();
    return hovercards.initialize();
  });

  copyHomeMenu = function() {
    var menu;
    if ($("#fixed-menu ul").length) {
      return;
    }
    menu = $("#home ul").clone();
    return $("#fixed-menu h1").after(menu);
  };

  setSizeAndResize = function() {
    var debouncedResizeFunction;
    resizeFunction();
    debouncedResizeFunction = _.debounce(resizeFunction, 100);
    return $(window).resize(function() {
      return resizeFunction();
    });
  };

  resizeFunction = function() {
    var height, width;
    width = $(window).width();
    height = $(window).height();
    $("#home").outerWidth(width);
    $("#home").outerHeight(height);
    $("#zoom-wrapper").transformOrigin("" + (width / 2) + "px " + (height / 2) + "px");
    clickNavigation.getHomeCenterCoords();
    return pan.calculateMaxes();
  };

  clickNavigation = {
    transitionTime: 1200,
    homeX: 0,
    homeY: 0,
    initialize: function() {
      var _this = this;
      this.getTransitionTime();
      this.getHomeCenterCoords();
      $("body").on("click", "ul.work-links a", function(e) {
        return _this.goToPiece(e);
      });
      return $("body").on("click", ".return-home", function(e) {
        return _this.returnHome();
      });
    },
    getTransitionTime: function() {
      var transitionTime;
      transitionTime = $("#transition-time").css("transition").split(" ")[1];
      return this.transitionTime = transitionTime.match(/ms$/) ? parseInt(trantisionTime.replace(/ms$/, ""), 10) : parseFloat(transitionTime.replace(/s$/, ""), 10) * 1000;
    },
    getHomeCenterCoords: function() {
      var position;
      position = $("#home").position();
      this.homeX = position.left + $(window).width() / 2;
      return this.homeY = position.top + $(window).height() / 2;
    },
    goToPiece: function(e) {
      var target;
      e.preventDefault();
      target = $("#" + ($(e.target).data("target")));
      this.moveToElement(target);
      return $("#home .return-home").show();
    },
    returnHome: function() {
      $("#home .return-home").hide();
      return this.moveToElement($("#home"));
    },
    moveToElement: function(el) {
      var centerOfElementX, centerOfElementY, element, fieldX, fieldY, height, isHome, position, returnLink, translateString, width,
        _this = this;
      element = $(el);
      position = element.position();
      width = element.width();
      height = element.height();
      isHome = element.attr("id") === "home";
      centerOfElementX = Math.round(position.left + width / 2);
      centerOfElementY = Math.round(position.top + height / 2);
      if (isHome) {
        fieldX = 0;
        fieldY = 0;
      } else {
        fieldX = centerOfElementX - this.homeX;
        fieldY = centerOfElementY - this.homeY;
      }
      translateString = "translate(" + (fieldX * -1) + "px, " + (fieldY * -1) + "px)";
      $("#zoom-wrapper").addClass("zoomed-out");
      $("#stage").addClass("animating").transform("" + translateString);
      setTimeout(function() {
        return $("#zoom-wrapper").removeClass("zoomed-out");
      }, this.transitionTime / 2);
      setTimeout(function() {
        return $("#stage").removeClass("animating");
      }, this.transitionTime);
      returnLink = $("#fixed-menu");
      if (isHome) {
        return returnLink.animate({
          opacity: 0
        }, this.transitionTime / 2, function() {
          return returnLink.hide();
        });
      } else {
        return setTimeout(function() {
          returnLink.show().css({
            opacity: 0
          });
          return returnLink.animate({
            opacity: 1
          }, this.transitionTime / 2);
        }, this.transitionTime);
      }
    }
  };

  pan = {
    prevX: false,
    prevY: false,
    startCoords: {},
    endCoords: {},
    movementDuration: 0,
    movementDurationTimeout: null,
    padding: 20,
    minX: 0,
    maxX: 0,
    minY: 0,
    maxY: 0,
    initialize: function() {
      var _this = this;
      $("body").on("mousedown", function(e) {
        return _this.mouseDown(e);
      });
      $("body").on("mouseup", function(e) {
        return _this.mouseUp(e);
      });
      return $("body").on("mousemove", function(e) {
        return _this.mouseMove(e);
      });
    },
    mouseDown: function(e) {
      if ($("#stage").hasClass("animating") || $(e.target).closest("#home").length || $(e.target).closest("a").length || $(e.target).closest("img").length || $(e.target).closest("#fixed-menu").length) {
        return;
      }
      $("#stage").stop(true).addClass("panning");
      this.prevX = false;
      this.prevY = false;
      this.startCoords.x = e.pageX;
      this.startCoords.y = e.pageY;
      this.movementDuration = 0;
      return this.setTimer();
    },
    mouseUp: function(e) {
      var deltaX, deltaY, distance, distanceTraveled, maxDistance, maxSpeed, maxxedCoords, newX, newY, pos, slope, speed, xTravel, yTravel;
      if ($(e.target).closest("#home").length || $("#stage").hasClass("animating")) {
        return;
      }
      if (!$("#stage").hasClass("panning")) {
        return;
      }
      $("#stage").removeClass("panning");
      clearTimeout(this.movementDurationTimeout);
      this.endCoords.x = e.pageX;
      this.endCoords.y = e.pageY;
      xTravel = this.endCoords.x - this.startCoords.x;
      yTravel = (this.endCoords.y - this.startCoords.y) * -1;
      slope = xTravel === 0 ? 100 : yTravel / xTravel;
      distanceTraveled = Math.sqrt(xTravel * xTravel + yTravel * yTravel);
      speed = ((distanceTraveled / this.movementDuration) * 1000) || 0;
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
      return maxxedCoords = this.panMax(newX, newY);
    },
    /*
    	  if speed > 700
    	    $("#stage").addClass("momentum").animate({
    	      top: maxxedCoords[1]
    	      left: maxxedCoords[0]
    	    }, 1000, "easeOutQuint", ->
    	      $("#stage").removeClass("momentum")
    	    )
    */

    mouseMove: function(e) {
      var currentPos, deltaX, deltaY, maxxedCoords, newX, newY;
      if (!$("#stage").hasClass("panning")) {
        return;
      }
      currentPos = this.matrixToArray($("#stage"));
      if ((this.prevX != null) && (this.prevY != null) && this.prevX !== false && this.prevY !== false) {
        deltaX = e.pageX - this.prevX;
        deltaY = e.pageY - this.prevY;
        newX = currentPos[0] + deltaX;
        newY = currentPos[1] + deltaY;
        maxxedCoords = this.panMax(newX, newY);
        $("#stage").transform("translate(" + maxxedCoords[0] + "px, " + maxxedCoords[1] + "px");
      }
      this.prevX = e.pageX;
      return this.prevY = e.pageY;
    },
    setTimer: function() {
      return this.movementDurationTimeout = setTimeout(this.counter.bind(this), 1);
    },
    counter: function() {
      this.movementDuration++;
      return this.setTimer();
    },
    matrixToArray: function(el) {
      var matrix, res;
      matrix = el.css("-webkit-transform");
      res = matrix.substr(7, matrix.length - 8).split(', ');
      return [parseInt(res[4], 10), parseInt(res[5], 10)];
    },
    calculateMaxes: function() {
      var homeHeight, homePosition, homeWidth, stageHeight, stageWidth;
      homePosition = $("#home").position();
      homeWidth = $("#home").width();
      homeHeight = $("#home").height();
      stageWidth = $("#stage").width();
      stageHeight = $("#stage").height();
      this.maxX = homePosition.left + this.padding;
      this.maxY = homePosition.top + this.padding;
      this.minX = (stageWidth - homePosition.left - homeWidth - this.padding) * -1;
      return this.minY = (stageHeight - homePosition.top - homeHeight - this.padding) * -1;
    },
    panMax: function(x, y) {
      if (x < this.minX) {
        x = this.minX;
      }
      if (y < this.minY) {
        y = this.minY;
      }
      if (x > this.maxX) {
        x = this.maxX;
      }
      if (y > this.maxY) {
        y = this.maxY;
      }
      return [x, y];
    }
  };

  hovercards = {
    initialize: function() {
      var _this = this;
      $("body").on("mouseenter", ".test", function(e) {
        return _this.showHovercard(e.currentTarget);
      });
      return $("body").on("mouseleave", ".test", function(e) {
        return _this.hideHovercard();
      });
    },
    showHovercard: function(el) {
      var params;
      params = {
        title: $(el).data("title"),
        year: $(el).data("year"),
        text: $(el).data("text")
      };
      $("#info").hide().empty().append(this.template(params));
      return $("#info").stop(true, true).fadeIn();
    },
    hideHovercard: function() {
      return $("#info").stop(true, true).fadeOut();
    },
    template: function(params) {
      return "<h1>" + params.title + "</h1>\n<h2>" + params.year + "</h2>\n<div class=\"text\">" + params.text + "</div>";
    }
  };

}).call(this);
