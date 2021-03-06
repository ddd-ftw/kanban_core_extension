require 'rails_helper'

describe 'remove state' do
  let(:service) do
    PhaseSpecService.new(project_repository, board_repository, board_maintainer)
  end
  let(:project_repository) { ProjectRepository.new }
  let(:board_repository) { BoardRepository.new }
  let(:board_maintainer) { Kanban::BoardMaintainer.new(board_repository) }

  let(:project_id) { Project('Name', 'Goal') }

  let(:board_service) do
    BoardService(development_tracker: FakeDevelopmentTracker.new)
  end

  before do
    ProjectService().specify_workflow(project_id, workflow)
  end

  let(:phase) { Phase('Dev') }
  let(:new_workflow) { project_repository.find(project_id).workflow }

  context 'states = Doing|Review|Done' do
    let(:workflow) do
      Workflow([{ phase: phase, transition: ['Doing', 'Review', 'Done'] }])
    end

    context 'no card' do
      it do
        service.remove_state(project_id, phase, State('Review'))
        expect(new_workflow).to eq(
          Workflow([{ phase: phase, transition: ['Doing', 'Done'] }])
        )
      end
    end

    context 'card on Doing' do
      it do
        board_service.add_card(project_id, FeatureId('feat_1'))
        service.remove_state(project_id, phase, State('Review'))
        expect(new_workflow).to eq(
          Workflow([{ phase: phase, transition: ['Doing', 'Done'] }])
        )
      end
    end

    context 'card on Review' do
      it do
        board_service.add_card(project_id, FeatureId('feat_1'))
        board_service.forward_card(project_id, FeatureId('feat_1'), Step(phase.to_s, 'Doing'))
        expect {
          service.remove_state(project_id, phase, State('Review'))
        }.to raise_error(Activity::CardOnState)
      end
    end
  end
end
