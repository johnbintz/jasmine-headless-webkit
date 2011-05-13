require 'coffee-script'

watch('(jasmine/.*)\.coffee') { |m| coffee(m[1]) }

def coffee(file)
  begin
    File.open(file + '.js', 'w') { |fh| fh.print CoffeeScript.compile File.open(file + '.coffee') }
    puts "Wrote #{file}"
  rescue Exception => e
    puts e.message
  end
end

