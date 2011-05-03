module JasmineMixin
  JASMINE_PROGRAM = File.expand_path('../../../bin/jasmine-headless-webkit', __FILE__)

  JAVASCRIPT_EXTENSIONS = %w{js}

  def self.included(klass)
    klass::ALL_HOOKS << [ :run_jasmine, :ran_jasmine ]
  end

  attr_accessor :is_jasmine_running, :jasmine_to_run

  def initialize
    super()
    setup_jasmine_project_mappings
  end

  def get_to_green
    begin
      reset_jasmine(:no)
      super if find_files_to_test

      reset_jasmine(:yes)
      run_jasmine if find_files_to_test

      self.is_jasmine_running = :all
      wait_for_changes unless all_jasmine_good
    end until all_jasmine_good

    reset_jasmine(:all)
  end

  def reset_jasmine(method)
    self.files_to_test = new_hash_of_arrays
    self.is_jasmine_running = method
  end

  def run_jasmine
    hook :run_jasmine

    self.jasmine_to_run = :all

    if mtime = find_files_to_test
      self.last_mtime = mtime
    end

    begin
      system make_jasmine_cmd

      self.jasmine_to_run = ($?.exitstatus == 0) ? :none : :all
    end

    hook :ran_jasmine
  end

  def all_jasmine_good
    self.jasmine_to_run == :none
    self.files_to_test = new_hash_of_arrays
  end

  def find_files
    Hash[super.find_all { |file, mtime|
      is_js = (file[%r{\.(#{JAVASCRIPT_EXTENSIONS.join('|')})$}] != nil)

      case self.is_jasmine_running
      when :all
        true
      when :no
        !is_js
      when :yes
        is_js
      end
    }]
  end

  def make_jasmine_cmd
    "#{JASMINE_PROGRAM}"
  end

  def setup_jasmine_project_mappings
    add_mapping(%r{spec/javascripts/.*_spec\.js}) { |filename, _|
      filename
    }

    add_mapping(%r{public/javascripts/(.*)\.js}) { |_, m|
      [ "spec/javascripts/#{m[1]}_spec.js" ]
    }
  end

  def add_javascript_extensions(*extensions)
    self.class::JAVASCRIPT_EXTENSIONS << extensions
  end
end
