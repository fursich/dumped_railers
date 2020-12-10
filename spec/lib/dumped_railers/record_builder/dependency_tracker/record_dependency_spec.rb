# frozen_string_literal: true

RSpec.describe DumpedRailers::RecordBuilder::DependencyTracker::RecordDependency do
  describe '#with' do
    let(:dependency) { described_class.new }
    subject { dependency.with(attribute) }

    context 'with a single attribute' do
      let(:attribute) { :attribute }
      it 'returns a DependentObject instace' do
        expect(subject).to be_an_instance_of described_class::DependentObject
      end

      it 'always returns the same object' do
        first_result = subject
        expect(subject).to eq first_result
      end
    end

    context 'with multiple attributes' do
      let(:attribute) { :attribute }
      let(:another_record_dependency) { dependency.with(:another_attribute) }

      it 'returns another object' do
        expect(subject).not_to eq another_record_dependency
      end
    end
  end

  describe '#dependent_record_labels' do
    let(:dependency) { described_class.new }
    subject { dependency.dependent_record_labels }

    context 'with registered dependencies' do

      before do
        dependency.with(:attr_A).record_label = :dependent_record_1_A
        dependency.with(:attr_A).model_name   = :dependent_model_1_A
        dependency.with(:attr_B).record_label = :dependent_record_1_B
        dependency.with(:attr_B).model_name   = :dependent_model_1_B
        dependency.with(:attr_C).record_label = :dependent_record_1_C
        dependency.with(:attr_C).model_name   = :dependent_model_1_C
      end
  
      it 'lists all record_labels regardless attributes' do
        expect(subject).to contain_exactly(:dependent_record_1_A, :dependent_record_1_B, :dependent_record_1_C)
      end
    end

    context 'without any dependencies registered' do
      it 'lists no record_labels' do
        expect(subject).to be_empty
      end
    end
  end


  describe '#each' do
    let(:dependency) { described_class.new }
    subject { -> (block) { dependency.each_dependent_record_label &block } }

    context 'with registered dependencies' do

      before do
        dependency.with(:attr_A).record_label = :dependent_record_1_A
        dependency.with(:attr_A).model_name   = :dependent_model_1_A
        dependency.with(:attr_B).record_label = :dependent_record_1_B
        dependency.with(:attr_B).model_name   = :dependent_model_1_B
        dependency.with(:attr_C).record_label = :dependent_record_1_C
        dependency.with(:attr_C).model_name   = :dependent_model_1_C
      end

      it 'iterates over all attributes x record_labels' do
        expect(subject).to yield_successive_args([:attr_A, :dependent_record_1_A],[:attr_B, :dependent_record_1_B],[:attr_C, :dependent_record_1_C])
      end
    end

    context 'without any dependencies registered' do
      it 'does not iterate anything' do
        expect(subject).not_to yield_control
      end
    end
  end
end
