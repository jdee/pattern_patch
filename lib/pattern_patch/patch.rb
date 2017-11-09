require "active_support/core_ext/hash"
require "erb"
require "yaml"

module PatternPatch
  # The PatternPatch::Patch class defines a patch as an operation that
  # may be applied to any file. Often the operation may also be reverted.
  class Patch
    # Regexp defining one or more matching regions in a file.
    attr_accessor :regexp

    # String with text to use in the patch operation. May contain ERB.
    attr_accessor :text

    # Symbol specifying the patch mode: :append (default), :prepend or :replace
    attr_accessor :mode

    # Setting this to true will apply the patch to all matches in the file.
    # By default (when false), the patch is only applied to the first match.
    attr_accessor :global

    # If set to a file path, the contents of that file will be used to populate
    # the text attribute. Setting this after construction modifies the text
    # field.
    attr_reader :text_file

    class << self
      # Load a Patch from a YAML file. The following special processing applies:
      # The mode field is converted to a symbol. The text_file field will be
      # interpreted relative to the YAML file. A Regexp will be constructed from
      # the regexp field using Regexp.new unless it is a String containing a
      # Regexp literal using slash delimiters, e.g. /x/i. This format may be
      # used to specify a Regexp with modifiers in YAML. Raises if the file
      # cannot be loaded.
      #
      # [patch] [String] Path to a YAML file containing a patch definition.
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

    # Construct a new Patch from the options. The following fields are mapped
    # to the corresponding attributes: :regexp, :text, :text_file, :mode,
    # :global. Raises ArgumentError if both :text and :text_file are specified.
    #
    # [options] [Hash] Parameters used to construct the Patch
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

    # Applies the patch to one or more files. ERB is processed in the text
    # field, whether it comes from a text_file or not. Pass a Binding to
    # ERB using the :binding option. Pass the :offset option to specify a
    # starting offset, in characters, from the beginning of the file.
    #
    # [files] [Array or String] One or more file paths to which to apply the patch.
    # [options] [Hash] Options for applying the patch.
    def apply(files, options = {})
      offset = options[:offset] || 0
      files = [files] if files.kind_of? String

      patch_text = ERB.new(text).result options[:binding]

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

    # Reverse the effect of a patch on one or more files. ERB is processed in the text
    # field, whether it comes from a text_file or not. Pass a Binding to
    # ERB using the :binding option. Pass the :offset option to specify a
    # starting offset, in characters, from the beginning of the file.
    #
    # [files] [Array or String] One or more file paths to which to apply the patch.
    # [options] [Hash] Options for applying the patch.
    def revert(files, options = {})
      offset = options[:offset] || 0
      files = [files] if files.kind_of? String

      patch_text = ERB.new(text).result options[:binding]

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
