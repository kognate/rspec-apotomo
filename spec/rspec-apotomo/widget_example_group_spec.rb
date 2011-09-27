require 'spec_helper'
require "action_controller/railtie"
require 'rspec/rails/example/widget_example_group'

# This class is used as a dummy widget for testing
class DummyWidget < Apotomo::Widget
  responds_to_event :doo

  def display
    render
  end
end
DummyWidget.append_view_path "spec/fixtures"


Rails.application = Class.new(Rails::Application)
#Rails.application.routes.append do |r|
#  r.match "/render_event_response", :as => :apotomo_event_path
#end

module RSpec::Rails
  describe WidgetExampleGroup do
    context "as RSpec" do
      it "responds to render_widget" do
        group = RSpec::Core::ExampleGroup.describe do
          include WidgetExampleGroup
        end

        # Why is this weird? See https://github.com/rspec/rspec-core/issues/460
        group.new.__should_for_example_group__ respond_to(:render_widget)
      end
    end

    context "as a test writer" do
      # A real user wouldn't use WidgetExampleGroup because
      # the rails rspec would include it automagically.
      include WidgetExampleGroup

      context "light-weight integration tests" do
        has_widgets do |root|
          root << widget(:dummy)
          root[:dummy].instance_eval do
            def apotomo_event_path(*args)
              "i should be mixed in properly from @routes"
            end
          end
        end

        it "should render a view" do
          render_widget(:dummy).should == "Hey from DummyWidget! i should be mixed in properly from @routes\n"
        end
      end

      context "- ::has_widget" do
        has_widgets do |root|
          root << widget(:dummy)
        end

        it "adds the widget to root" do
          root.find_widget(:dummy).should_not be_nil
        end
      end

      context "- #render_widget" do
        has_widgets do |root|
          root << widget(:dummy)
        end

        it "calls render_widget in apotomo's widget" do
          ::Apotomo::Widget.any_instance.should_receive(:render_widget)
          render_widget(:some_widget)
        end

        it "can use response to get the result of render_widget" do
          ::Apotomo::Widget.any_instance.stub(:render_widget).and_return("expected string")
          render_widget(:some_widget)
          response.should == "expected string"
        end
      end

      context "- #trigger" do
        has_widgets do |root|
          root << widget(:dummy)
        end

        it "triggers events and returns the page updates" do
          DummyWidget.any_instance.stub(:doo).and_return("unexpected string")
          trigger(:doo, :dummy).should == ["unexpected string"]
        end
      end

      context "- #assign" do
        has_widgets do |root|
          root << widget(:dummy)
        end

        it "gets the widget controller variables" do

        end
        pending "sets the widget view variables"
      end
    end
  end
end
