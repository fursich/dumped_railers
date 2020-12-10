# frozen_string_literal: true

RSpec.describe DumpedRailers::RecordBuilder::FixtureRow::RecordStore do

  describe '.register' do
    subject { described_class.register(:label, object: :an_object) }

    it 'can be registered' do
      expect  { subject } .not_to raise_error
    end

    it 'can be registered multiple times' do
      subject
      expect  { subject } .not_to raise_error
    end
  end

  describe '.registered?' do
    subject { described_class.registered?(:label_X) }

    context 'when nothing is registered' do
      it { is_expected.to eq false }
    end

    context 'when a label is registered' do
      context 'under the same label' do
        before do
          described_class.register(:label_X, object: :object_X)
        end

        it { is_expected.to eq true }
      end

      context 'under a different label' do
        before do
          described_class.register(:label_A, object: :object_X)
        end

        it { is_expected.to eq false }
      end
    end
  end

  describe '.retrieve!' do
    subject { described_class.retrieve!(:label_X) }

    context 'when nothing is registered' do
      it 'raises RuntimeError' do
        expect { subject }.to raise_error RuntimeError
      end
    end

    context 'when a label is registered' do
      context 'under the same label' do
        context  'with a signle registration' do
          before do
            described_class.register(:label_X, object: :object_X)
          end

          it { is_expected.to eq :object_X }
        end

        context  'when multiple registrations were made' do
          before do
            described_class.register(:label_X, object: :object_X)
            described_class.register(:label_X, object: :object_ZZZ)
          end

          it { is_expected.to eq :object_ZZZ }
        end
      end

      context 'under a different label' do
        before do
          described_class.register(:label_A, object: :object_X)
        end

        it 'raises RuntimeError' do
          expect { subject }.to raise_error RuntimeError
        end
      end
    end
  end

  describe '.clear!' do
    subject { described_class.clear! }

    before do
      described_class.register(:label_X, object: :object_X)
    end

    it 'clears up all the registration' do
      expect { subject }.to change { described_class.registered?(:label_X) }.from(true).to(false)
    end
  end
end
