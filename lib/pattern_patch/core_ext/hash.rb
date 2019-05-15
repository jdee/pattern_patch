class Hash
  def symbolize_keys
    each_with_object({}) do |ary, hash|
      key, value = *ary
      hash[key.to_sym] = value
    end
  end
end
