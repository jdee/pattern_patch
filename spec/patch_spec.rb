describe PatternPatch::Patch do
  describe 'initialization' do
    it 'initializes parameters from options' do
      patch = PatternPatch::Patch.new regexp: //, text: '', mode: :append, global: false
      expect(patch.regexp).to eq(//)
      expect(patch.text).to eq ''
      expect(patch.mode).to eq :append
      expect(patch.global).to be false
    end

    it 'initializes to default values when no options passed' do
      patch = PatternPatch::Patch.new
      expect(patch.regexp).to be_nil
      expect(patch.text).to be_nil
      expect(patch.mode).to eq :append
      expect(patch.global).to be_nil
    end
  end

  describe '#inspect' do
    it 'includes the value of each field' do
      text = PatternPatch::Patch.new.inspect
      expect(text).to match(/regexp=/)
      expect(text).to match(/text=/)
      expect(text).to match(/mode=/)
      expect(text).to match(/global=/)
    end
  end

  describe '#apply' do
    it 'passes field values to the Utilities#apply_patch method' do
    end
  end
end
