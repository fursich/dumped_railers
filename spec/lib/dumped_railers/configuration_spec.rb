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
        it { is_expected.to eq :any }
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
        config.yaml_column_permitted_classes = [Date]
        config.a_random_option   = 'something'
      end
    end

    it {
      is_expected.to match(
        ignorable_columns: [:uuid],
        preprocessors:     [:foo, :bar],
        authorized_models: [:model1, :model2],
        yaml_column_permitted_classes: [Date],
        a_random_option:   'something',
      )
    }

    context 'when option values are distructively mutated' do
      subject {
        klass.options[:ignorable_columns] << :published_at
        klass.options[:preprocessors] << :baz
        klass.options[:yaml_column_permitted_classes] << Time
      }

      it 'does updates original configurations' do
        expect  { subject }.to change { klass.options }.to(
          {
            ignorable_columns: [:uuid, :published_at],
            preprocessors:     [:foo, :bar, :baz],
            authorized_models: [:model1, :model2],
            yaml_column_permitted_classes: [Date, Time],
            a_random_option:   'something',
          }
        )
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
        config.yaml_column_permitted_classes = [Date, Time]
        config.a_random_option   = :something
      end
    end

    it 'has preset options' do
      expect { subject }.to change { klass.options.keys }.to contain_exactly(
        *%i[ignorable_columns preprocessors authorized_models yaml_column_permitted_classes]
      )
    end

    it 'resets ignorable_columns' do
      expect { subject }.to change { klass.ignorable_columns }.to %w[id created_at updated_at]
    end

    it 'resets preprocessors' do
      expect { subject }.to change { klass.preprocessors }.to []
    end

    it 'resets authorized_models' do
      expect { subject }.to change { klass.authorized_models }.to :any
    end

    if ActiveRecord.respond_to?(:yaml_column_permitted_classes)
      it 'resets yaml_column_permitted_classes' do
        expect { subject }.to change { klass.yaml_column_permitted_classes }.to match_array(ActiveRecord.yaml_column_permitted_classes + [Date, Time, DateTime])
      end
    else
      it 'resets yaml_column_permitted_classes' do
        expect { subject }.to change { klass.yaml_column_permitted_classes }.to match_array([Date, Time, DateTime])
      end
    end

    it 'resets other options' do
      expect { subject }.to change { klass.instance_variable_get(:@_config).a_random_option }.to nil
    end
  end
end
