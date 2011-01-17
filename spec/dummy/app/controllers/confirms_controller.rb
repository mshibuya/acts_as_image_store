class ConfirmsController < ApplicationController
  image_deletable
  # GET /confirms
  # GET /confirms.xml
  def index
    @confirms = Confirm.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @confirms }
    end
  end

  # GET /confirms/1
  # GET /confirms/1.xml
  def show
    @confirm = Confirm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @confirm }
    end
  end

  # GET /confirms/new
  # GET /confirms/new.xml
  def new
    @confirm = Confirm.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @confirm }
    end
  end

  # GET /confirms/1/edit
  def edit
    @confirm = Confirm.find(params[:id])
  end

  # POST /confirms/1/confirm
  # PUT  /confirms/1/confirm
  def confirm
    case request.request_method
    when "POST"
      @confirm    = Confirm.new(params[:confirm])
    when "PUT"
      @confirm = Confirm.find(params[:id])
      @confirm.attributes = params[:confirm]
    end

    render :action => (@confirm.new_record? ? :new : :edit) unless @confirm.valid?
  end


  # POST /confirms
  # POST /confirms.xml
  def create
    @confirm = Confirm.new(params[:confirm])

    respond_to do |format|
      if @confirm.save
        format.html { redirect_to(@confirm, :notice => 'Confirm was successfully created.') }
        format.xml  { render :xml => @confirm, :status => :created, :location => @confirm }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @confirm.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /confirms/1
  # PUT /confirms/1.xml
  def update
    @confirm = Confirm.find(params[:id])

    respond_to do |format|
      if @confirm.update_attributes(params[:confirm])
        format.html { redirect_to(@confirm, :notice => 'Confirm was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @confirm.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /confirms/1
  # DELETE /confirms/1.xml
  def destroy
    @confirm = Confirm.find(params[:id])
    @confirm.destroy

    respond_to do |format|
      format.html { redirect_to(confirms_url) }
      format.xml  { head :ok }
    end
  end
end
