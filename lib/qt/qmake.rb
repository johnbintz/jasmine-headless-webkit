require 'rbconfig'
require 'rubygems'
require 'rubygems/version'

module Qt
  class NotInstalledError < StandardError; end
  class Qmake
    class << self
      QMAKES = %w{qmake-qt4 qmake}

      def installed?
        path != nil
      end

      def make_installed?
        make_path != nil
      end

      def command(project_file = nil)
        spec = (case platform
        when :linux
          "linux-g++"
        when :freebsd
          "freebsd-g++"
        when :mac_os_x
          "macx-g++"
        end)

        command = "#{path} #{envs} -spec #{spec}"
        command << " #{project_file}" if project_file
        command
      end

      def make!(name, project_file = nil)
        @name = name

        check_make!
        check_qmake!

        system command(project_file)

        system %{make}
      end

      #
      # We need integration tests for these!
      #
      def path
        @path ||= best_qmake
      end

      def make_path
        get_exe_path('gmake') || get_exe_path('make')
      end

      def platform
        case RbConfig::CONFIG['host_os']
        when /linux/
          :linux
        when /freebsd/i
          :freebsd
        when /darwin/
          :mac_os_x
        end
      end

      def qt_version_of(qmake_path)
        Gem::Version.new(%x{#{qmake_path} -v}.lines.to_a[1][%r{Using Qt version ([^ ]+) },1])
      end

      def best_qmake
        if qmake_path = QMAKES.collect do |path|
          result = nil
          if qmake_path = get_exe_path(path)
            if (qt_version = qt_version_of(qmake_path)) >= Gem::Version.create('4.7')
              result = [ qmake_path, qt_version ]
            end
          end
          result
        end.compact.sort { |a, b| b.last <=> a.last }.first
        qmake_path.first
        else
          nil
        end
      end

      private
      def envs
        %w{QMAKE_CC QMAKE_CXX}.collect do |env|
          if ENV[env]
            "#{env}=#{ENV[env]}"
          end
        end.compact.join(" ")
      end

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
            when :freebsd
              %{install /usr/ports/devel/gmake}
            when :mac_os_x
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
          install_method = (
            case platform
            when :linux
              <<-MSG
  sudo apt-get install libqt4-dev qt4-qmake on Debian-based systems, or downloading
  Nokia's prebuilt binary at http://qt.nokia.com/downloads/
              MSG
            when :freebsd
              <<-MSG
  Install /usr/ports/www/qt4-webkit and /usr/ports/devel/qmake4.
MSG
              MSG
            when :mac_os_x
              <<-MSG
  sudo port install qt4-mac (for the patient) or downloading Nokia's pre-built binary
  at http://qt.nokia.com/downloads/
              MSG
            end
          ).strip

          $stderr.puts <<-MSG
  qmake is not installed or is not the right version (#{@name} needs Qt 4.7 or above).
  You'll need to install it to build #{@name}.
          #{install_method} should do it for you.
          MSG
        end
      end
    end
  end
end

