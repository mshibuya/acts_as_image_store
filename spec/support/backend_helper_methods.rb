# coding: utf-8
require 'mogilefs'

module BackendHelperMethods
  def backend_prepare
  end

  def backend_purge
    StoredImage.storage.purge
  end
end

