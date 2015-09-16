class WorkflowService

  def initialize(project_repository, board_repository)
    @project_repository = project_repository
    @board_repository = board_repository
  end

  def add_phase_spec(project_id, phase_spec, option = nil)
    project = @project_repository.find(project_id)

    builder = Project::WorkflowBuilder.new(project.workflow)
    add_with_position(option) do |direction, base_phase|
      case direction
      when :before
        builder.insert_phase_spec_before(phase_spec, base_phase)
      when :after
        builder.insert_phase_spec_after(phase_spec, base_phase)
      else
        builder.add_phase_spec(phase_spec)
      end
    end

    project.specify_workflow(builder.workflow)
    @project_repository.store(project)
  end

  def set_transition(project_id, phase, transition)
    project = @project_repository.find(project_id)

    builder = Project::WorkflowBuilder.new(project.workflow)
    builder.set_transition(phase, transition)
    project.specify_workflow(builder.workflow)

    @project_repository.store(project)
  end

  def add_state(project_id, phase, state, option)
    project = @project_repository.find(project_id)

    builder = Project::WorkflowBuilder.new(project.workflow)
    add_with_position(option) do |direction, base_state|
      case direction
      when :before
        builder.insert_state_before(phase, state, base_state)
      when :after
        builder.insert_state_after(phase, state, base_state)
      end
    end

    project.specify_workflow(builder.workflow)
    @project_repository.store(project)
  end

  private

    def add_with_position(option)
      direction, base = Hash(option).flatten
      yield(direction, base)
    end
end