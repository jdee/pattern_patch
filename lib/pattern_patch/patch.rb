require "active_support/core_ext/hash"
require "erb"
require "yaml"

module PatternPatch
  class Patch
    attr_accessor :regexp
    attr_accessor :text
    attr_accessor :mode
    attr_accessor :global
    attr_reader :text_file

    class << self
      def from_yaml(path)
        hash = YAML.load_file(path).symbolize_keys

        # Adjust string fields from YAML

        if hash[:regexp].kind_of? String
          regexp_string = hash[:regexp]
          if (matches = %r{^/(.+)/([imx]*)$}.match regexp_string)
            flags = 0
            if matches[2] =~ /i/
              flags |= Regexp::IGNORECASE
            end
            if matches[2] =~ /x/
              flags |= Regexp::EXTENDED
            end
            if matches[2] =~ /m/
              flags |= Regexp::MULTILINE
            end
            hash[:regexp] = Regexp.new matches[1], flags
          else
            hash[:regexp] = /#{regexp_string}/
          end
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

      if options[:binding]
        patch_text = ERB.new(text).result(options[:binding])
      else
        patch_text = text
      end

      files.each do |path|
        modified = Utilities.apply_patch File.read(path),
                                         regexp,
                                         patch_text,
                                         global,
                                         mode,
                                         offset
        File.write path, modified
      end
    end

    def revert(files, options = {})
      offset = options[:offset] || 0
      files = [files] if files.kind_of? String

      if options[:binding]
        patch_text = ERB.new(text).result(options[:binding])
      else
        patch_text = text
      end

      files.each do |path|
        modified = Utilities.revert_patch File.read(path),
                                          regexp,
                                          patch_text,
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
