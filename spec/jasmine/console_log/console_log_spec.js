describe('console.log', function() {
  it('should succeed, but with a console.log', function() {
    console.log("hello");
    expect(success).toEqual(1);
  });
});

