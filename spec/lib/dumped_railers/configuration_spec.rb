# frozen_string_literal: true

RSpec.describe DumpedRailers::Configuration do
  let(:klass) {
    Class.new do
      extend DumpedRailers::Configuration
      configure_defaults!
    end
  }

  describe '#configure' do
    describe 'ignorable_columns' do
      subject { klass.ignorable_columns }

      context 'default' do
        it { is_expected.to eq(%w(id created_at updated_at)) }
      end

      context 'when configured' do
        subject {
         klass.configure { |config| 
            config.ignorable_columns += ['uuid', 'tenant_id', 'published_on']
          }
        }

        it 'updates configuration' do
          expect { subject }.to change { klass.ignorable_columns }.to (a_collection_containing_exactly *%w(id created_at updated_at uuid tenant_id published_on))
        end
      end
    end

    describe 'preprocessors' do
      subject { klass.preprocessors }

      context 'default' do
        it { is_expected.to be_empty }
      end

      context 'when configured' do
        let(:preprocessor_1) { -> (_model, _attrs) { {foo: :bar} } }
        let(:preprocessor_2) { -> (_model, _attrs) { {bar: :baz} } }

        subject {
          klass.configure { |config|
            config.preprocessors = [preprocessor_1, preprocessor_2]
          }
        }

        it 'updates configuration' do
          expect { subject }.to change { klass.preprocessors }.to([preprocessor_1, preprocessor_2])
        end
      end
    end

    describe 'authorized_models' do
      subject { klass.authorized_models }

      context 'default' do
        it { is_expected.to be_empty }
      end

      context 'when configured' do
        subject {
          klass.configure { |config|
            config.authorized_models = [:model1, :model2]
          }
        }

        it 'updates configuration' do
          expect { subject }.to change { klass.authorized_models }.to([:model1, :model2])
        end
      end
    end

    describe 'any other options' do
      subject { klass.instance_variable_get(:@_config).a_random_option }

      context 'with default value' do
        it { is_expected.to be_nil }
      end

      context 'when configured' do
        before do
          klass.configure { |config|
            config.a_random_option = :new_value
          }
        end

        it 'updates configuration' do
          expect(subject).to eq :new_value
        end
      end
    end
  end

  describe '#options' do
    subject { klass.options }

    before do
      klass.configure do |config|
        config.ignorable_columns = [:uuid]
        config.preprocessors     = [:foo, :bar]
        config.authorized_models = [:model1, :model2]
        config.a_random_option   = 'something'
      end
    end

    it {
      is_expected.to match(
        ignorable_columns: [:uuid],
        preprocessors:     [:foo, :bar],
        authorized_models: [:model1, :model2],
        a_random_option:   'something',
      )
    }

    context 'when options are mutated' do
      subject {
        klass.options[:ignorable_columns] << :published_at
        klass.options[:a_random_option].upcase!
      }

      it 'does not change original options' do
        expect  { subject }.not_to change { klass.options }
      end
    end
  end

  describe '#configure_defaults!' do
    subject { klass.configure_defaults! }

    before do
      klass.configure do |config|
        config.ignorable_columns = [:uuid]
        config.preprocessors     = [:foo, :bar]
        config.authorized_models = [:model1, :model2]
        config.a_random_option   = :something
      end
    end

    it 'resets ignorable_columns' do
      expect { subject }.to change { klass.ignorable_columns }.to %w[id created_at updated_at]
    end

    it 'resets preprocessors' do
      expect { subject }.to change { klass.preprocessors }.to []
    end

    it 'resets authorized_models' do
      expect { subject }.to change { klass.authorized_models }.to []
    end

    it 'resets other options' do
      expect { subject }.to change { klass.instance_variable_get(:@_config).a_random_option }.to nil
    end
  end
end
