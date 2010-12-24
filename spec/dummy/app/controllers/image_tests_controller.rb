class ImageTestsController < ApplicationController
  # GET /image_tests
  # GET /image_tests.xml
  def index
    @image_tests = ImageTest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @image_tests }
    end
  end

  # GET /image_tests/1
  # GET /image_tests/1.xml
  def show
    @image_test = ImageTest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @image_test }
    end
  end

  # GET /image_tests/new
  # GET /image_tests/new.xml
  def new
    @image_test = ImageTest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @image_test }
    end
  end

  # GET /image_tests/1/edit
  def edit
    @image_test = ImageTest.find(params[:id])
  end

  # POST /image_tests
  # POST /image_tests.xml
  def create
    @image_test = ImageTest.new(params[:image_test])

    respond_to do |format|
      if @image_test.save
        format.html { redirect_to(@image_test, :notice => 'Image test was successfully created.') }
        format.xml  { render :xml => @image_test, :status => :created, :location => @image_test }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @image_test.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /image_tests/1
  # PUT /image_tests/1.xml
  def update
    @image_test = ImageTest.find(params[:id])

    respond_to do |format|
      if @image_test.update_attributes(params[:image_test])
        format.html { redirect_to(@image_test, :notice => 'Image test was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @image_test.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /image_tests/1
  # DELETE /image_tests/1.xml
  def destroy
    @image_test = ImageTest.find(params[:id])
    @image_test.destroy

    respond_to do |format|
      format.html { redirect_to(image_tests_url) }
      format.xml  { head :ok }
    end
  end
end
