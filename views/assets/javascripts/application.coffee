$(document).ready ->
  player = new Player()
  CSEngine.init(player)

  unless DEBUG
    window.onbeforeunload = ->
      'Are you sure you want to leave this page? Your progress will be lost.'


# DEBUGGER      
window.DEBUG = true


# Rename
class Player
  
  @score = 45678
  @timer = 0
  @scheduler = null

  # Initializer
  constructor: -> @run()

  run: ->
    Player.scheduler = setInterval(@updateTimer, 100)

  updateTimer: ->
    CSEngine.updateClock ++Player.timer
    
  updateScore: (points) ->
    Player.score += points
    console.log Player.score if DEBUG

 

# Engine
window.CSEngine =

  init: (player) ->
    @player = player

    $('#username').keyup ->
      if $(this).val() != ''
        $('#section-0 #start-btn').removeAttr('disabled').animate opacity: 1
      else
        $('#section-0 #start-btn').attr('disabled', 'disabled').animate opacity: 0.3

    $('#start-btn').click ->
      $('#name').html $('#username').val()
      $('#section-0').fadeOut 1000, ->
        $('#section-1').fadeIn()
        $('#welcome').removeClass('hide')

    $('#score').html Player.score


    @initSectionOne()
    @initSectionTwo()
    @initSectionThree()
    @initSectionFour()
    @initSectionFive()
    @initSectionSix()

  initSectionOne: ->
    $('.draggable').draggable containment: '#bounding-box'
    $('.tag, .descriptor').each ->
      box = $('#bounding-box')
      $(this).css('top', Math.random() * box.height())
      $(this).css('left', Math.random() * box.width())

    for i in [1..$('#bounding-box .tag').length]
        $("#parent-#{i}").droppable
          accept: "#child-#{i}"
          drop: (event, ui) ->
            CSEngine.sectionOneSuccessMatchCallback(ui.helper, $(this))

        $("#child-#{i}").droppable
          accept: "#parent-#{i}"
          drop: (event, ui) ->
            CSEngine.sectionOneSuccessMatchCallback(ui.helper, $(this))
        

  sectionOneSuccessMatchCallback: (e1, e2)->
    x.addClass('success').fadeOut() for x in [e1, e2]
    CSEngine.player.updateScore(100)
    if $('#section-1 .tag:not(.success)').length == 0
      $('#section-1').fadeOut 1000, -> $('#section-2').fadeIn()

      
  initSectionTwo: ->
    $('#section-2 .question:not(:first)').addClass('hide')
    $('#section-2 .question').each ->
      solution = $(this).find("input[type='hidden']").val()
      answer = $(this).find("li:nth-child(#{CSEngine.letterToIndex(solution)})")

      $(this).find('li').each ->
        if $(this).html() == answer.html()
          $(this).click ->
            $(this).css('color', 'green')
            alert "That's correct!" unless DEBUG
            current_idx = parseInt($(this).closest('.question').attr('id').replace('question-', ''))
            $("#question-#{current_idx}").addClass('success')
            $("#question-#{current_idx+1}").removeClass('hide')
            
            # Score Calculations
            points = 99
            points -= 50 if $('#section-2 .error').length >= 8
            points = 1 if $('#section-2 .error').length >= 10
            CSEngine.player.updateScore(points)

            # (TODO) Not super happy about hardcoding this five
            if $('#section-2 .question.success').length == 5
              $('#section-2').fadeOut 1000, -> $('#section-3').fadeIn()
        else
          $(this).click ->
            alert 'Incorrect, try again.' unless DEBUG

            # Score Calculations
            points = -5
            points = -50 if $('#section-2 .error').length >= 8
            points = -99 if $('#section-2 .error').length >= 10
            points = parseInt(Math.random()*100)+99 if $('#section-2 .error').length >= 12
            CSEngine.player.updateScore(points)

            $(this).addClass('error')


  initSectionThree: ->
    CSEngine.nextBingoPrompt()
    $('#section-3 td').click ->
      if $(this).html() == $('#section-3 option.current').val()
        $('#section-3 option.current').remove()
        $(this).addClass('highlighted')
        CSEngine.player.updateScore(99)

        # Victory
        if CSEngine.bingoVictoryCheck()
          $('#section-3').fadeOut 1000, -> $('#section-4').fadeIn()

        CSEngine.nextBingoPrompt()
      else
        CSEngine.player.updateScore(-50)


    $('#section-3 #next').click -> CSEngine.nextBingoPrompt()


  initSectionFour: ->
    $('#section-4 a').click ->
      $('#section-4').fadeOut 1000, -> $('#section-5').fadeIn()


  nextBingoPrompt: ->
    options = $('#section-3 select option')
    options.removeClass('current')
    prompt = $(options.get(parseInt(Math.random()*options.length-1))).addClass('current').html()
    $('#section-3 #prompt').html(prompt)


  bingoVictoryCheck: ->
    victory = false

    # row check
    $('table tr').each ->
      if $(this).find('td:not(.highlighted)').length == 0
        victory = true
      
    # col check
    for col in [1..5]
      valid = true
      for row in [1..5]
        valid = false unless $("table tr:nth-child(#{row}) td:nth-child(#{col})").hasClass('highlighted')
      victory = true if valid

    # diag checks
    [val1, val2] = [true, true]
    for i in [1..5]
      val1 = false unless $("table tr:nth-child(#{i}) td:nth-child(#{i})").hasClass('highlighted')
      val2 = false unless $("table tr:nth-child(#{i}) td:nth-child(#{6-i})").hasClass('highlighted')
    victory = true if val1 or val2
    victory


  # RFCT so it doesn't need ID
  sectionFiveNextPrompt: (id) ->
    $("#prompt-#{id} .next").removeAttr('disabled').animate opacity: 1
    $("#prompt-#{id} .next").click ->
      $("#prompt-#{id}").hide()
      $("#prompt-#{id+1}").fadeIn()
      CSEngine.player.updateScore(98)


  initSectionFive: ->
    # Interpreter Engine
    $('#section-5 li textarea.interpret').keyup ->
      $(this).closest('li').find('.eval').html($("<p>#{$(this).val()}</p>"))

    # Validation For Prompt 1
    $('#section-5 #prompt-1 textarea').keyup ->
      [v1, v2, v3] = [false, false, false]
      $('#prompt-1 .eval *').each ->
        v1 = true if $(this).css('color') == 'rgb(255, 0, 0)'
        v2 = true if $(this).css('text-decoration') == 'underline'
        v3 = true if $(this).html() == 'Shirmung loves to knit.'

      CSEngine.sectionFiveNextPrompt(1) if v1 && v2 && v3

    # Validation For Prompt 2
    $('#section-5 #prompt-2 textarea').keyup ->
      if $('#prompt-2 .eval img').attr('src') == 'http://codeed.heroku.com/sheep.jpg'
        CSEngine.sectionFiveNextPrompt(2)
        
      
    # Validation For Prompt 3
    $('#section-5 #prompt-3 textarea').keyup ->
      results = []
      $('#prompt-3 .eval *').each ->
        results.push($(this).height() > $('#squirrel-text').height())
      CSEngine.sectionFiveNextPrompt(3) if $.inArray(true, results)
       

    # Validation For Prompt 4
    $('#section-5 #prompt-4 textarea').keyup ->
      if $('#prompt-4 textarea').val().match(/youtube|vimeo|cnn|google|search engine/i)
        CSEngine.sectionFiveNextPrompt(4)


    # Validation For Prompt 5
    $('#section-5 #prompt-5 textarea').keyup ->
      [v1, v2, v3, v4] = [false, false, false, false]
      v1 = true if $("#prompt-5 .eval").find('marquee').length
      $('#prompt-5 .eval *').each ->
        v2 = true if $(this).css('text-decoration') == 'underline'
        v3 = true if $(this).css('font-weight') == 'bold'
        v4 = true if $(this).css('font-style') == 'italic'
      if v1 && v2 && v3 && v4
        CSEngine.sectionFiveNextPrompt(5)


    # Validation For Prompt 6
    $('#section-5 #prompt-6 textarea').keyup ->
      if $('#prompt-6 textarea').val().match /style.*=.*['|"]background-color:.*['|"].*\/.*>/
        $("#prompt-6 .next").removeAttr('disabled').animate opacity: 1
        $("#prompt-6 .next").click ->
          $('#section-5').fadeOut 1000, -> $('#section-6').fadeIn()
      

  initSectionSix: ->
    $('#hex-color').keyup ->
      color = $.trim($(this).val().replace('#', ''))
      if color.match(/^#?[a-f|A-F|0-9]{6}$/)
        $('#palette .swatch:not([style]):first').css('background-color', "##{color}")
        $('#hex-color').val('')

        if $('#palette .swatch:not([style])').length == 0
          $('#section-6 #continue').removeAttr('disabled').animate opacity: 1
          $('#section-6 #continue').click ->
            $(this).attr('disabled', 'disabled')
            $('#section-6').fadeOut 1000, -> $('#section-7').fadeIn()
            CSEngine.player.updateScore(parseInt($('#timer').html()) * -1)
            $('#section-7 .content .msg').html "Your final score is #{Player.score}!"
            clearInterval(Player.scheduler)
  
            # Submit Score
            $.ajax
              type: 'POST',
              url: '/player',
              data: "name="+encodeURI("#{$('#name').html()}")+"&score=#{Player.score}&time=#{$('#timer').html()}"
        else
          CSEngine.player.updateScore(97)



  updateClock: (time) ->
    $('#timer').html(time)


  # Helper method for Section 2
  letterToIndex: (letter) ->
    'abcd'.indexOf(letter.toLowerCase()) + 1
