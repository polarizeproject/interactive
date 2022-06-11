
var leading = 60
    var wheel = 0
    var offset = 0
    var lastOffset = 0

    window.addEventListener('mousewheel', function(event) {
      event.preventDefault()
      wheel += event.deltaY

      offset = Math.floor((wheel / leading)) * leading

      if(lastOffset !== offset) onOffset(event.deltaY > 0)

      lastOffset = offset
    })


    function onOffset(up) {


      (document.querySelectorAll('#text')).forEach(function(el, i) {
        var lines = el.innerHTML.trim().split('\n')

        if(i % 2 === (up ? 0 : 1)) {
         lines.unshift(lines.pop())
        } else {
             lines.push(lines.shift())
        }

        el.innerHTML = lines.join('\n')
      })
    }


 
// SHUFFLE DEI VERSI

const text = document.getElementById('text');

function rndPoem() {

  const lines = text
  .innerHTML.split(/<br>/)
  .map(line => line.trim());

  for (let i = lines.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [lines[i], lines[j]] = [lines[j], lines[i]];
  }

  return lines.join('<br>');

}


text.innerHTML = rndPoem();

