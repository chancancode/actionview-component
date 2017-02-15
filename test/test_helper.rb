# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]

require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

Rails::TestUnitReporter.executable = 'bin/test'

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

require 'active_support/core_ext/string/strip'

module ActionView
  class TestCase
    setup do
      # Automatically unload any top-level constants added by the tests
      @constants_snapshot = Object.constants

      # Automatically restore the view_paths on the TestController
      @view_paths_snapshot = TestController.view_paths.dup
    end

    teardown do
      (Object.constants - @constants_snapshot).each { |name| Object.send(:remove_const, name) }

      TestController.view_paths = @view_paths_snapshot

      FileUtils.remove_entry @tmpdir if @tmpdir
    end

    def assert_dom_equal(expected, actual = rendered, message = nil, strip: :heredoc)
      super(strip_content(expected, strip), strip_content(rendered, strip), message)
    end

    # register a temporary template, as if it as located in app/views/path
    def register_template(path, content, strip: :heredoc)
      # TODO: make a custom in-memory reoslver instead of going through the FS
      unless @tmpdir
        @tmpdir = Dir.mktmpdir
        TestController.prepend_view_path OptimizedFileSystemResolver.new(@tmpdir)
      end

      full_path = File.join(@tmpdir, path)
      FileUtils.mkdir_p File.dirname(full_path)
      File.write(full_path, strip_content(content, strip))

      nil
    end

    private

      # Need to experiment if this priority is the best one: @rendered > @output_buffer
      def rendered
        @rendered.blank? ? @output_buffer : @rendered
      end

      def document_root_element
        @fragment ||= Nokogiri::HTML.fragment(rendered)
      end

      def strip_content(content, mode = :heredoc)
        if mode == :heredoc
          content.strip_heredoc
        elsif mode
          content.strip
        else
          content
        end
      end
  end
end
