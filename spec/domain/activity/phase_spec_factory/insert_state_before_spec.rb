require 'rails_helper'

module Activity
  describe PhaseSpecFactory do
    let(:factory) { described_class.new(current) }
    let(:new_phase_spec) { factory.build_phase_spec }

    context 'current Doing|Review|Done' do
      let(:current) do
        PhaseSpec(phase: 'Dev', transition: ['Doing', 'Review', 'Done'])
      end

      context 'insert before Doing' do
        it do
          factory.insert_state_before(State('KPT'), State('Doing'))
          expect(new_phase_spec).to eq(
            PhaseSpec(
              phase: 'Dev',
              transition: ['KPT', 'Doing', 'Review', 'Done']
            )
          )
        end
      end

      context 'insert before Review' do
        it do
          factory.insert_state_before(State('KPT'), State('Review'))
          expect(new_phase_spec).to eq(
            PhaseSpec(
              phase: 'Dev',
              transition: ['Doing', 'KPT', 'Review', 'Done']
            )
          )
        end
      end

      context 'insert before Done' do
        it do
          factory.insert_state_before(State('KPT'), State('Done'))
          expect(new_phase_spec).to eq(
            PhaseSpec(
              phase: 'Dev',
              transition: ['Doing', 'Review', 'KPT', 'Done']
            )
          )
        end
      end

      context 'insert Doing before Done' do
        it do
          factory.insert_state_before(State('Doing'), State('Done'))
          expect { new_phase_spec }.to raise_error(DuplicateState)
        end
      end

      context 'insert before None' do
        it do
          expect {
            factory.insert_state_before(State('KPT'), State('None'))
          }.to raise_error(StateNotFound)
        end
      end
    end
  end
end
