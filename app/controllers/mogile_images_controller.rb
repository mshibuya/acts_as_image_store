class MogileImagesController < ApplicationController
  # GET /images/200x150/1234567890abcdef1234567890abcdef.jpg
  rescue_from MogileImageStore::ImageNotFound, :with => :error_404 
  rescue_from MogileImageStore::SizeNotAllowed, :with => :error_404 
  def show
    if MogileImageStore.backend[:reproxy]
      type, urls = MogileImage.fetch_urls(params[:name], params[:format], params[:size])
      response.header['Content-Type'] = type
      response.header['X-REPROXY-URL'] = urls.join(' ')
      render :nothing => true
    else
      type, data = MogileImage.fetch_data(params[:name], params[:format], params[:size])
      response.header['Content-Type'] = type
      render :layout => false, :text => data
    end
  end

  def error_404
    render :nothing => true, :status => "404 Not Found"
  end
end
