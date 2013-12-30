# Don't mind this, just trying to translate the JQuery to LS

$(document).ready ->
  $(document).ready ->
    
    # Init Menu
    $("#menu > ul > li ul").each (index, e) ->
      count = $(e).find("li").length
      content = "<span class=\"cnt\">" + count + "</span>"
      $(e).closest("li").children("a").append content

    $("#menu ul ul li:odd").addClass "odd"
    $("#menu ul ul li:even").addClass "even"
    $("#menu > ul > li > a").click ->
      $("#menu li").removeClass "active"
      $(this).closest("li").addClass "active"
      checkElement = $(this).next()
      if (checkElement.is("ul")) and (checkElement.is(":visible"))
        $(this).closest("li").removeClass "active"
        checkElement.slideUp "normal"
      if (checkElement.is("ul")) and (not checkElement.is(":visible"))
        $("#menu ul ul:visible").slideUp "normal"
        checkElement.slideDown "normal"
      if $(this).closest("li").find("ul").children().length is 0
        true
      else
        false

    
    # Show/Hide Menu + Switch Captions
    a = 0
    $(".showhide").click (e) ->
      
      #e.preventDefault();
      if a is 0
        $("#menu").animate(
          left: "152px"
        , "slow").show()
        $("#a-show").fadeToggle 500
        $("#a-hide").fadeToggle 500
        a = 1
      else
        $("#menu").animate({\left: "-150px"},\slow).show!
        $("#a-show").fadeToggle 500
        $("#a-hide").fadeToggle 500
        a = 0

    $("#canvas").mousedown (e) ->
      $("#drawhere").fadeOut 150


