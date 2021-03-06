# The controller for projects.
class ProjectsController < ApplicationController
  before_filter :require_user
  
  # Shows the list of all projects
  def index
    @projects = Project.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # Shows the page for a single lab. 
  def show
    @project = Project.find(params[:id])
    @owners = ProjectAssignment.find(:all, :conditions => { :project_id => @project.id, :owner => 1 })

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # Shows the page to make a new project
  def new
    @project = Project.new
    10.times { @project.project_images.build }
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # Shows the page that allows editing of a project
  def edit
    @project = Project.find(params[:id])
    10.times { @project.project_images.build }

    return false unless require_project_owner(@project)

    @users = User.all
    @owners = ProjectAssignment.find(:all, :conditions => { :project_id => @project.id, :owner => 1 })
    @passed_owners = params[:owners]
  end

  # Actually creates a new lab
  def create
    @project = Project.new(params[:project])
    @project.users << current_user
    
    respond_to do |format|
      if @project.save
        @project.add_owner(current_user)

        format.html { redirect_to(@project, :notice => 'Project was successfully created.') }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Commits an update to the entry title
  def update_entry_title
    @entry = ProjectUpdate.find(params[:id])
    @entry.title = params[:value]
    @entry.save
    render :text => params[:value]
  end

  # Commits an update to the entry content
  def update_entry_content
    @entry = ProjectUpdate.find(params[:id])
    @entry.content = params[:value]
    @entry.save
    render :text => params[:value]
  end
  
  # Commits an update to the project itself
  def update
    @project = Project.includes(:project_images).find(params[:id])

    return false unless require_project_owner(@project)

    respond_to do |format|
      if @project.update_attributes(params[:project])
        @passed_users = params[:all_users] 
        @passed_members = params[:members]
        @passed_owners = params[:owners]
        
        p_users_array = @project.users.map { |user| [user.username, user.id] }
        
        if !@passed_users.nil?
          @passed_users.each do |user|
            if @project.users.include?(User.find(user.to_i))
              @project.users.delete(User.find(user.to_i))
            end
            
            if @project.owners.include?(User.find(user.to_i))
              @project.remove_owner(User.find(user.to_i))
            end
          end
        end
        
        if !@passed_members.nil?
          @passed_members.each do |member|
            if !@project.users.include?(User.find(member.to_i))
              @project.users << User.find(member.to_i)
            end
            
            if @project.owners.include?(User.find(member.to_i))
              @project.remove_owner(User.find(member.to_i))
            end
          end
        end
        
        if !@passed_owners.nil?
          @passed_owners.each do |owner|
            if !@project.users.include?(User.find(owner.to_i))
              @project.users << User.find(owner.to_i)
            end
            
            if !@project.owners.include?(User.find(owner.to_i))
              @project.add_owner(User.find(owner.to_i))
            end
          end
        end
        
        format.html { redirect_to(@project, :notice => 'Project successfully updated') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Deletes the project for real.
  def destroy
    @project = Project.find(params[:id])

    return false unless require_project_owner(@project)

    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
end
