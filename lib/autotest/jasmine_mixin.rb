module JasmineMixin
  JASMINE_PROGRAM = File.expand_path('../../../bin/jasmine-headless-webkit', __FILE__)

  JAVASCRIPT_EXTENSIONS = %w{js coffee}

  def self.included(klass)
    klass::ALL_HOOKS << [ :run_jasmine, :ran_jasmine ]
  end

  attr_accessor :is_jasmine_running, :jasmine_to_run, :jasmine_ran_once

  def initialize
    super()
    setup_jasmine_project_mappings
    jasmine_ran_once = false
  end

  def get_to_green
    begin
      reset_jasmine(:no)
      super if find_files_to_test

      reset_jasmine(:yes)
      self.last_mtime = Time.at(0) if !options[:no_full_after_start] && !jasmine_ran_once
      run_jasmine if find_files_to_test

      self.is_jasmine_running = :all
      wait_for_changes unless all_jasmine_good
    end until all_jasmine_good

    reset_jasmine(:all)
  end

  def rerun_all_tests
    reset_jasmine(:no)
    super

    reset_jasmine(:yes)
    run_jasmine

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

    jasmine_ran_once = true
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
    self.files_to_test.empty? ? '' :
      %{#{JASMINE_PROGRAM} #{self.files_to_test.keys.collect { |key| %{'#{key}'} }.join(' ')}}.tap { |o| p o }
  end

  def setup_jasmine_project_mappings
    add_mapping(%r{spec/javascripts/.*_spec\.(js|coffee)}) { |filename, _|
      filename
    }

    add_mapping(%r{public/javascripts/(.*)\.js}) { |_, m|
      files_matching(%r{spec/javascripts/#{m[1]}_spec\..*$})
    }

    add_mapping(%r{app/coffeescripts/(.*)\.coffee}) { |_, m|
      files_matching(%r{spec/javascripts/#{m[1]}_spec\..*$})
    }
  end

  def add_javascript_extensions(*extensions)
    self.class::JAVASCRIPT_EXTENSIONS << extensions
  end
end
