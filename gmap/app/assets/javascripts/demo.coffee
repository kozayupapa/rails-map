# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.mymap= null
marker1 = null
marker2 = null

console.log('hello coffe erb')
$(document).on "page:change", ->
        initialize()
        google.maps.event.addListener(window.mymap, 'idle', ->
                # 表示範囲を取得
                pos = window.mymap.getBounds()
                north = pos.getNorthEast().lat()
                south = pos.getSouthWest().lat()
                east    = pos.getNorthEast().lng()
                west = pos.getSouthWest().lng()
                # コントローラーに値をGETパラメータで渡す
                $.getScript("/users/marker?&north=#{north}&south=#{south}&east=#{east}&west=#{west}")
                console.log('this is in idle coffe erb')
)



# スタイル定義
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



if $('#map_canvas').length
    # 鳥取駅をデフォルトの位置とする
    default_point = new google.maps.LatLng(35.494317, 134.225368)

    # マップ作成
    # map_canvasというIDがついているdivを指定
    window.big_map = new google.maps.Map(
        document.getElementById('map_canvas'),
        {
        center: default_point, #設定しないとSafariで表示されなかった
        zoom: 16,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        scaleControl: true
        }
    )

    # ユーザーの現在位置取得を試みる
    if navigator.geolocation
        # 鳥取県の範囲を指定
        tottori_area_coords = [
            new google.maps.LatLng(35.57985414012871, 133.12805255937496),
            new google.maps.LatLng(35.65130415054386, 134.52331623124996),
            new google.maps.LatLng(35.16778016004279, 134.56726154374996),
            new google.maps.LatLng(34.99696260051415, 133.05114826249996)
        ]
        tottori_area = new google.maps.Polygon({ paths: tottori_area_coords })

        # ユーザーの現在位置が鳥取県の範囲内だったら、
        # 現在位置を中心とした地図にする
        navigator.geolocation.getCurrentPosition (position) ->
            current_location = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
            if google.maps.geometry.poly.containsLocation(current_location, tottori_area)
                big_map.setCenter(current_location)
            # 鳥取県意外から見られている場合は、鳥取駅を表示する
            else
                big_map.setCenter(default_point)
    # geolocationが有効でなければ、鳥取駅を表示する
    else
        big_map.setCenter(default_point)
