describe PatternPatch::Utilities do
  let (:util) { PatternPatch::Utilities }

  describe 'apply_patch' do
    describe 'modes' do
      it 'inserts text after a pattern in :append mode' do
        original = 'alpha beta gamma'
        modified = util.apply_patch original, /beta/, ' beta and a half', false, :append, 0
        expect(modified).to eq 'alpha beta beta and a half gamma'
      end

      it 'inserts text before a pattern in :prepend mode' do
        original = 'alpha beta gamma'
        modified = util.apply_patch original, /beta/, 'alpha and a half ', false, :prepend, 0
        expect(modified).to eq 'alpha alpha and a half beta gamma'
      end

      it 'replaces a pattern with text in :replace mode' do
        original = 'alpha beta gamma'
        modified = util.apply_patch original, /beta/, 'two', false, :replace, 0
        expect(modified).to eq 'alpha two gamma'
      end

      it 'recognizes capture groups in :replace mode' do
        original = 'alpha beta gamma'
        modified = util.apply_patch original, /(beta)/, '\1 two', false, :replace, 0
        expect(modified).to eq 'alpha beta two gamma'
      end

      it 'recognizes capture groups in :append mode' do
        original = 'alpha beta gamma'
        modified = util.apply_patch original, /(beta)/, ' \1 and a half', false, :append, 0
        expect(modified).to eq 'alpha beta beta and a half gamma'
      end

      it 'recognizes capture groups in :prepend mode' do
        original = 'alpha beta gamma'
        modified = util.apply_patch original, /(beta)/, '\1 and a half ', false, :prepend, 0
        expect(modified).to eq 'alpha beta and a half beta gamma'
      end

      it 'raises for any other mode' do
        original = 'alpha beta gamma'
        expect do
          util.apply_patch original, /beta/, ' beta and a half', false, :add_somewhere_i_dont_know_where, 0
        end.to raise_error ArgumentError
      end
    end

    describe 'line endings' do
      it 'handles things at the end of a line' do
        original = "alpha\nbeta\ngamma\n"
        modified = util.apply_patch original, /beta$/, "\nbeta and a half", false, :append, 0
        expect(modified).to eq "alpha\nbeta\nbeta and a half\ngamma\n"
      end

      it 'handles things at the beginning of a line' do
        original = "alpha\nbeta\ngamma\n"
        modified = util.apply_patch original, /^beta/, "alpha and a half\n", false, :prepend, 0
        expect(modified).to eq "alpha\nalpha and a half\nbeta\ngamma\n"
      end
    end

    describe 'global flag' do
      it 'appends globally' do
        original = 'alpha alpha alpha'
        modified = util.apply_patch original, /alpha/, ' alpha and a half', true, :append, 0
        expect(modified).to eq 'alpha alpha and a half alpha alpha and a half alpha alpha and a half'
      end

      it 'prepends globally' do
        original = 'alpha alpha alpha'
        modified = util.apply_patch original, /alpha/, 'alpha and a half ', true, :prepend, 0
        expect(modified).to eq 'alpha and a half alpha alpha and a half alpha alpha and a half alpha'
      end
    end
  end

  describe 'revert_patch' do
    describe 'modes' do
      it 'removes a patch applied in :append mode' do
        original = 'alpha beta beta and a half gamma'
        modified = util.revert_patch original, /beta/, ' beta and a half', false, :append, 0
        expect(modified).to eq 'alpha beta gamma'
      end

      it 'reverts a patch applied in :prepend mode' do
        original = 'alpha alpha and a half beta gamma'
        modified = util.revert_patch original, /beta/, 'alpha and a half ', false, :prepend, 0
        expect(modified).to eq 'alpha beta gamma'
      end

      it 'recognizes capture groups in :append mode' do
        original = 'alpha beta beta and a half gamma'
        modified = util.revert_patch original, /(beta)/, ' \1 and a half', false, :append, 0
        expect(modified).to eq 'alpha beta gamma'
      end

      it 'recognizes capture groups in :prepend mode' do
        pending 'not working with prepend atm'
        original = 'alpha beta and a half beta gamma'
        modified = util.revert_patch original, /(beta)/, '\1 and a half ', false, :prepend, 0
        expect(modified).to eq 'alpha beta gamma'
      end

      it 'raises if :replace mode specified' do
        original = 'alpha two gamma'
        expect do
          util.revert_patch original, /beta/, 'two', false, :replace, 0
        end.to raise_error ArgumentError
      end
    end

    describe 'line endings' do
      it 'handles things at the end of a line' do
        original = "alpha\nbeta\nbeta and a half\ngamma\n"
        modified = util.revert_patch original, /beta$/, "\nbeta and a half", false, :append, 0
        expect(modified).to eq "alpha\nbeta\ngamma\n"
      end

      it 'handles things at the beginning of a line' do
        original = "alpha\nalpha and a half\nbeta\ngamma\n"
        modified = util.revert_patch original, /^beta/, "alpha and a half\n", false, :prepend, 0
        expect(modified).to eq "alpha\nbeta\ngamma\n"
      end
    end

    describe 'global flag' do
      it 'reverts :append patches globally' do
        original = 'alpha alpha and a half alpha alpha and a half alpha alpha and a half'
        modified = util.revert_patch original, /alpha/, ' alpha and a half', true, :append, 0
        expect(modified).to eq 'alpha alpha alpha'
      end

      it 'reverts :prepend patches globally' do
        original = 'alpha and a half alpha alpha and a half alpha alpha and a half alpha'
        modified = util.revert_patch original, /alpha/, 'alpha and a half ', true, :prepend, 0
        expect(modified).to eq 'alpha alpha alpha'
      end
    end
  end
end
