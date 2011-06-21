case RUBY_PLATFORM
when /linux/
	system %{qmake -spec linux-g++}
else
	system %{qmake -spec macx-g++}
end

system %{make}
