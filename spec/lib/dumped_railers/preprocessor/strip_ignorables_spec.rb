# frozen_string_literal: true

RSpec.describe DumpedRailers::Preprocessor::StripIgnorables do
  describe '#call' do
    subject { described_class.new.call(model, attributes) }

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
          'id'         => 1,
          'title'      => 'a day in the life',
          'uuid'       => '428233be-9391-4bf8-8b04-442168c790b7',
          'tenant_id'  => 10,
          'created_at' => Time.new(2020, 1, 1),
          'updated_at' => Time.new(2020, 4, 15),
        )
      }
    end

    context 'with different config settings' do
      subject { described_class.new(*ignorable_columns).call(model, attributes) }

      context 'when ignorable columns are specified' do
        let(:ignorable_columns) { ['uuid', 'tenant_id'] }

        it  {
          is_expected.to match(
            'id'         => 1,
            'title'      => 'a day in the life',
            'created_at' => Time.new(2020, 1, 1),
            'updated_at' => Time.new(2020, 4, 15),
          )
        }
      end

      context 'when ignorable columns contains irrelevant column name' do
        let(:ignorable_columns) { ['uuid', 'published_at', 'archived_at'] }

        it  {
          is_expected.to match(
            'id'         => 1,
            'title'      => 'a day in the life',
            'tenant_id'  => 10,
            'created_at' => Time.new(2020, 1, 1),
            'updated_at' => Time.new(2020, 4, 15),
          )
        }
      end

      context 'when ignorable_columns is nil' do
        let(:ignorable_columns) { nil }

        it  {
          is_expected.to match(
            'id'         => 1,
            'title'      => 'a day in the life',
            'uuid'       => '428233be-9391-4bf8-8b04-442168c790b7',
            'tenant_id'  => 10,
            'created_at' => Time.new(2020, 1, 1),
            'updated_at' => Time.new(2020, 4, 15),
          )
        }
      end
    end
  end
end
