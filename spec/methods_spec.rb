describe PatternPatch::Methods do
  it 'has an attr_accessor :patch_dir' do
    expect(PatternPatch).to respond_to(:patch_dir)
    expect(PatternPatch).to respond_to(:patch_dir=)
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
end
