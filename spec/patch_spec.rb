describe PatternPatch::Patch do
  describe 'initialization' do
    it 'initializes parameters from options' do
      patch = PatternPatch::Patch.new regexp: //, text: '', mode: :prepend, global: true
      expect(patch.regexp).to eq(//)
      expect(patch.text).to eq ''
      expect(patch.mode).to eq :prepend
      expect(patch.global).to be true
    end

    it 'initializes to default values when no options passed' do
      patch = PatternPatch::Patch.new
      expect(patch.regexp).to be_nil
      expect(patch.text).to be_nil
      expect(patch.mode).to eq :append
      expect(patch.global).to be false
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

  describe '#to_s' do
    it 'is equal to #inspect' do
      patch = PatternPatch::Patch.new
      expect(patch.to_s).to eq patch.inspect
    end
  end

  describe '#from_yaml' do
    describe 'regexp field' do
      it 'recognizes case-insensitive regexps in a text field' do
        expect(YAML).to receive(:load_file) { { regexp: '/x/i' } }
        patch = PatternPatch::Patch.from_yaml("foo.yml")
        expect(patch.regexp).to eq(/x/i)
      end

      it 'recognizes extended regexps in a text field' do
        expect(YAML).to receive(:load_file) { { regexp: '/x/x' } }
        patch = PatternPatch::Patch.from_yaml("foo.yml")
        expect(patch.regexp).to eq(/x/x)
      end

      it 'recognizes multiline regexps in a text field' do
        expect(YAML).to receive(:load_file) { { regexp: '/x/m' } }
        patch = PatternPatch::Patch.from_yaml("foo.yml")
        expect(patch.regexp).to eq(/x/m)
      end
    end

    describe 'text_file field' do
      it 'interprets the path relative to the path of the YAML file' do
        expect(YAML).to receive(:load_file) { { text_file: "file.txt" } }
        expect(File).to receive(:read).with("/path/to/file.txt") { "" }
        patch = PatternPatch::Patch.from_yaml("/path/to/foo.yml")
        expect(patch.text_file).to eq "/path/to/file.txt"
      end
    end
  end

  describe '#text_file=' do
    it 'loads the contents of the file as the #text field' do
      patch = PatternPatch::Patch.new
      expect(File).to receive(:read).with('foo.txt') { 'contents of foo.txt' }
      patch.text_file = 'foo.txt'
      expect(patch.text).to eq 'contents of foo.txt'
    end
  end

  describe '#apply' do
    it 'passes field values to the Utilities#apply_patch method' do
      patch = PatternPatch::Patch.new regexp: /x/, text: 'y'
      expect(File).to receive(:read).with('file.txt') { 'x' }

      expect(PatternPatch::Utilities).to receive(:apply_patch).with(
        'x',
        patch.regexp,
        patch.text,
        patch.global,
        patch.mode,
        0
      ) { 'xy' }

      expect(File).to receive(:write).with('file.txt', 'xy')

      patch.apply 'file.txt'
    end

    it 'passes the offset option if present' do
      patch = PatternPatch::Patch.new regexp: /x/, text: 'y'
      expect(File).to receive(:read).with('file.txt') { 'x' }

      expect(PatternPatch::Utilities).to receive(:apply_patch).with(
        'x',
        patch.regexp,
        patch.text,
        patch.global,
        patch.mode,
        1
      ) { 'x' }

      expect(File).to receive(:write).with('file.txt', 'x')

      patch.apply 'file.txt', offset: 1
    end

    it 'uses ERB with a default binding if :binding option absent' do
      patch = PatternPatch::Patch.new regexp: /x/, text: '<%= PatternPatch::VERSION %>'
      expect(File).to receive(:read).with('file.txt') { 'x' }

      expect(PatternPatch::Utilities).to receive(:apply_patch).with(
        'x',
        patch.regexp,
        PatternPatch::VERSION,
        patch.global,
        patch.mode,
        0
      ) { "x#{PatternPatch::VERSION}" }

      expect(File).to receive(:write).with('file.txt', "x#{PatternPatch::VERSION}")

      patch.apply 'file.txt', binding: binding
    end

    it 'passes a :binding option to ERB if present' do
      replacement_text = "y"
      patch = PatternPatch::Patch.new regexp: /x/, text: '<%= replacement_text %>'
      expect(File).to receive(:read).with('file.txt') { 'x' }

      expect(PatternPatch::Utilities).to receive(:apply_patch).with(
        'x',
        patch.regexp,
        replacement_text,
        patch.global,
        patch.mode,
        0
      ) { 'xy' }

      expect(File).to receive(:write).with('file.txt', 'xy')

      patch.apply 'file.txt', binding: binding
    end
  end

  describe '#revert' do
    it 'passes field values to the Utilities#revert_patch method' do
      patch = PatternPatch::Patch.new regexp: /x/, text: 'y'
      expect(File).to receive(:read).with('file.txt') { 'xy' }

      expect(PatternPatch::Utilities).to receive(:revert_patch).with(
        'xy',
        patch.regexp,
        patch.text,
        patch.global,
        patch.mode, 0
      ) { 'x' }

      expect(File).to receive(:write).with('file.txt', 'x')

      patch.revert 'file.txt'
    end

    it 'passes the offset option if present' do
      patch = PatternPatch::Patch.new regexp: /x/, text: 'y'
      expect(File).to receive(:read).with('file.txt') { 'x' }

      expect(PatternPatch::Utilities).to receive(:revert_patch).with(
        'x',
        patch.regexp,
        patch.text,
        patch.global,
        patch.mode,
        1
      ) { 'x' }

      expect(File).to receive(:write).with('file.txt', 'x')

      patch.revert 'file.txt', offset: 1
    end

    it 'uses ERB with a default binding if :binding option absent' do
      patch = PatternPatch::Patch.new regexp: /x/, text: '<%= PatternPatch::VERSION %>'
      expect(File).to receive(:read).with('file.txt') { "x#{PatternPatch::VERSION}" }

      expect(PatternPatch::Utilities).to receive(:revert_patch).with(
        "x#{PatternPatch::VERSION}",
        patch.regexp,
        PatternPatch::VERSION,
        patch.global,
        patch.mode, 0
      ) { 'x' }

      expect(File).to receive(:write).with('file.txt', 'x')

      patch.revert 'file.txt', binding: binding
    end

    it 'passes a :binding option to ERB if present' do
      replacement_text = "y"
      patch = PatternPatch::Patch.new regexp: /x/, text: '<%= replacement_text %>'
      expect(File).to receive(:read).with('file.txt') { 'xy' }

      expect(PatternPatch::Utilities).to receive(:revert_patch).with(
        'xy',
        patch.regexp,
        replacement_text,
        patch.global,
        patch.mode, 0
      ) { 'x' }

      expect(File).to receive(:write).with('file.txt', 'x')

      patch.revert 'file.txt', binding: binding
    end
  end

  describe '::from_yaml' do
    it 'loads a patch from a YAML file' do
      expect(YAML).to receive(:load_file).with('file.yml') { { regexp: 'x', text: 'y', mode: 'prepend', global: true } }
      patch = PatternPatch::Patch.from_yaml 'file.yml'
      expect(patch.regexp).to eq(/x/)
      expect(patch.text).to eq 'y'
      expect(patch.mode).to eq :prepend
      expect(patch.global).to be true
    end
  end
end
