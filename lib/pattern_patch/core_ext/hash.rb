class Hash
  def symbolize_keys
    inject({}) do |hash, ary|
      key, value = *ary
      hash[key.to_sym] = value
      hash
    end
  end
end
