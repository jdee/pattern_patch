module PatternPatch
  class Utilities
    class << self
      # Add the specified text after the specified pattern.
      # Returns a modified copy of the string.
      #
      # [contents] [String] A string to modify, e.g. the contents of a file
      # [regexp] [Regexp] A regular expression specifying a pattern to be matched
      # [text] [String] Text to be appended to the specified pattern
      # [global] Boolean flag. If true, patch all occurrences of the regex.
      # [mode] [Symbol] :append, :prepend or :replace to specify how to apply the patch
      # [offset] [Integer] Starting position for matching
      def apply_patch(contents, regexp, text, global, mode, offset)
        search_position = offset
        while (matches = regexp.match(contents, search_position))
          patched_pattern =
            case mode
            when :append
              "#{matches[0]}#{text.apply_matches matches}"
            when :prepend
              "#{text.apply_matches matches}#{matches[0]}"
            when :replace
              matches[0].sub regexp, text
            else
              raise ArgumentError, "Invalid mode argument. Specify :append, :prepend or :replace."
            end

          contents = "#{matches.pre_match}#{patched_pattern}#{matches.post_match}"
          break unless global
          search_position = matches.pre_match.length + patched_pattern.length
        end
        contents
      end

      # Reverts a patch. Use the same arguments that were supplied to apply_patch.
      # The mode argument can only be :append or :prepend. Patches using :replace
      # cannot be reverted.
      # Returns a modified copy of the string.
      #
      # [contents] [String] A string to modify, e.g. the contents of a file
      # [regexp] [Regexp] A regular expression specifying a pattern to be matched
      # [text] [String] Text to be appended to the specified pattern
      # [global] Boolean flag. If true, patch all occurrences of the regex.
      # [mode] [Symbol] :append or :prepend. :replace patches cannot be reverted automatically.
      # [offset] [Integer] Starting position for matching
      def revert_patch(contents, regexp, text, global, mode, offset)
        search_position = offset
        regexp_string = regexp.to_s

        patched_regexp =
          case mode
          when :append
            /#{regexp_string}#{text}/m
          when :prepend
            # TODO: Capture groups aren't currently revertible in :prepend mode.
            # This patched regexp can turn into something like /\1.*(\d+)/.
            # The capture group reference cannot occur in the regexp before definition
            # of the group. This would have to be transformed to something like
            # /(\d+).*\1/. Patch reversion is probably not a major use case right
            # now, so ignore for the moment.
            /#{text}#{regexp_string}/m
          else
            raise ArgumentError, "Invalid mode argument. Specify :append or :prepend."
          end

        while (matches = patched_regexp.match(contents, search_position))
          reverted_text = matches[0].sub(text.apply_matches(matches), '')
          contents = "#{matches.pre_match}#{reverted_text}#{matches.post_match}"
          break unless global
          search_position = matches.pre_match.length + reverted_text.length
        end

        contents
      end
    end
  end
end
