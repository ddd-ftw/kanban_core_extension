class PhaseSpecAddingsController < ApplicationController

  def new
    @command = AddPhaseSpecCommand.new(
      project_id_str: params[:project_id_str],
      position: params[:position],
      base_phase_name: params[:base_phase_name]
    )
    render 'modal_window_form', locals: { path: 'boards/new_phase_spec_adding' }
  end

  def create
    @command = AddPhaseSpecCommand.new(command_params)
    if @command.execute(workflow_service)
      flash[:notice] = 'ワークフローにフェーズを追加しました。'
      render 'redirect_from_modal', locals: { to: board_url(@command.project_id_str) }
    else
      render 'modal_window_form', locals: { path: 'boards/new_phase_spec_adding' }
    end
  end

  def add_transition
    render 'boards/add_transition'
  end

  private

    def command_params
      params.require(:add_phase_spec_command).permit(
        :project_id_str, :phase_name, :wip_limit_count, { state_names: [] },
        :position, :base_phase_name
      )
    end
end
