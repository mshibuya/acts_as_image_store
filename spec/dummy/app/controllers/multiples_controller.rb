class MultiplesController < ApplicationController
  before_filter :find_confirm
  image_deletable
  # GET /multiples
  # GET /multiples.xml
  def index
    @multiples = @confirm.multiples.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @multiples }
    end
  end

  # GET /multiples/1
  # GET /multiples/1.xml
  def show
    @multiple = @confirm.multiples.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @multiple }
    end
  end

  # GET /multiples/new
  # GET /multiples/new.xml
  def new
    @multiple = @confirm.multiples.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @multiple }
    end
  end

  # GET /multiples/1/edit
  def edit
    @multiple = @confirm.multiples.find(params[:id])
  end

  # POST /multiples
  # POST /multiples.xml
  def create
    @multiple = @confirm.multiples.new(params[:multiple])

    respond_to do |format|
      if @multiple.save
        format.html { redirect_to(confirm_multiple_path(@confirm, @multiple), :notice => 'Multiple was successfully created.') }
        format.xml  { render :xml => @multiple, :status => :created, :location => @multiple }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @multiple.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /multiples/1
  # PUT /multiples/1.xml
  def update
    @multiple = @confirm.multiples.find(params[:id])

    respond_to do |format|
      if @multiple.update_attributes(params[:multiple])
        format.html { redirect_to(confirm_multiple_path(@confirm, @multiple), :notice => 'Multiple was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @multiple.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /multiples/1
  # DELETE /multiples/1.xml
  def destroy
    @multiple = @confirm.multiples.find(params[:id])
    @multiple.destroy

    respond_to do |format|
      format.html { redirect_to(confirm_multiples_url(@confirm)) }
      format.xml  { head :ok }
    end
  end

  private

  def find_confirm
    @confirm = Confirm.find(params[:confirm_id])
  end
end
