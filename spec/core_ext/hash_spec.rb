describe Hash do
  let (:h) { { 'a' => 1, 'b' => 2 } }
  describe '#symbolize_keys' do
    it 'transforms keys to symbols' do
      expect(h.symbolize_keys).to eq(a: 1, b: 2)
    end

    it 'does not modify the receiver' do
      h.symbolize_keys
      expect(h).to eq({ 'a' => 1, 'b' => 2 })
    end
  end

  describe '#symbolize_keys!' do
    it 'modifies the receiver' do
      h.symbolize_keys!
      expect(h).to eq(a: 1, b: 2)
    end

    it 'returns nil' do
      expect(h.symbolize_keys!).to be_nil
    end
  end
end
