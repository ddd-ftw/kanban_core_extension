class ProjectService

  def initialize(project_repository, board_repository, board_builder)
    @project_repository = project_repository
    @board_repository = board_repository
    @board_builder = board_builder
  end

  def launch(description)
    EventPublisher.subscribe(@board_builder)

    factory = Project::ProjectFactory.new(@project_repository)
    project = factory.launch_project(description)
    @project_repository.store(project)

    project.project_id
  end

  def specify_workflow(project_id, workflow)
    project = @project_repository.find(project_id)

    project.specify_workflow(workflow)

    @project_repository.store(project)
  end

  def launch_with_workflow(description, workflow)
    project_id = launch(description)
    specify_workflow(project_id, workflow)
  end

  def change_wip_limit(project_id, phase, new_wip_limit)
    project = @project_repository.find(project_id)
    board = @board_repository.find(project_id)

    project.change_wip_limit(phase, new_wip_limit, board)

    @project_repository.store(project)
  end
end
