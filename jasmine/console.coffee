class window.Inspector
  constructor: (data) ->
    @data = data
    @examinedObjects = []
  run: ->
    for property in this.inspect([], @data)
      do (property) =>
        JHW.log(property.report())
  inspect: (output, data, indent = 0, key = null) ->
    for obj in @examinedObjects
      if obj == data
        JHW.log("loop")
        output.push(new InspectedProperty("<< LOOP >>", key, indent))
        return output
    @examinedObjects.push(data)

    switch typeof(data)
      when 'undefined'
        output.push(new InspectedProperty('undefined', key, indent))
      when 'string', 'number', 'boolean'
        output.push(new InspectedProperty(data, key, indent))
      else
        output.push(new DefinedObject(key, indent))
        for newKey, value of data
          JHW.log("trying #{newKey}")
          if data.hasOwnProperty(newKey)
            this.inspect(output, value, indent + 1, newKey)
    output

class window.IntendableProperty
  indentString: (output) ->
    if @key?
      output = "#{@key}: #{output}"
    if @indent > 0
      for i in [1..@indent]
        do (i) =>
          output = "  " + output
    output

class window.DefinedObject extends window.IntendableProperty
  constructor: (key, indent) ->
    @key = key
    @indent = indent
  report: ->
    this.indentString("Object")

class window.InspectedProperty extends window.IntendableProperty
  constructor: (data, key, indent) ->
    @data = data
    @key = key
    @indent = indent
  report: ->
    output = switch typeof(@data)
      when 'string'
        "\"#{@data}\""
      else
        @data
    this.indentString(output)
