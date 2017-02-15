require 'test_helper'

class ComponentsTest < ActionView::TestCase
  test "rendering a basic component" do
    class ::HelloWorldComponent < ActionView::Component
    end

    register_template "components/hello_world.html.erb", <<-ERB
      <div>hello world</div>
    ERB

    render component: "hello_world"

    assert_dom_equal <<-HTML
      <div>hello world</div>
    HTML
  end

  test "rendering a basic component from another template" do
    class ::InsideComponent < ActionView::Component
    end

    register_template "components/inside.html.erb", <<-ERB
      <div>Inside!</div>
    ERB

    register_template "outside.html.erb", <<-ERB
      <div>
        Outside!
        <%= render component: :inside -%>
      </div>
    ERB

    render template: "outside"

    assert_dom_equal <<-HTML
      <div>
        Outside!
        <div>Inside!</div>
      </div>
    HTML
  end

  test "rendering a component with keyword arguments" do
    class ::GreetingsComponent < ActionView::Component
      def initialize(first_name:, middle_name: nil, last_name:, website: nil, social_media_handle: nil)
        @first_name = first_name
        @middle_name = middle_name
        @last_name = last_name
        @website = website
        @social_media_handle = social_media_handle
      end

      def full_name
        if @middle_name
          "#{@first_name} #{@middle_name} #{@last_name}"
        else
          "#{@first_name} #{@last_name}"
        end
      end

      def url
        if @website
          @website
        elsif @social_media_handle
          "https://echochamber.com/#{@social_media_handle}"
        end
      end
    end

    register_template "components/greetings.html.erb", <<-ERB
      <div>
        <% if url %>
          Hello, <a href="<%= url %>"><%= full_name %></a>!
        <% else %>
          Hello, <%= full_name %>!
        <% end %>
      </div>
    ERB

    render component: "greetings", first_name: "David", middle_name: "Heinemeier", last_name: "Hansson"
    render component: "greetings", first_name: "Godfrey", last_name: "Chan", social_media_handle: "@chancancode"
    render component: "greetings", first_name: "Aaron", last_name: "Patterson", website: "https://tenderlovemaking.com", social_media_handle: "@tenderlove"

    assert_dom_equal <<-HTML
      <div>
          Hello, David Heinemeier Hansson!
      </div>
      <div>
          Hello, <a href="https://echochamber.com/@chancancode">Godfrey Chan</a>!
      </div>
      <div>
          Hello, <a href="https://tenderlovemaking.com">Aaron Patterson</a>!
      </div>
    HTML
  end

  test "rendering a component with keyword arguments from another template" do
    class ::GreetingsComponent < ActionView::Component
      def initialize(first_name:, middle_name: nil, last_name:, website: nil, social_media_handle: nil)
        @first_name = first_name
        @middle_name = middle_name
        @last_name = last_name
        @website = website
        @social_media_handle = social_media_handle
      end

      def full_name
        if @middle_name
          "#{@first_name} #{@middle_name} #{@last_name}"
        else
          "#{@first_name} #{@last_name}"
        end
      end

      def url
        if @website
          @website
        elsif @social_media_handle
          "https://echochamber.com/#{@social_media_handle}"
        end
      end
    end

    register_template "components/greetings.html.erb", <<-ERB
      <div>
        <% if url %>
          Hello, <a href="<%= url %>"><%= full_name %></a>!
        <% else %>
          Hello, <%= full_name %>!
        <% end %>
      </div>
    ERB

    register_template "outside.html.erb", <<-ERB
      <h1>Outside</h1>

      <%= render component: :greetings, first_name: "David", middle_name: "Heinemeier", last_name: "Hansson" -%>
      <%= render component: :greetings, first_name: "Godfrey", last_name: "Chan", social_media_handle: "@chancancode" -%>
      <%= render component: :greetings, first_name: "Aaron", last_name: "Patterson", website: "https://tenderlovemaking.com", social_media_handle: "@tenderlove" -%>
    ERB

    render template: :outside

    assert_dom_equal <<-HTML
      <h1>Outside</h1>

      <div>
          Hello, David Heinemeier Hansson!
      </div>
      <div>
          Hello, <a href="https://echochamber.com/@chancancode">Godfrey Chan</a>!
      </div>
      <div>
          Hello, <a href="https://tenderlovemaking.com">Aaron Patterson</a>!
      </div>
    HTML
  end
end
