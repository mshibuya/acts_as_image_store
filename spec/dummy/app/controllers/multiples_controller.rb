class MultiplesController < ApplicationController
  image_deletable
  # GET /multiples
  # GET /multiples.xml
  def index
    @multiples = Multiple.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @multiples }
    end
  end

  # GET /multiples/1
  # GET /multiples/1.xml
  def show
    @multiple = Multiple.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @multiple }
    end
  end

  # GET /multiples/new
  # GET /multiples/new.xml
  def new
    @multiple = Multiple.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @multiple }
    end
  end

  # GET /multiples/1/edit
  def edit
    @multiple = Multiple.find(params[:id])
  end

  # POST /multiples
  # POST /multiples.xml
  def create
    @multiple = Multiple.new(params[:multiple])

    respond_to do |format|
      if @multiple.save
        format.html { redirect_to(multiple_path(@multiple), :notice => 'Multiple was successfully created.') }
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
    @multiple = Multiple.find(params[:id])

    respond_to do |format|
      if @multiple.update_attributes(params[:multiple])
        format.html { redirect_to(multiple_path(@multiple), :notice => 'Multiple was successfully updated.') }
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
    @multiple = Multiple.find(params[:id])
    @multiple.destroy

    respond_to do |format|
      format.html { redirect_to(multiples_url) }
      format.xml  { head :ok }
    end
  end

end
