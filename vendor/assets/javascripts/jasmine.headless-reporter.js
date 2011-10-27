(function() {
  if (!(typeof jasmine !== "undefined" && jasmine !== null)) {
    throw new Error("jasmine not laoded!");
  }
  jasmine.HeadlessReporter = (function() {
    function HeadlessReporter() {}
    return HeadlessReporter;
  })();
}).call(this);
