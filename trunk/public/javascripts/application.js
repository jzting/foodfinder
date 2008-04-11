// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


Object.extend(Event,{
 // check whether or not the DOM element is ready
 onElementReady: function(el)
 {
	element = document.getElementById(el);
alert(element);	
	/*
   if( element && (element.nextSibling || element.textContent) ){
     alert('woot!');
   }
   else{
		alert('wtf...');
		alert(element);
      	setTimeout( this.onElementReady.bind(this, element,function(e) { alert('woot!')}), 1 );
   }
*/

 }
});


function callback() {
alert('hello!');
}

function loadMap(lat, long, address) {
	var map;	
	map = new GMap2(document.getElementById("map"));
	map.setCenter(new GLatLng(lat, long),15);
	map.addOverlay(addInfoWindowToMarker(new GMarker(new GLatLng(lat, long)), address,{}));
	map.addControl(new GLargeMapControl());
	map.addControl(new GMapTypeControl());

}

function updateSearch() { $('search').value = "AGAIN!" }

function toggleLoader(toggle) { if(toggle)  $('spinner').show(); else $('spinner').hide(); }

