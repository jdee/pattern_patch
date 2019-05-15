class Hash
  # #transform_keys not available in 2.3
  def symbolize_keys
    each_with_object({}) do |ary, hash|
      key, value = *ary
      hash[key.to_sym] = value
    end
  end

  def symbolize_keys!
    hash = symbolize_keys
    clear
    hash.each { |k, v| self[k] = v }
    nil
  end
end
