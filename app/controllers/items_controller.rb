# The controller for manipulation of items.
# This was largely auto-generated as a scaffold controller, which is the
# reason for all that boilerplate you see below.
class ItemsController < ApplicationController
  before_filter :require_user

  # GET /items
  # GET /items.xml
  # Displays the index page listing all items.
  def index
    @items = Item.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1
  # GET /items/1.xml
  # Shows an individual item.
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/new
  # GET /items/new.xml
  # Creates a new item.
  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/1/edit
  # Edits an existing item.
  def edit
    @item = Item.find(params[:id])

    if @item.lab then
      return false unless require_lab_admin(@item.lab)
    else
      return false unless require_super_admin(@item.lab)
    end
  end

  # POST /items
  # POST /items.xml
  # Creates an item, given some parameters.
  def create
    if params[:lab_id] then
      # Create an item, but then redirect back to the lab it belongs to.
      @lab = Lab.find(params[:lab_id])
      @item = @lab.items.create(params[:item])
      redirect_to lab_path(@lab)
    else
      # This is just the generic create, called from the item view.
      @item = Item.new(params[:item])

      if @item.lab then
        return false unless require_lab_admin(@item.lab)
      else
        return false unless require_super_admin(@item.lab)
      end

      respond_to do |format|
        if @item.save
          format.html { redirect_to(@item, :notice => 'Item was successfully created.') }
          format.xml  { render :xml => @item, :status => :created, :location => @item }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  # Updates an existing item.
  def update
    @item = Item.find(params[:id])

    if @item.lab then
      return false unless require_lab_admin(@item.lab)
    else
      return false unless require_super_admin(@item.lab)
    end

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to(@item, :notice => 'Item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  # Deletes an item.
  def destroy
    @item = Item.find(params[:id])

    if @item.lab then
      return false unless require_lab_admin(@item.lab)
    else
      return false unless require_super_admin(@item.lab)
    end

    @item.destroy

    respond_to do |format|
      format.html { redirect_to(items_url) }
      format.xml  { head :ok }
    end
  end
end
