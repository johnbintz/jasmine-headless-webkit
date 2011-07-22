function yes() {
  $('body').append('<form action="something" method="post"><button /><form>')
  $('button').trigger('click')
}

