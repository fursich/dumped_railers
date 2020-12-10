# frozen_string_literal: true

RSpec.describe DumpedRailers::RecordBuilder::FixtureRow do

  describe '#analyze_dependencies!' do
    let(:fixture_row) { described_class.new(:object_1, attrs) }
    let(:dependency_tracker) { DumpedRailers::RecordBuilder::DependencyTracker.for(:Model_X).on(fixture_row) }
    let(:dependent_records) { dependency_tracker.dependent_record_labels }

    subject { fixture_row.analyze_dependencies!(dependency_tracker) }

    context 'when attrs are empty' do
      let(:attrs) { {} }
      it 'stores no dependencies' do
        subject
        expect(dependent_records).to be_empty
      end
    end

    context 'when attrs are given' do
      context 'without any dependent references' do
        let(:attrs) { { id: 1, title: 'Norwegian Wood' } }

        it 'stores no dependencies' do
          subject
          expect(dependent_records).to be_empty
        end
      end

      context 'with malformatted references' do
        let(:attrs) { { id: 1, title: 'After The Quake', author: '_author_83', next: '_author_33' } }

        it 'stores no dependencies' do
          subject
          expect(dependent_records).to be_empty
        end
      end

      context 'with (non-polymorphic) references' do
        let(:attrs) { { id: 2, title: 'Dance, Dance, Dance', author: '__author_33', publisher: '__publisher_532' } }

        it 'stores two dependencies' do
          subject
          expect(dependent_records.count).to eq 2
        end

        it 'has dependent author' do
          subject
          expect(dependency_tracker.with(:author)).to have_attributes(record_label: :__author_33, model_name: nil)
        end

        it 'has dependent publisher' do
          subject
          expect(dependency_tracker.with(:publisher)).to have_attributes(record_label: :__publisher_532, model_name: nil)
        end
      end

      context 'with polymorphic references' do
        let(:attrs) { { id: 3, title: '1Q84', author: '__novel_writer_12(NovelWriter)', inspired_by: '__novel_73(Novel)' } }

        it 'stores two dependencies' do
          subject
          expect(dependent_records.count).to eq 2
        end

        it 'has dependent author' do
          subject
          expect(dependency_tracker.with(:author)).to have_attributes(record_label: :__novel_writer_12, model_name: :NovelWriter)
        end

        it 'has dependent publisher' do
          subject
          expect(dependency_tracker.with(:inspired_by)).to have_attributes(record_label: :__novel_73, model_name: :Novel)
        end
      end
    end

    context 'when executed twice' do
      let(:attrs) { {} }

      before do
        fixture_row.analyze_dependencies!(dependency_tracker)
      end

      it 'raises RuntimeError' do
        expect { subject }.to raise_error RuntimeError
      end
    end
  end

  describe '#instantiate_as!' do
    let(:fixture_row) { described_class.new(:object_1, attrs) }
    let(:dependency_tracker) { DumpedRailers::RecordBuilder::DependencyTracker.for(model).on(fixture_row) }
    let(:model) { double('model').tap { |dbl| allow(dbl).to receive(:new).and_return(:an_object) } }
    let(:record_store) { described_class::RecordStore }

    context 'after dependency analysis has been properly done' do
      before do
        fixture_row.analyze_dependencies!(dependency_tracker)
      end
  
      subject { fixture_row.instantiate_as!(model) }
  
      shared_examples 'successful instantiation' do
        it 'initializes the model with attrs' do
          subject
          expect(model).to have_received(:new).with(resolved_attrs)
        end
  
        it 'is registered' do
          expect { subject }.to change { record_store.registered?(fixture_row.label) }.from(false).to(true)
        end
  
        it 'stores the generated object' do
          subject
          expect(record_store.retrieve!(fixture_row.label)).to eq :an_object
        end
      end
  
      context 'when attrs are empty' do
        let(:attrs) { {} }
  
        it_behaves_like 'successful instantiation' do
          let(:resolved_attrs) { {} }
        end
      end
  
      context 'when attrs are given' do
        context 'without any dependent references' do
          let(:attrs) { { id: 1, title: 'Norwegian Wood' } }
  
          it_behaves_like 'successful instantiation' do
            let(:resolved_attrs) { { id: 1, title: 'Norwegian Wood' } }
          end
        end
  
        context 'with malformatted references' do
          let(:attrs) { { id: 1, title: 'After The Quake', author: '_author_83', next: 'author_33' } }
  
          it_behaves_like 'successful instantiation' do
            let(:resolved_attrs) { { id: 1, title: 'After The Quake', author: '_author_83', next: 'author_33' } }
          end
        end
  
        context 'with (non-polymorphic) references' do
          let(:attrs) { { id: 2, title: 'Dance, Dance, Dance', author: '__author_33', publisher: '__publisher_532' } }
  
          context 'when some of the dependencies cannot be resolved' do
            before do
              described_class::RecordStore.register(:__author_33,     object: :record_for_haruki_murakami)
            end
  
            it 'raises RuntimeError' do
              expect { subject }.to raise_error RuntimeError
            end
          end
  
          context 'when all dependencies have been registered in RecordStore' do
            before do
              described_class::RecordStore.register(:__author_33,     object: :record_for_haruki_murakami)
              described_class::RecordStore.register(:__publisher_532, object: :record_for_kodansha)
            end
  
            it_behaves_like 'successful instantiation' do
              let(:resolved_attrs) { { id: 2, title: 'Dance, Dance, Dance', author: :record_for_haruki_murakami, publisher: :record_for_kodansha } }
            end
          end
        end
  
        context 'with polymorphic references' do
          let(:attrs) { { id: 3, title: '1Q84', author: '__novel_writer_12(NovelWriter)', inspired_by: '__novel_73(Novel)' } }
  
          context 'when some of the dependencies cannot be resolved' do
            before do
              described_class::RecordStore.register(:__novel_writer_12, object: :record_for_haruki_murakami)
            end
  
            it 'raises RuntimeError' do
              expect { subject }.to raise_error RuntimeError
            end
          end
  
          context 'when all dependencies have been registered in RecordStore' do
            before do
              described_class::RecordStore.register(:__novel_writer_12, object: :record_for_haruki_murakami)
              described_class::RecordStore.register(:__novel_73,        object: :record_for_nineteen_eighty_four)
            end
  
            it_behaves_like 'successful instantiation' do
              let(:resolved_attrs) { { id: 3, title: '1Q84', author: :record_for_haruki_murakami, inspired_by: :record_for_nineteen_eighty_four } }
            end
          end
        end
      end
    end

    context 'without dependency analysis in prior' do
      subject { fixture_row.instantiate_as!(model) }
  
      let(:attrs) { { id: 1, title: 'Norwegian Wood' } }
  
      it 'raises RuntimeError' do
        expect { subject }.to raise_error RuntimeError
      end
    end
  end
end
