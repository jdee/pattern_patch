describe String do
  describe '#apply_matches!' do
    it 'applies match data to an unrelated string' do
      text = '\1 abc'
      matches = /(\d+)/.match "123"
      text.apply_matches! matches
      expect(text).to eq "123 abc"
    end

    it 'handles repeated instances of the same capture group' do
      text = '\1 \1 abc'
      matches = /(\d+)/.match "123"
      text.apply_matches! matches
      expect(text).to eq "123 123 abc"
    end

    it 'replaces multiple capture groups' do
      text = '\1 \2 abc'
      matches = /(\d+)(.*)/.match "123xyz"
      text.apply_matches! matches
      expect(text).to eq "123 xyz abc"
    end
  end

  describe '#apply_matches' do
    it 'returns clone.apply_matches!' do
      text = '\1 \2 abc'
      matches = /(\d+)(.*)/.match "123xyz"
      new_text = text.apply_matches matches
      expect(new_text).to eq "123 xyz abc"
      expect(text).to eq '\1 \2 abc'
    end
  end
end
