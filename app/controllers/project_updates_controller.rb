# This is the controller to manage updates to projects by users.
class ProjectUpdatesController < ApplicationController
  before_filter :require_user

  # Creates a new update to a project
  def create
    @project = Project.find(params[:project_id])
    @annotation = @project.project_updates.create(params[:project_update])
    redirect_to project_path(@project)
  end
  
end