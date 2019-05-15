module PatternPatch
  class Renderer
    attr_reader :template

    def initialize(text, safe_level = nil, trim_mode = nil)
      @template = ERB.new text, safe_level, trim_mode
      @locals = {}
    end

    # Render an ERB template with a binding or locals.
    #     renderer = Renderer.new template_text
    #     result = renderer.render binding
    #     result = renderer.render a: 'foo', b: 1
    # @param locals [Hash, Binding] a Binding or a Hash of locals
    def render(locals = {})
      if !locals.kind_of?(Hash)
        # Pass a binding this way.
        template.result locals
      elsif template.respond_to? :result_with_hash
        # ERB#result_with_hash requires Ruby 2.5.
        template.result_with_hash locals
      else
        @locals = locals
        template.result binding
      end
    end

    def method_missing(method_sym, *args, &block)
      return super unless @locals.has_key?(method_sym)

      @locals[method_sym]
    end
  end
end
