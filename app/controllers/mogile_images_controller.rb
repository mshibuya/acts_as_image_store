# coding: utf-8

class MogileImagesController < ApplicationController
  protect_from_forgery :except => [:flush]
  
  rescue_from MogileImageStore::ImageNotFound, :with => :error_404
  rescue_from MogileImageStore::SizeNotAllowed, :with => :error_404

  ##
  # 画像の送信、もしくはx-reproxy-cache-forヘッダ出力を行う
  #
  def show
    if MogileImageStore.backend['reproxy']
      type, urls = MogileImage.fetch_urls(params[:name], params[:format], params[:size])
      response.header['Content-Type'] = type
      response.header['X-REPROXY-URL'] = urls.join(' ')
      if MogileImageStore.backend['cache']
        response.header['X-REPROXY-CACHE-FOR'] = "#{MogileImageStore.backend['cache']}; Content-Type"
      end
      render :nothing => true
    else
      type, data = MogileImage.fetch_data(params[:name], params[:format], params[:size])
      response.header['Content-Type'] = type
      render :layout => false, :text => data
    end
  end

  ##
  # reproxyが有効の際にreproxy cacheのクリアを行う
  #
  def flush
    unless MogileImageStore.backend['reproxy'] && MogileImageStore.backend['cache']
      render :nothing => true, :status => "206 No Content"
      return
    end

    body = request.body.read
    # authentication
    if request.env[MogileImageStore::AUTH_HEADER_ENV] == MogileImageStore.auth_key(body)
      response.header['X-REPROXY-CACHE-CLEAR'] = body
      render :nothing => true, :status => "200 OK"
    else
      render :nothing => true, :status => "401 Unauthorized"
    end
  end

  def error_404
    render :nothing => true, :status => "404 Not Found"
  end
end
