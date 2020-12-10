# frozen_string_literal: true

RSpec.describe DumpedRailers::RecordBuilder::DependencyTracker do
  describe 'class method' do
    describe '.for' do
      subject { described_class.for(model) }

      context 'with a single model' do
        let(:model) { :model }
        it 'returns a DependencyTracker object' do
          expect(subject).to be_an_instance_of described_class
        end

        it 'always returns the same object' do
          first_result = subject
          expect(subject).to eq first_result
        end
      end

      context 'with multiple models' do
        let(:model) { :model }
        let(:another_tracker) { described_class.for(:another_model) }

        it 'returns another tracker' do
          expect(subject).not_to eq another_tracker
        end
      end
    end
  end

  describe '#on' do
    let(:tracker) { described_class.new }

    context 'with the object' do
      subject { tracker.on(:object) }

      it 'returns a RecordDependency object' do
        expect(subject).to be_an_instance_of described_class::RecordDependency
      end

      it 'always returns the same object' do
        first_result = subject
        expect(subject).to eq first_result
      end
    end

    context 'with multiple objects' do
      let!(:another_record_dependency) { tracker.on(:another_object) }
      subject { tracker.on(:object) }

      it 'returns another object' do
        expect(subject).not_to eq another_record_dependency
      end
    end

    describe '#list_all_record_labels_with' do
      let(:tracker) { described_class.new }
      subject { tracker.list_all_record_labels_with(:attr_A) }

      context 'with registered dependencies' do

        before do
          tracker.on(:object_1).with(:attr_A).record_label = :dependent_record_1_A
          tracker.on(:object_1).with(:attr_A).model_name   = :dependent_model_1_A
          tracker.on(:object_1).with(:attr_B).record_label = :dependent_record_1_B
          tracker.on(:object_1).with(:attr_B).model_name   = :dependent_model_1_B

          tracker.on(:object_2).with(:attr_A).record_label = :dependent_record_2_A
          tracker.on(:object_2).with(:attr_A).model_name   = :dependent_model_2_A
          tracker.on(:object_2).with(:attr_B).record_label = :dependent_record_2_B
          tracker.on(:object_2).with(:attr_B).model_name   = :dependent_model_2_B

          tracker.on(:object_3).with(:attr_A).record_label = :dependent_record_3_A
          tracker.on(:object_3).with(:attr_A).model_name   = :dependent_model_3_A
          tracker.on(:object_3).with(:attr_B).record_label = :dependent_record_3_B
          tracker.on(:object_3).with(:attr_B).model_name   = :dependent_model_3_B
        end

        it 'lists all record_labels with specified_attributes' do
          expect(subject).to contain_exactly(:dependent_record_1_A, :dependent_record_2_A, :dependent_record_3_A)
        end
      end

      context 'without any dependencies registered' do
        it 'lists no record_labels' do
          expect(subject).to be_empty
        end
      end
    end

    describe '#list_all_model_names_with' do
      let(:tracker) { described_class.new }
      subject { tracker.list_all_model_names_with(:attr_B) }

      context 'with registered dependencies' do
        before do
          tracker.on(:object_1).with(:attr_A).record_label = :dependent_record_1_A
          tracker.on(:object_1).with(:attr_A).model_name   = :dependent_model_1_A
          tracker.on(:object_1).with(:attr_B).record_label = :dependent_record_1_B
          tracker.on(:object_1).with(:attr_B).model_name   = :dependent_model_1_B

          tracker.on(:object_2).with(:attr_A).record_label = :dependent_record_2_A
          tracker.on(:object_2).with(:attr_A).model_name   = :dependent_model_2_A
          tracker.on(:object_2).with(:attr_B).record_label = :dependent_record_2_B
          tracker.on(:object_2).with(:attr_B).model_name   = :dependent_model_2_B

          tracker.on(:object_3).with(:attr_A).record_label = :dependent_record_3_A
          tracker.on(:object_3).with(:attr_A).model_name   = :dependent_model_3_A
          tracker.on(:object_3).with(:attr_B).record_label = :dependent_record_3_B
          tracker.on(:object_3).with(:attr_B).model_name   = :dependent_model_3_B
        end

        it 'lists all model_names with specified_attributes' do
          expect(subject).to contain_exactly(:dependent_model_1_B, :dependent_model_2_B, :dependent_model_3_B)
        end
      end

      context 'without any dependencies registered' do
        it 'lists no model_names' do
          expect(subject).to be_empty
        end
      end
    end
  end
end
