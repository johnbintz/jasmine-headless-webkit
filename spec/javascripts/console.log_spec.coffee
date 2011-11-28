#= require jquery

describe 'console.log', ->
  it 'should not eat my precious jqueries', ->
    _log = JHW.log

    JHW.log = ->

    d = $('<div><div id="inner">b</div></div>');
    expect(d.find('#inner').length).toBe(1);
    console.log(d.find('#inner'));
    expect(d.find('#inner').length).toBe(1);

    JHW.log = _log

