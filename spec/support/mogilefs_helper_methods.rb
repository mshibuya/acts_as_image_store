# coding: utf-8
require 'mogilefs'

module MogilefsHelperMethods
  def mogilefs_prepare
    @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.backend['hosts']
    unless @mogadm.get_domains[MogileImageStore.backend['domain']]
      @mogadm.create_domain MogileImageStore.backend['domain']
      @mogadm.create_class  MogileImageStore.backend['domain'],
        MogileImageStore.backend['class'], 2 rescue nil
    end

  end

  def mogilefs_cleanup
    MogileImage.destroy_all
    @mogadm = MogileFS::Admin.new :hosts  => MogileImageStore.backend['hosts']
    @mg = MogileFS::MogileFS.new({ :domain => MogileImageStore.backend['domain'],
                                 :hosts  => MogileImageStore.backend['hosts'] })
    @mg.each_key('') {|k| @mg.delete k }
    @mogadm.delete_domain MogileImageStore.backend['domain']
  end
end

