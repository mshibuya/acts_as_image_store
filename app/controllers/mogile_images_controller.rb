class MogileImagesController < ApplicationController
  # GET /images/200x150/1234567890abcdef1234567890abcdef.jpg
  def show
#    type, urls = MogileImage.fetch_urls(params[:name], params[:format], params[:size])
    type, data = MogileImage.fetch_data(params[:name], params[:format], params[:size])
    response.header['Content-Type'] = type
#    response.header['X-REPROXY-URL'] = urls.join(' ')
#    render :nothing => true
p data.size
    render :layout => false, :text => data
  end
end
