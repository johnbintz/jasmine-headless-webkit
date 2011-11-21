describe('console.log', function() {
  it('should succeed, but with a console.log', function() {
    console.log("hello");
    expect(success).toEqual(1);
  });

  it("wont eat my precious jqueries", function() {
    var d = $('<div><div id="inner">b</div></div>');
    expect(d.find('#inner').length).toBe(1);
    console.log(d.find('#inner'));
    expect(d.find('#inner').length).toBe(1);
  });
});

