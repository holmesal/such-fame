'use strict'

angular.module('portfolioApp')
  .controller 'MainCtrl', ($scope, $famous, $timeout, $window) ->

    # Famous init
    EventHandler = $famous['famous/core/EventHandler']
    Engine = $famous['famous/core/Engine']
    PhysicsEngine = $famous['famous/physics/PhysicsEngine']
    Circle = $famous['famous/physics/bodies/Circle']
    Transitionable = $famous['famous/transitions/Transitionable']
    Wall = $famous['famous/physics/constraints/Wall']
    Walls = $famous['famous/physics/constraints/Walls']
    Collision = $famous['famous/physics/constraints/Collision']
    Repulsion = $famous['famous/physics/forces/Repulsion']
    Spring = $famous['famous/physics/forces/Spring']
    Force = $famous['famous/physics/forces/Force']
    Distance = $famous['famous/physics/constraints/Distance']
    Vector = $famous['famous/math/Vector']

    numCircles = 5
    $scope.circleSize = 70
    $scope.dims =
      w: $window.innerWidth
      h: $window.innerHeight
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

    for i in [0...numCircles]
      circ = new Circle 
        radius: $scope.circleSize/2
        # position: [width, height]
        position: [width + Math.random()*0.0000001, height + Math.random()*0.000001]

      circ._id = Math.random()

      # Add
      physicsEngine.addBody circ 

      # Store ref to color
      $scope.colorMap[circ._id] = _.sample colors

      $scope.circles.push circ


    # Transitionable for repulsion
    repulsionTrans = new Transitionable 0
    # Circle-circle repulsion 
    repulse = new Repulsion

    $scope.spinner = new Transitionable 0

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
    spin true


    # Circle-center spring 
    spring = new Spring
      anchor: [0.5,0.5]#[width/2, height/2]
      period: 300
      dampingRatio: 0.6

    # Attach all the things
    for circ in $scope.circles 
      # Attach the repulsion
      physicsEngine.attach repulse, $scope.circles, circ
      # Attach the spring
      physicsEngine.attach spring, circ 
      # console.log 'ok'

    # Hack to hook repulsion strength up to a transitionable
    prerender = ->
      # No force support yet
      strength = repulsionTrans.get()
      repulse.setOptions
        strength: strength

    Engine.on 'prerender', prerender

    # Expand - circles fan out
    expand = ->
      # Make repulsion big, after a delay to avoid problems with circles starting in the same location
      repulsionTrans.set 5,
        duration: 200
        curve: 'easeInOut'
      , ->
        console.log 'done'

      # Make the spring distance big
      spring.setOptions
        length: 110

      expanded = true

      # TODO - set a velocity in a certain initial direction on each circle, to keep them from "sticking together" when the initial spring is set. This might make the above transitionable unnecessary

    # Contract - all circles merge into one small circle
    contract = ->
      # Kill repulsion
      repulse.setOptions 
        strength: 0
      # Kill spring 
      spring.setOptions
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
    contract()
    setTimeout ->
      expand()
      console.log 'hi'
    , 1000


    # Walls
    walls = [
      new Wall
        normal: [1,0,0]
        distance: 0
        restitution: 0.1
    ,
      new Wall
        normal: [-1,0,0]
        distance: width
        restitution: 0.1
    ,
      new Wall
        normal: [0,1,0]
        distance: 0
        restitution: 0.1
    ,
      new Wall
        normal: [0,-1,0]
        distance: height
        restitution: 0.1
    ]

    $scope.circleClicked = (circle) ->
      unless zoomedIn
        # we're zoomed out, so zoom in
        $scope.zoomIn()
      else
        # we're zoomed in, so zoom out
        $scope.zoomOut()
        console.log 'no'

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

    # Then animate out
    # $timeout $scope.zoomOut, 3000

    $scope.zoomIn()


    # physicsEngine.attach walls, $scope.circles

    # $timeout ->
    #   a = new Transitionable [200,0]
    #   spring.setOptions
    #     anchor: [1,1]
    #     length: 0.1
    # , 2000