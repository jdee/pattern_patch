require "yaml"

module PatternPatch
  class Patch
    attr_accessor :regexp
    attr_accessor :text
    attr_accessor :mode
    attr_accessor :global

    class << self
      def from_yaml(path)
        hash = YAML.load_file path

        # Adjust string fields from YAML

        if hash[:regexp].kind_of? String
          hash[:regexp] = /#{hash[:regexp]}/
        end

        if hash[:mode].kind_of? String
          hash[:mode] = hash[:mode].to_sym
        end

        new hash
      end
    end

    def initialize(options = {})
      @regexp = options[:regexp]
      @text = options[:text]
      @mode = options[:mode] || :append
      @global = options[:global].nil? ? false : options[:global]
    end

    def apply(files, options = {})
      offset = options[:offset] || 0

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
