//= require 'things/code'

describe('code', function() {
  it('should equal 1', function() {
    expect(window.a).toEqual(1)
    expect(jQuery).not.toBeUndefined()
  });
});

