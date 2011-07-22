module RailsAdmin
  class ImageStoreController < RailsAdmin::ApplicationController
    include ActionView::Helpers::TextHelper

    attr_accessor :image_model

    before_filter :get_model

    image_deletable

    def image_delete
      begin
        process_delete_image(@abstract_model.model)
      rescue ::ActiveRecord::RecordInvalid, ::ActsAsImageStore::ImageNotFound
        redirect_to({ :action => 'edit' },
                    :alert => I18n.translate('acts_as_image_store.errors.flashes.delete_failed'))
        return
      end
      redirect_to ({
        :controller => "rails_admin/main",
        :model_name => params[:model_name],
        :action => "edit",
        :id => params[:id],
      })
    end
  end
end
