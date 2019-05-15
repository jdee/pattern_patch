require_relative 'core_ext/hash'

module PatternPatch
  class Renderer
    def initialize(text, safe_level = nil, trim_mode = nil)
      @template = ERB.new text, safe_level, trim_mode
      @locals = {}
    end

    # Render an ERB template with a binding or locals.
    #     renderer = Renderer.new template_text
    #     result = renderer.render binding
    #     result = renderer.render a: 'foo', b: 1
    # @param locals_or_binding [Hash, Binding] a Hash of locals or a Binding
    # @return the result of rendering the template
    def render(locals_or_binding = {})
      if !locals_or_binding.kind_of?(Hash)
        # Pass a Binding this way.
        @template.result locals_or_binding
      elsif template.respond_to? :result_with_hash
        # ERB#result_with_hash requires Ruby 2.5.
        @template.result_with_hash locals_or_binding
      else
        @locals = locals_or_binding.symbolize_keys
        @template.result binding
      end
    end

    def method_missing(method_sym, *args, &block)
      return super unless @locals.key?(method_sym)

      @locals[method_sym]
    end
  end
end
