duration = 1000

$ ->
  # TODO add window resize, debounced
  sizeHome()
  homeLinks()
  backHome()

sizeHome = ->
  $("#home").outerWidth $(window).width()
  $("#home").outerHeight $(window).height()

homeLinks = ->
  $("body").on "click", "#home ul a", (e)->
    e.preventDefault()

    $("#home .return-home").show() # block action on the home page
    $("#home")
      .addClass("animating zoomed-out")
      .removeAnimation()

backHome = ->
  $("body").on "click", ".return-home", (e)->
    $("#home .return-home").hide()
    $("#home")
      .addClass("animating").removeClass("zoomed-out")
      .removeAnimation()

jQuery.fn.removeAnimation = ->
  setTimeout ->
    $(this).removeClass "animating"
  , duration
