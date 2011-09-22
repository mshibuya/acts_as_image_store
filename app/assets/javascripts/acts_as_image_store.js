jQuery.fn.extend({
  multipleImage: function(){
    jQuery(this).find('th input').live('click', function(evt){
      jQuery(this).parent().parent().remove();
      return false;
    });
    jQuery(this).parent().find('.multiple_image_add').bind('click', function(evt){
      table = jQuery(this).parent().find('.multiple_images');
      tags = table.find('tbody:last-child').html();
      table.find('tbody:first-child').append(tags);
      return false;
    });
    jQuery(this).find('tbody:first-child').sortable({items:"tr"});
  }
});

jQuery(function($){ $('.multiple_images').multipleImage(); });

