window.Intense = {
  colors:
    black: 0
    red: 1
    green: 2
    yellow: 3
    blue: 4
    magenta: 5
    cyan: 6
    white: 7
  methods:
    foreground: (color) ->
      "\033[3#{Intense.colors[color]}m#{this}\033[0m"
    bright: ->
      "\033[1m#{this}\033[0m"
}

for method, code of Intense.methods
  String.prototype[method] = code

