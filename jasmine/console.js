(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  window.Inspector = (function() {
    function Inspector(data) {
      this.data = data;
      this.examinedObjects = [];
    }
    Inspector.prototype.run = function() {
      var property, _i, _len, _ref, _results;
      _ref = this.inspect([], this.data);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        property = _ref[_i];
        _results.push(__bind(function(property) {
          return JHW.log(property.report());
        }, this)(property));
      }
      return _results;
    };
    Inspector.prototype.inspect = function(output, data, indent, key) {
      var newKey, obj, value, _i, _len, _ref;
      if (indent == null) {
        indent = 0;
      }
      if (key == null) {
        key = null;
      }
      _ref = this.examinedObjects;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        obj = _ref[_i];
        if (obj === data) {
          JHW.log("loop");
          output.push(new InspectedProperty("<< LOOP >>", key, indent));
          return output;
        }
      }
      this.examinedObjects.push(data);
      switch (typeof data) {
        case 'undefined':
          output.push(new InspectedProperty('undefined', key, indent));
          break;
        case 'string':
        case 'number':
        case 'boolean':
          output.push(new InspectedProperty(data, key, indent));
          break;
        default:
          output.push(new DefinedObject(key, indent));
          for (newKey in data) {
            value = data[newKey];
            JHW.log("trying " + newKey);
            if (data.hasOwnProperty(newKey)) {
              this.inspect(output, value, indent + 1, newKey);
            }
          }
      }
      return output;
    };
    return Inspector;
  })();
  window.IntendableProperty = (function() {
    function IntendableProperty() {}
    IntendableProperty.prototype.indentString = function(output) {
      var i, _fn, _ref;
      if (this.key != null) {
        output = "" + this.key + ": " + output;
      }
      if (this.indent > 0) {
        _fn = __bind(function(i) {
          return output = "  " + output;
        }, this);
        for (i = 1, _ref = this.indent; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
          _fn(i);
        }
      }
      return output;
    };
    return IntendableProperty;
  })();
  window.DefinedObject = (function() {
    function DefinedObject(key, indent) {
      this.key = key;
      this.indent = indent;
    }
    __extends(DefinedObject, window.IntendableProperty);
    DefinedObject.prototype.report = function() {
      return this.indentString("Object");
    };
    return DefinedObject;
  })();
  window.InspectedProperty = (function() {
    function InspectedProperty(data, key, indent) {
      this.data = data;
      this.key = key;
      this.indent = indent;
    }
    __extends(InspectedProperty, window.IntendableProperty);
    InspectedProperty.prototype.report = function() {
      var output;
      output = (function() {
        switch (typeof this.data) {
          case 'string':
            return "\"" + this.data + "\"";
            break;
          default:
            return this.data;
        }
      }).call(this);
      return this.indentString(output);
    };
    return InspectedProperty;
  })();
}).call(this);
