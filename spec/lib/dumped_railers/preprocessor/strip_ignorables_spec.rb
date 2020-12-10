# frozen_string_literal: true

RSpec.describe DumpedRailers::Preprocessor::StripIgnorables do
  describe '#call' do
    subject { described_class.new.call(attributes, model) }

    let(:attributes) {
      {
        'id'         => 1,
        'title'      => 'a day in the life',
        'uuid'       => '428233be-9391-4bf8-8b04-442168c790b7',
        'tenant_id'  => 10,
        'created_at' => Time.new(2020, 1, 1),
        'updated_at' => Time.new(2020, 4, 15),
      }
    }

    let(:model) { Object }

    context 'with default config' do
      it  {
        is_expected.to match(
          'title'     => 'a day in the life',
          'uuid'      => '428233be-9391-4bf8-8b04-442168c790b7',
          'tenant_id' => 10,
        )
      }
    end

    context 'with different config settings' do
      around do |example|
        original_settings = nil

        DumpedRailers.configure do |config|
          original_settings = config.ignorable_columns
          config.ignorable_columns = ['uuid', 'tenant_id']
        end

        example.run

        DumpedRailers.configure do |config|
          config.ignorable_columns = original_settings
        end
      end

      it  {
        is_expected.to match(
          'id'         => 1,
          'title'      => 'a day in the life',
          'created_at' => Time.new(2020, 1, 1),
          'updated_at' => Time.new(2020, 4, 15),
        )
      }
    end
  end
end
