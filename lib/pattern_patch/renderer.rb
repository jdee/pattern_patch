require_relative 'core_ext/hash'
require 'rubygems'

module PatternPatch
  # Provides a fairly clean binding for resolving locals in Ruby < 2.5.
  # All locals become method calls in the binding passed to ERB. A separate
  # class (instead of a Module, e.g.) means minimal clutter in the set of
  # methods available to the binding.
  class Renderer
    class << self
      def is_ruby3?
        version = Gem::Version.new RUBY_VERSION
        requirement = Gem::Requirement.new '>= 3'
        requirement =~ version
      end
    end

    def initialize(text, safe_level = nil, trim_mode = nil)
      if self.class.is_ruby3?
        @template = ERB.new text, trim_mode: trim_mode
      else
        @template = ERB.new text, safe_level, trim_mode
      end
      @locals = {}
    end

    # Render an ERB template with a binding or locals.
    #     renderer = Renderer.new template_text
    #     result = renderer.render binding
    #     result = renderer.render a: 'foo', b: 1
    # @param locals_or_binding [Hash, Binding] a Hash of locals or a Binding
    # @return the result of rendering the template
    # @raise ArgumentError for invalid locals
    def render(locals_or_binding = {})
      # Pass a Binding this way.
      return @template.result(locals_or_binding) unless locals_or_binding.kind_of?(Hash)

      @locals = locals_or_binding.symbolize_keys
      # Any local that corresponds to a method name in this class is invalid
      # because it cannot trigger method_missing. The same goes for
      # locals_or_binding, the only local variable.
      # Avoid new methods and local variables, which will be visible in the binding.
      # Could validate only for Ruby < 2.5, but better to be consistent.
      if @locals.any? { |l| respond_to?(l) || l == :locals_or_binding }
        raise ArgumentError, "Invalid locals: #{@locals.select { |l| respond_to?(l) || l == :locals_or_binding }.map(&:to_str).join ', '}"
      end

      if @template.respond_to? :result_with_hash
        # ERB#result_with_hash requires Ruby 2.5.
        @template.result_with_hash locals_or_binding
      else
        @template.result binding
      end
    end

    def method_missing(method_sym, *args, &block)
      return super unless @locals.key?(method_sym)

      @locals[method_sym]
    end
  end
end
