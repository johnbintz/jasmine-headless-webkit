require 'rbconfig'

module Qt
  class NotInstalledError < StandardError; end

  class Qmake
    class << self
      def installed?
        path != nil
      end

      def make_installed?
        make_path != nil
      end

      def command
        case platform
        when :linux
          "#{path} -spec linux-g++"
        when :mac_os_x
          "#{path} -spec macx-g++"
        end
      end

      def make!(name)
        @name = name

        check_make!
        check_qmake!
        check_qmake_version!

        system command
        system %{make}
      end

      #
      # We need integration tests for these!
      #
      def path
        get_exe_path('qmake')
      end

      def make_path
        get_exe_path('make')
      end

      def platform
        case RbConfig::CONFIG['host_os']
        when /linux/
          :linux
        when /darwin/
          :mac_os_x
        end
      end

      def qt_version
        @qt_version ||= %x{#{path} -v}.lines.to_a[1][%r{Using Qt version ([^ ]+) },1]
      end

      def qt_47_or_better?
        return false if !qt_version
        return true if (major = qt_version.split('.')[0].to_i) > 4
        return false if major < 4
        qt_version.split('.')[1].to_i >= 7
      end

      private
      def get_exe_path(command)
        path = %x{which #{command}}.strip
        path = nil if path == ''
        path
      end

      def check_make!
        if !make_installed?
          install_method = (
            case platform
            when :linux
              %{sudo apt-get install make or sudo yum install make}
            when :darwin
              %{Install XCode, and/or sudo port install make}
            end
          )

          $stderr.puts <<-MSG
make is not installed. You'll need to install it to build #{@name}.
#{install_method} should do it for you.
MSG
          raise NotInstalledError
        end
      end

      def check_qmake!
        if !installed?
          install_method = strip(
            case platform
            when :linux
              <<-MSG
sudo apt-get install libqt4-dev qt4-qmake on Debian-based systems, or downloading
Nokia's prebuilt binary at http://qt.nokia.com/downloads/
MSG
            when :darwin
              <<-MSG
sudo port install qt4-mac (for the patient) or downloading Nokia's pre-built binary
at http://qt.nokia.com/downloads/
MSG
            end
          )

          $stderr.puts <<-MSG
qmake is not installed. You'll need to install it to build #{@name}.
#{install_method} should do it for you.
MSG
        end
      end

      def check_qmake_version!
        if !qt_47_or_better?
          install_method = strip(
            case platform
            when :linux
              <<-MSG
sudo apt-get install libqt4-dev qt4-qmake on Debian-based systems, or downloading
Nokia's prebuilt binary at http://qt.nokia.com/downloads/
MSG
            when :darwin
              <<-MSG
sudo port install qt4-mac (for the patient) or downloading Nokia's pre-built binary
at http://qt.nokia.com/downloads/
MSG
            end
          )

          $stderr.puts <<-MSG
qmake is not version 4.7 or above (currently version #{qt_version}. You'll need to install version 4.7 or higher
to build #{@name}. #{install_method} should do it for you.
MSG
        end
      end
    end
  end
end

