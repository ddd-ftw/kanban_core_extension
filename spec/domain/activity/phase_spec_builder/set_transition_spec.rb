require 'rails_helper'

module Activity
  describe PhaseSpecBuilder do
    describe '#set_transition' do
      subject do
        factory.set_transition(states, project_id)
      end

      let(:factory) { described_class.new(current) }
      let(:built) { factory.build_phase_spec }

      let(:project_id) { ProjectId('prj_789') }
      let(:board) do
        Kanban::Board.new.tap {|b| b.prepare(project_id) }
      end

      context 'no transition' do
        let(:current) do
          PhaseSpec(phase: 'Dev', transition: nil, wip_limit: 2)
        end

        context 'set Doing|Done, card = none' do
          let(:states) { [State('Doing'), State('Done')] }

          it do
            subject
            expect(built).to eq(
              PhaseSpec(phase: 'Dev', transition: ['Doing', 'Done'], wip_limit: 2)
            )
          end
        end

        context 'set Doing|Done, card = 1' do
          let(:states) { [State('Doing'), State('Done')] }

          before do
            board.add_card(feature_id, Step('Dev'))
            board.save!
          end

          let(:feature_id) { FeatureId('feat_1') }

          it do
            subject
            expect(built).to eq(
              PhaseSpec(phase: 'Dev', transition: ['Doing', 'Done'], wip_limit: 2)
            )
          end

          it do
            expect(EventPublisher)
              .to receive(:publish)
              .with(
                :transition_setted,
                TransitionSetted.new(project_id, Phase('Dev'))
              )
            subject
          end
        end

        context 'set Doing|Done|Doing' do
          let(:states) { [State('Doing'), State('Done'), State('Doing')] }

          it do
            subject
            expect { built }.to raise_error(DuplicateState)
          end
        end
      end

      context 'transition already setted' do
        let(:current) do
          PhaseSpec(
            phase: 'Dev',
            transition: ['Doing', 'Review', 'Done'],
            wip_limit: 2
          )
        end

        let(:states) { [State('Doing'), State('Done')] }

        it do
          expect { subject }.to raise_error(TransitionAlreadySetted)
        end
      end
    end
  end
end
