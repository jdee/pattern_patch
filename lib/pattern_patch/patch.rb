require "active_support/core_ext/hash"
require "yaml"

module PatternPatch
  class Patch
    attr_accessor :regexp
    attr_accessor :text
    attr_accessor :text_file
    attr_accessor :mode
    attr_accessor :global

    class << self
      def from_yaml(path)
        hash = YAML.load_file(path).symbolize_keys

        # Adjust string fields from YAML

        if hash[:regexp].kind_of? String
          hash[:regexp] = /#{hash[:regexp]}/
        end

        if hash[:mode].kind_of? String
          hash[:mode] = hash[:mode].to_sym
        end

        if hash[:text_file]
          hash[:text_file] = File.expand_path hash[:text_file], File.dirname(path)
        end

        new hash
      end
    end

    def initialize(options = {})
      raise ArgumentError, "text and text_file are mutually exclusive" if options[:text] && options[:text_file]

      @regexp = options[:regexp]
      @text_file = options[:text_file]

      if @text_file
        @text = File.read @text_file
      else
        @text = options[:text]
      end

      @mode = options[:mode] || :append
      @global = options[:global].nil? ? false : options[:global]
    end

    def text_file=(path)
      @text_file = path
      @text = File.read path if path
    end

    def apply(files, options = {})
      offset = options[:offset] || 0
      files = [files] if files.kind_of? String

      files.each do |path|
        modified = Utilities.apply_patch File.read(path),
                                         regexp,
                                         text,
                                         global,
                                         mode,
                                         offset
        File.write path, modified
      end
    end

    def revert(files, options = {})
      offset = options[:offset] || 0
      files = [files] if files.kind_of? String

      files.each do |path|
        modified = Utilities.revert_patch File.read(path),
                                          regexp,
                                          text,
                                          global,
                                          mode,
                                          offset
        File.write path, modified
      end
    end

    def inspect
      "#<PatternPatch::Patch regexp=#{regexp.inspect} text=#{text.inspect} mode=#{mode.inspect} global=#{global.inspect}>"
    end
  end
end
