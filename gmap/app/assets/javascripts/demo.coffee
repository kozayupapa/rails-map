# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.mymap= null
poly = null

#GoogleMapスタイル定義
map_style_options = [
    {
        featureType: 'all',
        elementType: 'geometry',
        stylers: [{ hue: '#6d4d38' }, { saturation: '-70' }, { gamma: '2.0' }]
    },
    {
        featureType: 'water',
        elementType: 'geometry',
        stylers: [{ color: "#acdcfa" }]
    }
    {
        featureType: 'all',
        elementType: 'labels',
        stylers: [{ lightness: "10" }]
    }
]


$(document).on "page:change", ->
        initialize()
        google.maps.event.addListener(window.mymap, 'idle', ->
                # 表示範囲を取得
                pos = window.mymap.getBounds()
                north = pos.getNorthEast().lat()
                south = pos.getSouthWest().lat()
                east    = pos.getNorthEast().lng()
                west = pos.getSouthWest().lng()
                # コントローラーに値をGETパラメータで渡す TODO: 表示範囲に変えて何か表示を変更したい場合
                #$.getScript("/users/marker?&north=#{north}&south=#{south}&east=#{east}&west=#{west}")
                console.log('window.mymap is in idle state')
)




this.initialize = ->
  latlng = new google.maps.LatLng(35.664410, 140.164880)
  opts = {
    zoom: 14
    center: latlng
    mapTypeId: google.maps.MapTypeId.ROADMAP
    scaleControl: true
  }
  window.mymap = new google.maps.Map(document.getElementById("map_canvas"), opts)

  # スタイル適用
  my_style = new google.maps.StyledMapType(map_style_options)
  window.mymap.mapTypes.set('MyStyle', my_style)
  window.mymap.setMapTypeId('MyStyle')


  # Add a listener for the click event
  if $('#enable_edit_path')[0]
    window.mymap.addListener('click', addLatLng)
    showLine()
  else if $('#enable_show_path')[0]
    showPolygon()
  else if $('#enable_show_allpaths')[0]
    console.log("hello all path")
    showPolygons()

showLine = ->
  poly = new google.maps.Polyline({
    strokeColor: '#000000',
    strokeOpacity: 1.0,
    strokeWeight: 3
  })
  poly.setMap(window.mymap)

  lonlatarray=[]
  for llstr in $('#user_address').val().split('/')
    llstr=llstr.slice(1,-1)
    ll=llstr.split(',')
    lonlatarray.push(new google.maps.LatLng(ll[0],ll[1])) 
  console.log(lonlatarray)
  poly.setPath(lonlatarray)

showPolygon = ->
  poly = new google.maps.Polygon({
    strokeColor: '#000000',
    strokeOpacity: 1.0,
    strokeWeight: 3
  })
  poly.setMap(window.mymap)
  lonlatarray=[]
  # erb で埋め込まれた値を取得する
  for llstr in $('#a_user').data("address").split('/')
    llstr=llstr.slice(1,-1)
    ll=llstr.split(',')
    lonlatarray.push(new google.maps.LatLng(ll[0],ll[1])) 
  console.log(lonlatarray)
  poly.setPath(lonlatarray)

showPolygons = ->
  # Ajax でサーバーから取得する
  $.getScript("/users/area")
  


###
Handles click events on a map, and adds a new point to the Polyline.
###
this.addLatLng =(event)->
  path = poly.getPath();

  # Because path is an MVCArray, we can simply append a new coordinate
  # and it will automatically appear.
  path.push(event.latLng);

  # アドレスとしてline のPathを保存する
  $('#user_address').val(path.getArray().join "/")

  # 最後のlon lat をuserの場所として保存する (TODO:平均をとりたい)
  $('#user_latitude').val(event.latLng.lat())
  $('#user_longitude').val(event.latLng.lng())





