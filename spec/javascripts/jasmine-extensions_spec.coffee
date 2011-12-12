describe 'jasmine.Suite.prototype.getSuiteSplitName', ->
  it 'should flatten the description', ->
    suite = new jasmine.Suite({});
    suite.description = "hello\ngoodbye\n";
    expect(suite.getSuiteSplitName()).toEqual([ "hello goodbye " ])

  it 'should not fail on missing description', ->
    suite = new jasmine.Suite({});
    suite.description = 1;
    expect(suite.getSuiteSplitName()).toEqual([ "1" ])

describe 'jasmine.Spec.prototype.getSuiteSplitName', ->
  it 'should flatten the description', ->
    spec = new jasmine.Spec({}, {});
    spec.suite = {
      getSuiteSplitName: -> []
    }
    spec.description = "hello\ngoodbye\n";
    expect(spec.getSpecSplitName()).toEqual([ "hello goodbye " ])

  it 'should not fail on missing description', ->
    spec = new jasmine.Spec({}, {});
    spec.suite = {
      getSuiteSplitName: -> []
    }
    spec.description = 1
    expect(spec.getSpecSplitName()).toEqual([ "1" ])

describe 'jasmine.Spec.prototype.getJHWSpecInformation', ->
  it 'should append null when there is no file information', ->
    spec = new jasmine.Spec({}, {})
    spyOn(spec, 'getSpecSplitName').andReturn(["one"])
    spyOn(HeadlessReporterResult, 'findSpecLine').andReturn({})
    expect(spec.getJHWSpecInformation()).toEqual("one||")

describe 'jasmine.WaitsBlock and jasmine.WaitsForBlock', ->
  beforeEach ->
  it 'should notify JHW of waiting', ->
    waits(5500)
    runs ->
      expect(true).toEqual(true)

  it 'should notify JHW of waiting for something', ->
    value = false

    setTimeout(
      -> 
        value = true
      , 5000
    )

    waitsFor(
      ->
        value
      , "Nope"
      5500
    )

    runs ->
      expect(true).toEqual(true)

describe 'jasmine.NestedResults.isValidSpecLine', ->
  it 'should check the lines', ->
    expect(jasmine.NestedResults.isValidSpecLine('yes')).toEqual(false)
    expect(jasmine.NestedResults.isValidSpecLine('expect')).toEqual(true)
    expect(jasmine.NestedResults.isValidSpecLine(' expect')).toEqual(true)
    expect(jasmine.NestedResults.isValidSpecLine('return expect')).toEqual(true)
    expect(jasmine.NestedResults.isValidSpecLine(' return expect')).toEqual(true)

describe 'jasmine.nestedResults.parseFunction', ->
  it 'should parse the function', ->
    expect(jasmine.NestedResults.parseFunction("""
test
expect("cat")
  return expect("dog")
    """)).toEqual([
      [ 'expect("cat")', 1 ],
      [ 'expect("dog")', 2 ]
    ])

