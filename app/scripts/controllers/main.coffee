'use strict'

angular.module('portfolioApp')
  .controller 'MainCtrl', ($scope, $famous, $timeout, $window) ->

    # Famous init
    EventHandler = $famous['famous/core/EventHandler']
    Engine = $famous['famous/core/Engine']

    init = ->
      # Event handler
      $scope.horizontalScrollHandler = new EventHandler

      # Set up the pages
      for page in $scope.pages
        page.verticalScrollHandler = new EventHandler
        # Pipe all events from the vertical scroll to the horizontal scroll
        page.verticalScrollHandler.pipe $scope.horizontalScrollHandler

        page.contentHandler = new EventHandler
        page.contentHandler.pipe page.verticalScrollHandler

      # On window resize
      # TODO - this doesn't actually cause famous to re-render - figure out how to do that
      Engine.on 'resize', setLayout
      # And also right away
      setLayout()





    $scope.props =
      title:
        textAlign: 'center'
        lineHeight: '100px'
      content:
        padding: '30px'
        textAlign: 'justify'
      clipped:
        backgroundImage: "url(http://33.media.tumblr.com/537d8986d6b8df79a9fd6901e7174fe2/tumblr_nbk5oaEN2n1st5lhmo1_1280.jpg)"

    $scope.options = 
      channels: 
        friction: 0.002
        drag: 0.001

      slider:
        direction: 1

      horizontalScrollView:
        direction: 0
        paginated: true
        friction: 0.002
        drag: 0.001

      clipped:
        classes: ['clipped']
        size: [undefined,270]
        origin: [0.5,0.5]
        align: [0.5,0.5]
        properties:
          overflow: 'hidden'

      grid:
        dimensions: [2,1]


    

    $scope.pages = [
        title: 'alonso',
        image: 'http://31.media.tumblr.com/280a265f4280a671a98657cce2950bb2/tumblr_nbk6auQG2K1st5lhmo1_1280.jpg'
        content: 'views/content/alonso.html'
      ,
        title: 'another',
        image: 'http://33.media.tumblr.com/d59fde7754e24629be674872632e7556/tumblr_nb1udanVmD1st5lhmo1_1280.jpg'
        content: 'views/content/alonso.html'
      ,
        title: 'third',
        image: 'http://38.media.tumblr.com/bae910978b35b87f5e22b3165b4fb567/tumblr_nbk5l16U5S1st5lhmo1_1280.jpg'
        content: 'views/content/alonso.html'
      ,
        title: 'fourth',
        image: 'http://33.media.tumblr.com/537d8986d6b8df79a9fd6901e7174fe2/tumblr_nbk5oaEN2n1st5lhmo1_1280.jpg'
        content: 'views/content/alonso.html'
    ]



    $scope.getImageProps = (page) ->
      props = 
        backgroundSize: 'cover'
        backgroundPosition: 'center center'
        backgroundImage: "url(#{page.image})"

    

    # Set the window layout
    setLayout = ->
      if window.innerWidth < window.innerHeight
        $scope.layout = 'vertical'
        $scope.options.grid.dimensions = [1,1]
      else
        $scope.layout = 'horizontal'
        $scope.options.grid.dimensions = [2,1]

      console.log "set layout to #{$scope.layout}"
      # $scope.$apply ->
    


    init()