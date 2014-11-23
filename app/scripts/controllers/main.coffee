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
    Distance = $famous['famous/physics/constraints/Distance']
    Vector = $famous['famous/math/Vector']

    numCircles = 5
    $scope.circleSize = 50
    $scope.dims =
      w: $window.innerWidth
      h: $window.innerHeight
    # width = $window.innerWidth#320
    # height = $window.innerHeight# 320
    width = 0.5
    height = 0.5
    DISTANCE = 200
    expanded = true # layout state tracker
    # colors = ["#b58900","#cb4b16","#dc322f","#d33682","#6c71c4","#268bd2","#2aa198","#859900"]
    colors = ["#575757"]

    # Zoom levels
    levels = 
      out: [0.1,0.1]
      in: [1,1]
    $scope.scaler = new Transitionable levels.out


    $scope.colorMap = {}
    $scope.circles = []

    $scope.opts = 
      size: [500,500]

    physicsEngine = new PhysicsEngine

    # Create some circles
    $scope.colorMap = {}

    for i in [0..numCircles]
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
        length: 90

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

    $scope.circleClicked = ->
      if $scope.scaler.get() is levels.out 
        # we're zoomed out, so zoom in
        $scope.zoomIn()
      else
        # we're zoomed in, so zoom out
        $scope.scaler.set levels.out,
          duration: 300
          curve: 'easeInOut'

    $scope.zoomIn = ->
      $scope.scaler.set levels.in,
        duration: 300
        curve: 'easeInOut'


    $scope.scrollEventHandler = new EventHandler


    # physicsEngine.attach walls, $scope.circles

    # $timeout ->
    #   a = new Transitionable [200,0]
    #   spring.setOptions
    #     anchor: [1,1]
    #     length: 0.1
    # , 2000