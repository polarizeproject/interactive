function each(obj,callback) {
  obj = ( typeof obj === 'string' ? document.querySelectorAll(obj) :
         obj instanceof Node ? [obj] : obj );

  var length = obj.length,
      i = 0;

  for ( ; i < length; i++ ) {
    if ( callback.call( obj[ i ], i, obj[ i ] ) === false ) { break; }
  }
}

each('.slide-text',function(){
  var elem = this,
      characters = elem.innerText.split(''),
      content = '';
  
  each(characters,function(i,c){
    content += '<b class="st_c"><b class="st_c_c">' + c + '</b></b>';
  });

  elem.className += ' st';
  elem.innerHTML = content;

});