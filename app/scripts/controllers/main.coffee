'use strict'

###*
 * If you're reading this - I'm sorry. This is an extremely messy controller, but this site evolved over several weeks, and there's a lot of cruft left over. Here's how I'm planning to refactor this:
 * First, the top "navigation" interaction can be broken out into a directive. It'll emit "select" events that will by caught by this controller.
 * Part of the "card" UI will also be contained in a directive.
 * The goal is to get most of the transitionables out of this controller and into directives - this controller should only be responsible for stitching the two together.
###

angular.module('portfolioApp')
  .controller 'MainCtrl', ($scope, $famous, $timeout, $interval, $window, $route) ->

    # Famous init
    EventHandler = $famous['famous/core/EventHandler']
    Engine = $famous['famous/core/Engine']
    PhysicsEngine = $famous['famous/physics/PhysicsEngine']
    Circle = $famous['famous/physics/bodies/Circle']
    Particle = $famous['famous/physics/bodies/Particle']
    Transitionable = $famous['famous/transitions/Transitionable']
    Wall = $famous['famous/physics/constraints/Wall']
    Walls = $famous['famous/physics/constraints/Walls']
    Collision = $famous['famous/physics/constraints/Collision']
    Repulsion = $famous['famous/physics/forces/Repulsion']
    Spring = $famous['famous/physics/forces/Spring']
    RotationalSpring = $famous['famous/physics/forces/RotationalSpring']
    Force = $famous['famous/physics/forces/Force']
    Distance = $famous['famous/physics/constraints/Distance']
    Vector = $famous['famous/math/Vector']
    Scrollview = $famous['famous/views/Scrollview'];

    # transitions
    SnapTransition = $famous['famous/transitions/SnapTransition']
    Transitionable.registerMethod 'snap', SnapTransition

    $scope.projects = [
    #   name: 'Hashtag'
    #   icon: 'images/icons/hashtag.svg'
    #   description: 'Awesome group chat for all of the things'
    #   template: 'views/projects/hashtag.html'
    #   size: [26,true]
    # ,
    #   name: 'H.E.R.O.'
    #   icon: 'images/icons/hero.svg'
    #   description: 'Rugged humanitarian UAV'
    #   template: 'views/projects/hero.html'
    #   size: [30,true]
    # ,
    #   name: 'Shortwave'
    #   icon: 'images/icons/shortwave.svg'
    #   description: 'A chat room with a 100-foot range'
    #   template: 'views/projects/shortwave.html'
    #   size: [30,true]
    # ,
      name: 'Alonso Holmes'
      icon: 'images/icons/alonso.svg'
      description: 'Engineer, designer, and product person'
      template: 'views/projects/alonso.html'
      size: [true,34]
    # ,
    #   name: 'EROS'
    #   icon: 'images/icons/satellite.svg'
    #   description: 'In-flight satellite camera calibration'
    #   template: 'views/projects/satellite.html'
    #   size: [26,true]
    ,
      name: 'MountainLab'
      icon: 'images/icons/mountain.svg'
      description: 'Mountaintop product studio'
      template: 'views/projects/mountainlab.html'
      size: [true,22]
    ,
      name: 'Client Work'
      icon: 'images/icons/tie.svg'
      description: 'Selected client projects'
      template: 'views/projects/clientwork.html'
      size: [true,34]
    ,
      name: 'Projects'
      icon: 'images/icons/beaker.svg'
      description: 'Things I\'m hacking on'
      template: 'views/projects/projects.html'
      size: [true,34]
    ,
      name: 'Skills'
      icon: 'images/icons/code.svg'
      description: 'Frameworks, languages, and Excel endorsements'
      template: 'views/projects/skills.html'
      size: [true,22]
    ]

    numCircles = $scope.projects.length#6
    circleSizes = 
      big: 70
      small: 5

    $scope.circleSize = circleSizes.big

    $scope.dims =
      w: $window.innerWidth
      h: $window.innerHeight
    topAnchor = 0
    calcDims = ->
      topAnchor = $scope.dims.h * 0.2

      # How much space between the bottom of the screen and the popup card
      $scope.bottomCardPadding = $scope.dims.h * 0.4

      minspace = topAnchor + 170
      if $scope.dims.h - $scope.bottomCardPadding < minspace
        $scope.bottomCardPadding = $scope.dims.h - minspace
    calcDims()
    # console.log $scope.dims
    # width = $window.innerWidth#320
    # height = $window.innerHeight# 320
    width = 0.5
    height = 0.5
    DISTANCE = 200
    expanded = true # layout state tracker
    colors = ["#b58900","#cb4b16","#dc322f","#d33682","#6c71c4","#268bd2","#2aa198","#859900"]
    # colors = ["#E7604A", "#00CF69", "#4A90E2", "#738B97", "#F5A623"]
    colors = ["#575757"]
    # colors = ["#FEFEFE"]
    $scope.stroke = "#FEFEFE"


    # Zoom levels
    levels = 
      out: [0.1,0.1]
      in: [1,1]
    zoomedIn = false
    # Start zoomed in
    $scope.scaler = new Transitionable levels.out
    $scope.contentScaler = new Transitionable [1,1]

    # Event handler for scroll containers
    $scope.scrollEventHandler = new EventHandler

    $scope.imageFader = new Transitionable 0


    $scope.colorMap = {}
    $scope.circles = []

    $scope.opts = 
      size: [500,500]

    physicsEngine = new PhysicsEngine

    # Create some circles
    $scope.colorMap = {}

    $scope.layers = 
      center: 1001
      corner: 1002

    $scope.springLengths = 
      big: 200
      small: 30

    silverRatio = 0.3

    $scope.scrollview = new Scrollview()
      # size: [true,true]

    # console.log $scope.scrollview.pipeFrom



    # Center set of information - adding these as particles, because I want to hook them up to springs later


    # Center particle
    centerParticle = new Particle 

    # Corner particle
    # $scope.cornerPosition = [$scope.dims.w-50, 50]
    cornerParticle = new Particle 
      # position: $scope.cornerPosition
    # console.log cornerParticle

    # Name
    # namePosition = topAnchor + circleSizes.big + 30
    $scope.projectName = new Particle 
      # position: [$scope.dims.w/2, namePosition]
    # $scope.projectName.spring = new Spring 
    #   length: 0
    #   anchor: [centerParticle]
    physicsEngine.addBody $scope.projectName
    

    setParticlePositions = ->
      # Center particle position
      centerParticle.setPosition [$scope.dims.w/2, $scope.dims.h/2]

      # Corner particle position
      $scope.cornerPosition = [$scope.dims.w-50, 50]
      cornerParticle.setPosition $scope.cornerPosition

      # Name
      $scope.projectName.setPosition [$scope.dims.w/2, topAnchor + circleSizes.big + 30]

    setParticlePositions()

    # # Description
    # descriptionPosition = namePosition + 100
    # $scope.projectDescription = new Particle 
    #   position: [$scope.dims.w/2, descriptionPosition]
    # # $scope.projectDescription.spring = new Spring 
    # #   length: 0
    # #   anchor: [centerParticle]
    # physicsEngine.addBody $scope.projectDescription

    angular.element($window).bind 'resize', ->
      $route.reload()
      # console.log 'window resize'
      # # Update the location of the center particle
      # $scope.dims =
      #   w: $window.innerWidth
      #   h: $window.innerHeight
      # calcDims()

      # # centerParticle.setPosition [$scope.dims.w/2, $scope.dims.h/2]

      # setParticlePositions()

      # $scope.reset()

      # $scope.$apply()





    initPhysics = ->

      rotate = Math.random() * Math.PI
      console.log "rotate is #{rotate}"

      for i in [0...numCircles]
        # Compute the ideal angle
        angle = ((2*Math.PI*i) / (numCircles)) + rotate
        # Add a random rotation 
        console.log "Deploying circle #{i} at angle #{angle * 180 / Math.PI}"
        offset = 
          x: 20 * Math.cos angle
          y: 20 * Math.sin angle
        circ = new Circle 
          radius: circleSizes.big/2
          position: [$scope.dims.w/2 + offset.x, $scope.dims.h/2 + offset.y]
          # position: [width + Math.random()*0.0000001, height + Math.random()*0.000001]
        # console.log circ

        circ._id = Math.random()

        # Fader and scaler for icons
        circ.iconScaler = new Transitionable 0.7
        circ.iconFader = new Transitionable 0

        # Fader for the entire circle
        circ.fader = new Transitionable 1

        # Add
        physicsEngine.addBody circ 

        # Store ref to color
        $scope.colorMap[circ._id] = _.sample colors

        $scope.circles.push circ



      # Attach all the things
      for circ, idx in $scope.circles 
        # Make the spring
        circ.spring = new Spring
          anchor: centerParticle#[0.5,0.5]#[width/2, height/2]
          period: 300
          dampingRatio: 0.3
          # forceFunction: Spring.FORCE_FUNCTIONS.FENE

        # circ.rotationalSpring = new RotationalSpring
        #   anchor: [0.5,0.5]
        #   period: 3000
        #   dampingRation: 0.1
        #   length: 300

        # Attach the repulsion
        # physicsEngine.attach repulse, $scope.circles, circ
        # Attach the spring
        physicsEngine.attach circ.spring, circ 
        # Attach the rotational spring
        # physicsEngine.attach circ.rotationalSpring, circ
        # Attach the collisions
        physicsEngine.attach collision, $scope.circles, circ

        # Attach to the next spring
        prev = idx - 1
        if prev < 0
          prev = $scope.circles.length - 1
        next = idx + 1
        if next is $scope.circles.length
          next = 0
        

      setSprings()

      initWalls()
      $scope.reset true

    initWalls = ->
      # Walls
      walls = [
        new Wall
          normal: [1,0,0]
          distance: 0
          restitution: 0.1
      ,
        new Wall
          normal: [-1,0,0]
          distance: $scope.dims.w
          restitution: 0.1
      ,
        new Wall
          normal: [0,1,0]
          distance: 0
          restitution: 0.1
      ,
        new Wall
          normal: [0,-1,0]
          distance: $scope.dims.h
          restitution: 0.1
      ]

      # Attach to the circles
      physicsEngine.attach walls, $scope.circles



    # Center information


    

    # attraction = new Repulsion 
    #   strength: 10
    gv = new Vector [100,0,0]
    gravity = new Force gv



    
    # $scope.projectName.applyForce(new Vector [0, 1, 0])
    # physicsEngine.attach $scope.projectName.spring, $scope.projectName
    # physicsEngine.attach attraction, centerParticle, $scope.projectName

    # $scope.projectName.applyForce gravity.force
    

    # Transitionable for repulsion
    repulsionTrans = new Transitionable 0
    # Circle-circle repulsion 
    repulse = new Repulsion
    repulse = new Spring 
      length: $scope.springLengths.big
      period: 700
      dampingRatio: 0.5 # controls how "loosely" the circles arrange themselves


    $scope.spinner = new Transitionable 0

    $scope.padder = [true,300]
    $timeout ->
      $scope.padder = [true,0]
    , 2000

    # count = 1
    # slowSpin = ->
    #   $scope.spinner.set 3.14/numCircles*2*count,
    #     duration: 300
    #   , ->
    #     count += 1
    #     $timeout slowSpin, 2000
    #     # slowSpin()
    # slowSpin()

    # spin = (first = false) ->
    #   console.log "it is now #{Date.now()/1000}"
    #   period = 3000
    #   duration = 300
    #   if first
    #     # Sleep until nearest whole period
    #     millis = period - ((Date.now()/1000) % (period/1000)) * 1000
    #     console.log "it is now #{Date.now()/1000} - sleeping #{millis} until #{Date.now()/1000 + millis/1000}"
    #     $timeout spin, millis
    #   else
    #     # Pick a random location
    #     location = ((Date.now()/100000) % 1) * 3.14
    #     location = Math.random()*3.14
    #     console.log 'spinning to ' + location
    #     $scope.spinner.set location,
    #       duration: duration
    #       curve: 'easeInOut'
    #     , ->
    #       # spin()
    #       delay = Math.random() * 10000
    #       delay = period - duration
    #       $timeout spin, delay

    # spin true


    

    # circle-circle collisions
    collision = new Collision
      restitution: 0.3

    ###*
     * sets springs between each of the circles
     * @type {str} exclude (optional) - exclude a circle
    ###
    setSprings = (exclude=false) ->
      console.groupCollapsed '%csetting springs', 'color: green;'
      if exclude 
        console.info "<excluding #{exclude}>"
      # first remove all existing springs
      for circ in $scope.circles
        # Remove the existing spring
        if circ.neighborSprings
          console.info "detaching #{circ.neighborSprings}"
          for springId in circ.neighborSprings
            physicsEngine.detach springId
          circ.neighborSprings = []
        unless circ.neighborSprings
          circ.neighborSprings = []
        
      safe = (circle for circle, index in $scope.circles unless index is exclude)
      for circ, i in $scope.circles
        for circ, j in $scope.circles
          if i < j
            unless i is exclude or j is exclude
              console.info "#{i} <---> #{j}"
              # attach!
              $scope.circles[i].neighborSprings.push physicsEngine.attach repulse, $scope.circles[i], $scope.circles[j]
            else
              console.info "skipping because either #{i} or #{j} is #{exclude}"

      console.groupEnd()

        # Attach this element to every other element, except the excluded
        # circ.nextNeighborSpring = physicsEngine.attach repulse, safe, circ

        # # Attach to the next element, unless it's the exclude element
        # unless wrap(idx + 1) is exclude
        #   next = idx + 1
        # else
        #   # skip that shit
        #   next = idx + 2
        # # If you're at the end, attach to the start
        # next = wrap next


        # # Unless this element is excluded, attach the spring to the next neighbor
        # unless idx is exclude 
        #   console.info "attaching (#{idx}) -- (#{next})"
        #   circ.nextNeighborSpring = physicsEngine.attach repulse, $scope.circles[next], circ
        # else
        #   console.info "skipping (#{idx})"

    wrap = (idx) ->
      if idx >= $scope.circles.length 
        return idx - $scope.circles.length
      else
        return idx


    


    # Hack to hook repulsion strength up to a transitionable
    # prerender = ->
    #   # No force support yet
    #   strength = repulsionTrans.get()
      # repulse.setOptions
      #   strength: 2000#strength

      # gravity.applyForce $scope.projectName
      # $scope.projectName.applyForce(new Vector [0.01, 0, 0])



    # Engine.on 'prerender', prerender

    # Expand - circles fan out
    expand = ->
      # Make repulsion big, after a delay to avoid problems with circles starting in the same location
      repulsionTrans.set 5,
        duration: 200
        curve: 'easeInOut'
      , ->
        console.log 'done expanding'

      # Make the spring distance big
      for circ in $scope.circles
        circ.spring.setOptions
          length: 60

      expanded = true

      # TODO - set a velocity in a certain initial direction on each circle, to keep them from "sticking together" when the initial spring is set. This might make the above transitionable unnecessary

    # Contract - all circles merge into one small circle
    contract = ->
      # Kill repulsion
      repulse.setOptions 
        strength: 0
      # Kill spring 
      for circ in $scope.circles
        circ.spring.setOptions
          length: 0.01
      expanded = false

    bump = ->
      console.log 'bump'
      repulsionTrans.set 100, 
        duration: 100
      , ->
        repulsionTrans.set 5,
          duration: 100

    # Start off by expanding
    # contract()
    # setTimeout ->
    #   expand()
    # , 1000
    # expand()




    $scope.circleClicked = (circle, idx) ->

      # TODO - write a good touch/click accumulator for famo.us - basically, I want to run something on tap or click, and the scroll handling is a bit too touchy so I need to use touchstart :-z
      unless $scope.clicking
        $scope.clicking = true

        # Set the scrollview offset back to 0
        resetScrollview()

        $scope.project = $scope.projects[idx]

        circle.visited = true

        unless $scope.selected
          $scope.selected = true
          for circ, i in $scope.circles 
            # Circles to be shrunk
            unless circ is circle
              # circ.setPosition [Math.random(),Math.random()]
              circ.spring.setOptions
                anchor: cornerParticle
                length: $scope.springLengths.small * silverRatio
                dampingRatio: 0.6
              circ.setRadius circleSizes.small/2

              # Fade and hide the icons
              circ.iconScaler.set 0.3,
                duration: 50
              circ.iconFader.set 0,
                duration: 50

            # Circle to remain
            else
              # console.log 'circle to remain'
              circ.spring.setOptions
                anchor: [$scope.dims.w/2,topAnchor]
                dampingRatio: 0.5
                length: 0

              circ.setRadius circleSizes.big/2

              # make the circle sharp
              circ.fader.set 1,
                duration: 200

          console.log "circle #{idx} clicked!"

          repulse.setOptions
            length: $scope.springLengths.small

          # Reset the radial springs, excluding the current one
          setSprings idx

        else
          $scope.reset()

      $timeout ->
        $scope.clicking = false
      , 300

    resetScrollview = ->
      $scope.scrollView.setVelocity 0
      $scope.scrollView.setOffset 0
      $scope.scrollView.setPosition 0
      


    $scope.reset = (wait=false) ->

      # Could be called multiple times by a click vs a touchstart
      unless $scope.resetting
        $scope.resetting = true
        $scope.selected = false

        # Reset the scroll view
        resetScrollview()



        for circ in $scope.circles 
          circ.spring.setOptions
              anchor: centerParticle
              length: $scope.springLengths.big * silverRatio * 1
              dampingRatio: 0.4#0.3

          circ.setRadius circleSizes.big/2

          if wait 
            circ.iconScaler.delay 2500
            circ.iconFader.delay 2500
            damp = 0.3
          else
            circ.iconScaler.delay 50
            damp = 1

          circ.iconScaler.set 1,
            method: 'snap'
            dampingRatio: damp
            period: 300
          , ->
            $scope.resetting = false
          circ.iconFader.set 1,
            duration: 100
            curve: 'easeInOut'
          # $timeout ->
          # circ.iconFader.delay 2000
          # do (circ) ->
          #   $timeout ->
          #     console.log 'setting icon fader!'
          #     circ.iconFader.set 1,
          #       duration: 100
          #   , 5000
          # , 2000

          # Fade the circle if visited
          if circ.visited
            circ.fader.set 0.3,
              duration: 200
          # else
          #   circ.fader.set 1,
          #     duration: 200

        repulse.setOptions
          length: $scope.springLengths.big
          # length: new Transitionable $scope.springLengths.big,
          #   duration: 10000

        setSprings()

        # Have all the circles been visited?
        if (circ.visited for circ in $scope.circles when circ.visited).length is $scope.circles.length 
          # Reset all
          console.log 'resetting all!'
          for circ in $scope.circles 
            circ.visited = false
            # circ.fader.delay 2000
            do (circ) ->
              $timeout ->
                circ.applyForce new Vector [Math.random()*0.05-0.025,-0.1,0]
                circ.fader.set 1,
                  curve: 'easeInOut'
                  duration: 300
              , 2000

    # $scope.reset()

      # $scope.projectName.spring.setOptions
      #   anchor: circle
      #   length: 50

      # unless zoomedIn
      #   # we're zoomed out, so zoom in
      #   $scope.zoomIn()
      # else
      #   # we're zoomed in, so zoom out
      #   $scope.zoomOut()
      #   console.log 'no'

      # bump()

      # console.log circle
      # f = new Force [0,0,-10]
      # f.isZero = ->
      #   return false
      # console.log f
      # circle.applyForce f.force

    $scope.zoomIn = ->
      $scope.contentScaler.set [10,10],
        duration: 300
        curve: 'easeInOut'
      $scope.imageFader.set 1,
        duration: 300
        curve: 'easeInOut'
      $scope.scaler.set levels.in,
        duration: 300
        curve: 'easeInOut'
      , ->
        # bump()
      zoomedIn = true

    $scope.zoomOut = ->
      $scope.contentScaler.set [1,1],
        duration: 300
        curve: 'easeInOut'
      $scope.imageFader.set 0,
        duration: 300
        curve: 'easeInOut'
      $scope.scaler.set levels.out,
        duration: 300
        curve: 'easeInOut'
      zoomedIn = false

    # $scope.zoomIn()


    $scope.bumpCircle = (circ) ->
      console.log 'bump!'
      # unless $scope.selected
      #   console.log circ
      #   circ.iconFader.set 0.5,
      #     duration: 300
        # circ.applyForce new Vector [0,-0.005,0]


    

    # $timeout ->
    #   a = new Transitionable [200,0]
    #   spring.setOptions
    #     anchor: [1,1]
    #     length: 0.1
    # , 2000

    # $scope.scrollProps = 
    #   margin: 200

    # $scope.cardRotation = new Transitionable Math.PI/2

    # $timeout ->
    #   $scope.cardRotation.set 0,
    #     duration: 300
    #     curve: 'linear'
    # , 1000

    $scope.cardTranslation = new Transitionable [0,$scope.bottomCardPadding]
    $scope.cardMoving = false
    $scope.animateCardEnter = ($done) ->
      $scope.cardTranslation.set [0,0,1500],
        method: 'snap'
        dampingRatio: 0.4
        period: 300
      , ->
        $done()
        $scope.$apply ->
          $scope.showVideo = true
          console.log 'set to true'

    # $timeout ->


    $scope.animateCardLeave = ($done) ->
      $scope.cardTranslation.set [0,$scope.bottomCardPadding,1500],
        method: 'snap'
        dampingRatio: 0.5
        period: 200
      , ->
        $done()
        $scope.$apply ->
          $scope.showVideo = false
          console.log 'set to false'

    $scope.animateCardHalt = ->
      console.log 'halt called!'
      $scope.cardTranslation.halt()

    # $scope.cardParticle = new Particle
    #   position: [$scope.dims.w/2, $scope.dims.h/2]

    $scope.scrollOptions = 
      position: 200

    # $scope.viewProps = 
    #   style:
    #     paddingTop: 200

    # Not sure why this needs to be in a timeout
    $timeout ->
      $scope.scrollView = $famous.find('.outerScrollView')[0].renderNode
      console.log $scope.scrollView
      console.log 'scroll view ^^^'
    , 0

    # $timeout ->
    #   # scrollPos =  new Transitionable 0
    #   $scope.scrollView.setPosition 200
    #   # scrollPos.set 200,
    #   #   duration: 1000
    #   #   curve: 'easeInOut'
    # , 1000
    # 
    $scope.alert = (args) ->
      alert args

    $scope.nameOpacity = new Transitionable 0
    $scope.nameAnimation = 

      enter: ($done) ->
        $scope.nameOpacity.delay 200
        $scope.nameOpacity.set 1,
          duration: 300
        , $done

      leave: ($done) ->
        $scope.nameOpacity.set 0,
          duration: 50
        , $done

      halt: ($done) ->
        $scope.nameOpacity.halt()

    # Wait until the background image loads
    $timeout ->
      # Check for background image surface
      backgroundImageSurface = $famous.find('.backgroundImageSurface')[0]
      console.log backgroundImageSurface
      if backgroundImageSurface?.renderNode?._element
        console.log 'already deployed'
        # Element has been deployed, check if loaded
        if backgroundImageSurface.renderNode._element.complete
          # Element has been loaded
          console.log 'complete=true'
          begin()
        else
          # Wait for load
          backgroundImageSurface.renderNode._element.onload = ->
            console.log 'onload fired'
            begin()
      else
        console.log 'waiting for deploy...'
        backgroundImageSurface.renderNode.on 'deploy', ->
          console.log 'deploy happened'
          begin()
          # console.log backgroundImageSurface?.renderNode._element.complete

    # bootstrap = ->
    #   backgroundImageSurface = $famous.find('.backgroundImageSurface')[0]
    #   console.log "loaded is #{backgroundImageSurface?.renderNode._element?.complete}"
    #   $timeout bootstrap, 100
      # unless backgroundImageSurface?.renderNode._element
      #   console.warn 'no element found - are you using '
      #   $timeout bootstrap, 100
      # else
      #   if backgroundImageSurface.renderNode._element.complete
      #     # kick things off
      #     begin()
      #   else
      #     backgroundImageSurface.renderNode._element.onload = begin

    # bootstrap()

    begin = ->
      # alert 'starting now!'
      console.log 'let us begin'
      # Fade in the background image
      initPhysics()
      $scope.imageFader.set 1,
        duration: 500
        curve: 'easeInOut'
      , ->
        console.log 'init happening'



    $timeout ->
      console.log 'IMGIMG'
      circ = _.sample $scope.circles 
      # console.log circ
      # circ.rotationalSpring.setOptions
      #   anchor: [0,1000,0]
      #   length: 100
      # circ.applyTorque [0,.001,0]
      # newPos = new Transitionable circ.position
      # circ.setPosition newPos
      # newPos.set [0,0],
      #   duration: 5000
      # circ.applyTorque new Vector [0,0.1,0]

      # repulse.setOptions
      #   length: Math.random()*700
      #   dampingRatio: 0.11
      #   period: 700

      # setSprings()

      # circ = _.sample $scope.circles
      # console.log circ
      # spring = physicsEngine.getAgent(_.sample(circ.neighborSprings))
      # orig = spring.options.length
      # spring.setOptions
      #   length: 20

      # console.log 
    , 4000

