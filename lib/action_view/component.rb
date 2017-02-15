module ActionView
  class Component < Base
    def initialize(**args)
      args.each { |key, value| instance_variable_set(:"@#{key}", value) }
    end
  end

  class TemplateRenderer
    module ComponentTemplates
      def render(context, options)
        if options.key?(:component)
          name    = options[:component]
          klass   = "#{name}_component".classify.safe_constantize || Component
          args    = options.except(:component)
          context = klass.new(args)

          super context, template: "components/#{name}"
        else
          super
        end
      end
    end

    prepend ComponentTemplates
  end
end
