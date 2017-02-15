module ActionView
  class Component < Base
  end

  class TemplateRenderer
    module ComponentTemplates
      def render(context, options)
        if options.key?(:component)
          name    = options[:component]
          klass   = "#{name}_component".classify.constantize
          args    = options.except(:component)
          context = args.empty? ? klass.new : klass.new(args)

          super context, template: "components/#{name}"
        else
          super
        end
      end
    end

    prepend ComponentTemplates
  end
end
