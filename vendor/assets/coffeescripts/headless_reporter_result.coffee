# Try to get the line number of a failed spec
class window.HeadlessReporterResult
  constructor: (@name, @splitName) ->
    @results = []

  addResult: (message) ->
    @results.push(message)

  toString: ->
    output = "\n" + @name.foreground('red')
    bestChoice = HeadlessReporterResult.findSpecLine(@splitName)
    output += " (#{bestChoice.file}:#{bestChoice.lineNumber})".foreground('blue') if bestChoice.file

    for result in @results
      line = result.message.foreground('red')
      if result.lineNumber
        line += " (line ~#{bestChoice.lineNumber + result.lineNumber})".foreground('red').bright()
      output += "\n  #{line}"

      if result.line?
        output += "\n    #{result.line}".foreground('yellow')

    output

  @findSpecLine: (splitName) ->
    bestChoice = { accuracy: 0, file: null, lineNumber: null }

    for file, lines of HeadlessReporterResult.specLineNumbers
      index = 0
      lineNumber = 0
      while newLineNumberInfo = lines[splitName[index]]
        if newLineNumberInfo.length == 0
          lineNumber = newLineNumberInfo[0]
        else
          lastLine = null
          for line in newLineNumberInfo
            lastLine = line
            break if line > lineNumber

          lineNumber = lastLine

        index++

      if index > bestChoice.accuracy
        bestChoice = { accuracy: index, file: file, lineNumber: lineNumber }

      break if index == splitName.length

    bestChoice
