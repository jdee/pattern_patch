module PatternPatch
  class Renderer
    attr_reader :template

    def initialize(template)
      @template = template
      @locals = {}
    end

    def render(locals = {})
      if !locals.kind_of?(Hash)
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
      local_value = @locals[method_sym]
      # This approach makes it hard to pass nil for a local
      return super if local_value.nil?

      local_value
    end
  end
end
