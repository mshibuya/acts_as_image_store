# coding: utf-8
require 'mogilefs'

module MogilefsHelperMethods
  def mogilefs_prepare
    @mogadm = MogileFS::Admin.new :hosts  => ActsAsImageStore.backend['hosts']
    unless @mogadm.get_domains[ActsAsImageStore.backend['domain']]
      @mogadm.create_domain ActsAsImageStore.backend['domain']
      @mogadm.create_class  ActsAsImageStore.backend['domain'],
        ActsAsImageStore.backend['class'], 2 rescue nil
    end

  end

  def mogilefs_cleanup
    StoredImage.destroy_all
    @mogadm = MogileFS::Admin.new :hosts  => ActsAsImageStore.backend['hosts']
    @mg = MogileFS::MogileFS.new({ :domain => ActsAsImageStore.backend['domain'],
                                 :hosts  => ActsAsImageStore.backend['hosts'] })
    @mg.each_key('') {|k| @mg.delete k }
    @mogadm.delete_domain ActsAsImageStore.backend['domain']
  end
end

