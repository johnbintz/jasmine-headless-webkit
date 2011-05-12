require 'coffee-script'

FILE = 'jasmine/jasmine.headless-reporter.coffee' if !self.class.const_defined?(:FILE)
TARGET = FILE.gsub('.coffee', '.js') if !self.class.const_defined?(:TARGET)

watch(FILE) { coffee }

def coffee
  begin
    File.open(TARGET, 'w') { |fh| fh.print CoffeeScript.compile File.open(FILE) }
    puts "Wrote #{TARGET}"
  rescue Exception => e
    puts e.message
  end
end

coffee

