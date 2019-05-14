describe PatternPatch::Methods do
  include PatternPatch::Methods

  it 'has an attr_accessor :patch_dir' do
    expect(PatternPatch).to respond_to(:patch_dir)
    expect(PatternPatch).to respond_to(:patch_dir=)
  end

  it 'has an attr_accessor :safe_level' do
    expect(PatternPatch).to respond_to(:safe_level)
    expect(PatternPatch).to respond_to(:safe_level=)
  end

  it 'has an attr_accessor :trim_mode' do
    expect(PatternPatch).to respond_to(:trim_mode)
    expect(PatternPatch).to respond_to(:trim_mode=)
  end

  describe '#patch_config' do
    it 'yields self if a block is given' do
      expected_return_value = :foo

      return_value = patch_config do |config|
        expect(config).to be self
        expected_return_value
      end

      expect(return_value).to eq expected_return_value
    end

    it 'returns self if a block is given' do
      expect(patch_config).to be self
    end
  end

  describe '::patch' do
    it 'raises if patch_dir is nil' do
      expect do
        PatternPatch.patch_dir = nil
        PatternPatch.patch :foo
      end.to raise_error PatternPatch::ConfigurationError
    end

    it 'raises if the patch_dir is not a directory' do
      expect(Dir).to receive(:exist?).with("/some/path") { false }

      expect do
        PatternPatch.patch_dir = "/some/path"
        PatternPatch.patch :foo
      end.to raise_error PatternPatch::ConfigurationError
    end

    it 'loads the specified YAML patch from the patch_dir' do
      expect(Dir).to receive(:exist?).with("/some/path") { true }
      expect(PatternPatch::Patch).to receive(:from_yaml).with("/some/path/foo.yml") { PatternPatch::Patch.new }
      PatternPatch.patch_dir = "/some/path"
      expect(PatternPatch.patch(:foo)).to be_a PatternPatch::Patch
    end
  end

  describe '#safe_level' do
    it 'delegates to the PatternPatch module' do
      PatternPatch.safe_level = 0
      expect(safe_level).to eq 0

      self.safe_level = 1
      expect(PatternPatch.safe_level).to eq 1
    end
  end

  describe '#trim_mode' do
    it 'delegates to the PatternPatch module' do
      PatternPatch.trim_mode = "-"
      expect(trim_mode).to eq "-"

      self.trim_mode = "<>"
      expect(PatternPatch.trim_mode).to eq "<>"
    end
  end
end
