class String
  # Replace capture group references in self with appropriate
  # data from matches. Modifies the receiver. The receiver
  # need not match the matches.regexp.
  #
  # @param matches [MatchData] A MatchData object returned by Regexp#match
  # @return nil
  def apply_matches!(matches)
    search_position = 0
    while (m = /\\(\d+)/.match(self, search_position))
      capture_group = m[1].to_i
      search_position = index m[0]
      gsub! m[0], matches[capture_group]
      search_position += matches[capture_group].length
    end
    nil
  end

  # Return a copy of the receiver with capture group references
  # in self replaced by appropriate data from matches. The receiver
  # need not match the matches.regexp.
  #
  # @param matches [MatchData] A MatchData object returned by Regexp#match
  # @return [String] A modified copy of the receiver
  def apply_matches(matches)
    string = clone
    string.apply_matches! matches
    string
  end
end
