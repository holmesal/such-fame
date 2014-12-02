'use strict'

angular.module('portfolioApp')
  .controller 'MainCtrl', ($scope, $famous, $timeout, $window) ->

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
    Force = $famous['famous/physics/forces/Force']
    Distance = $famous['famous/physics/constraints/Distance']
    Vector = $famous['famous/math/Vector']
    Scrollview = $famous['famous/views/Scrollview'];

    # transitions
    SnapTransition = $famous['famous/transitions/SnapTransition']
    Transitionable.registerMethod 'snap', SnapTransition

    $scope.projects = [
      name: 'Hashtag'
      icon: 'images/icons/hashtag.svg'
      description: 'Awesome group chat for all of the thingsss'
      template: 'views/projects/hashtag.html'
      size: [20,true]
    ,
      name: 'Hero'
      icon: 'images/icons/hero.svg'
      description: 'Humanitarian emergency response UAV'
      template: 'views/projects/hero.html'
      size: [50,true]
    ,
      name: 'Shortwave'
      icon: 'images/icons/shortwave.svg'
      description: 'A chat room with a 100-foot range'
      template: 'views/projects/shortwave.html'
      size: [40,true]
    ,
      name: 'hey i\'m alonso'
      icon: 'images/icons/alonso.svg'
      description: ''
      template: 'views/projects/alonso.html'
      size: [35,true]
    ]

    numCircles = $scope.projects.length#6
    circleSizes = 
      big: 70
      small: 5
    $scope.circleSize = circleSizes.big
    $scope.dims =
      w: $window.innerWidth
      h: $window.innerHeight

    topAnchor = $scope.dims.h * 0.2

    console.log $scope.dims
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

    # How much space between the bottom of the screen and the popup card
    $scope.bottomCardPadding = $scope.dims.h * 0.4

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
    console.log $scope.scrollEventHandler

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
      position: [$scope.dims.w/2, $scope.dims.h/2]

    # Corner particle
    $scope.cornerPosition = [$scope.dims.w-50, 50]
    cornerParticle = new Particle 
      position: $scope.cornerPosition
    console.log cornerParticle

    # Name
    namePosition = topAnchor + circleSizes.big + 30
    $scope.projectName = new Particle 
      position: [$scope.dims.w/2, namePosition]
    # $scope.projectName.spring = new Spring 
    #   length: 0
    #   anchor: [centerParticle]
    physicsEngine.addBody $scope.projectName

    # # Description
    # descriptionPosition = namePosition + 100
    # $scope.projectDescription = new Particle 
    #   position: [$scope.dims.w/2, descriptionPosition]
    # # $scope.projectDescription.spring = new Spring 
    # #   length: 0
    # #   anchor: [centerParticle]
    # physicsEngine.addBody $scope.projectDescription






    for i in [0...numCircles]
      circ = new Circle 
        radius: circleSizes.big/2
        position: [$scope.dims.w/2 + Math.random()*0.0000001, $scope.dims.h/2 + Math.random()*0.0000001]
        # position: [width + Math.random()*0.0000001, height + Math.random()*0.000001]
      # console.log circ

      circ._id = Math.random()

      # Fader and scaler for icons
      circ.iconScaler = new Transitionable 1
      circ.iconFader = new Transitionable 1

      # Add
      physicsEngine.addBody circ 

      # Store ref to color
      $scope.colorMap[circ._id] = _.sample colors

      $scope.circles.push circ

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
      dampingRatio: 0.3


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

    spin = (first = false) ->
      console.log "it is now #{Date.now()/1000}"
      period = 3000
      duration = 300
      if first
        # Sleep until nearest whole period
        millis = period - ((Date.now()/1000) % (period/1000)) * 1000
        console.log "it is now #{Date.now()/1000} - sleeping #{millis} until #{Date.now()/1000 + millis/1000}"
        $timeout spin, millis
      else
        # Pick a random location
        location = ((Date.now()/100000) % 1) * 3.14
        location = Math.random()*3.14
        console.log 'spinning to ' + location
        $scope.spinner.set location,
          duration: duration
          curve: 'easeInOut'
        , ->
          # spin()
          delay = Math.random() * 10000
          delay = period - duration
          $timeout spin, delay
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


    # Attach all the things
    for circ, idx in $scope.circles 
      # Make the spring
      circ.spring = new Spring
        anchor: centerParticle#[0.5,0.5]#[width/2, height/2]
        period: 300
        dampingRatio: 0.3
        # forceFunction: Spring.FORCE_FUNCTIONS.FENE

      # Attach the repulsion
      # physicsEngine.attach repulse, $scope.circles, circ
      # Attach the spring
      physicsEngine.attach circ.spring, circ 
      # Attach the collisions
      physicsEngine.attach collision, $scope.circles, circ

      # Attach to the next spring
      prev = idx - 1
      if prev < 0
        prev = $scope.circles.length - 1
      next = idx + 1
      if next is $scope.circles.length
        next = 0
      
      # circ.neighborSprings.prev = physicsEngine.attach repulse, $scope.circles[prev], circ
    setSprings()


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
        console.log 'done'

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

    $scope.circleClicked = (circle, idx) ->

      $scope.project = $scope.projects[idx]

      unless $scope.selected
        $scope.selected = true
        for circ in $scope.circles 
          # Circles to be shrunk
          unless circ is circle
            # circ.setPosition [Math.random(),Math.random()]
            circ.spring.setOptions
              anchor: cornerParticle
              length: $scope.springLengths.small * silverRatio
              dampingRatio: 0.5
            circ.setRadius circleSizes.small/2

            # Fade and hide the icons
            circ.iconScaler.set 0.3,
              duration: 200
            circ.iconFader.set 0,
              duration: 200

          # Circle to remain
          else

            circ.spring.setOptions
              anchor: [$scope.dims.w/2,topAnchor]
              dampingRatio: 0.5
              length: 0

            circ.setRadius circleSizes.big/2

        console.log "circle #{idx} clicked!"

        repulse.setOptions
          length: $scope.springLengths.small

        # Reset the radial springs, excluding the current one
        setSprings idx

      else
        $scope.reset()
      


    $scope.reset = ->
      $scope.selected = false
      for circ in $scope.circles 
        circ.spring.setOptions
            anchor: centerParticle
            length: $scope.springLengths.big * silverRatio
            dampingRatio: 0.3

        circ.setRadius circleSizes.big/2

        circ.iconScaler.delay 50
        circ.iconScaler.set 1,
          duration: 200
        circ.iconFader.set 1,
          duration: 100

      repulse.setOptions
        length: $scope.springLengths.big

      # $timeout setSprings, 100

      setSprings()

    $scope.reset()

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

    $scope.zoomIn()


    physicsEngine.attach walls, $scope.circles

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
      $scope.cardTranslation.set [0,0],
        method: 'snap'
        dampingRatio: 0.2
        period: 300
      , $done

    # $timeout ->


    $scope.animateCardLeave = ($done) ->
      $scope.cardTranslation.set [0,$scope.bottomCardPadding],
        method: 'snap'
        dampingRatio: 0.5
        period: 200
      , $done

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

