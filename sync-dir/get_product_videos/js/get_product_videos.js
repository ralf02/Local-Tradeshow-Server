 /**
 * get_product_videos.js
 *
 * @fileoverview Displays a message on the console to verify the file is working *
 * @version 1.0
 * @author Rafael Contreras <ralfcontreras@gmail.com>
 */
 (function ($, Drupal, drupalSettings) {
  'use strict';

  $('.menubar .nav-link[href="/support"]').parent().remove();
  $('.menubar .nav-link[href="https://www.macdonperformanceparts.com/"]').parent().remove();
  $('.menubar .nav-link[href="/dealer-locator"]').parent().remove();
  $('.menubar .nav-link[href="/find-a-dealer"]').parent().remove();
  $('.menubar .nav-link[href="/stories"]').parent().remove();
  $('.menubar .nav-link[href="/user/login"]').parent().remove();

  $('.menubar .search').remove();

  $('footer .bandfooter1').remove();

  $('#seeitaction').attr('onclick',"openSetitActionCustom('myPopupKCt',this.id)");
  $('.playVideoHome').removeClass('playVideoHome').addClass('playVideoHomeCustom');
  $('.playVideoHomeCustom').attr('onclick',"playVideoCustom(this.id)");
  $('.videobacksetitaction .divclose').attr('onclick',"closeVideoLBCustom(this)");

  $('.linkvideopopup .buttonCustom').click(function (e) {
      e.preventDefault();
      var strVideoId = $(this).attr('href');
      var arrVideoId = strVideoId.split('&')
      var videoId = arrVideoId[0];
      videoId = videoId.replace(/https|http|www.|youtu.be|watch\?v=|youtube.com|&t=1s|:|\//gi, '');
      var url = '/sites/default/files/videos/syn_'+videoId+'.mp4';
      console.log('videoId',videoId);
      console.log('url',url);
      window.open(url,'_blank');
  });

  loadPlayVideo();

  Drupal.behaviors.betterExposedFiltersAutoSubmit = {
    attach: function(context) {
        $(document).once('weberAjaxViews').ajaxComplete(function (event, xhr, settings) {
            loadPlayVideo();
        });
    }
}

})(jQuery, Drupal, drupalSettings);

function loadPlayVideo(){
    jQuery('.playVideoView').removeClass('playVideoView').addClass('playVideoViewCustomCss');
    jQuery('.playVideoViewCustomCss').attr('onclick','playVideoViewCustom(this)');
}

function openSetitActionCustom(idpop,id)
{
    var videoId = jQuery("#"+id).attr("data-media");
    videoId = videoId.replace(/https|http|www.|youtu.be|watch\?v=|youtube.com|&t=1s|:|\//gi, '');

    jQuery('#myPopupKt').fadeIn('slow');
    var popup       = document.getElementById(idpop);
    var url = '/sites/default/files/videos/syn_'+videoId+'.mp4';
    popup.innerHTML='<iframe src="'+url+'?fs=1" allowfullscreen webkitallowfullscreen mozallowfullscreen" class="iframe-media"></iframe>';
}

function playVideoCustom(evt){

    var idblock = jQuery("#"+evt).attr('data-idblock');
    var idTagVideo = jQuery("#"+evt).attr("data-video")

    var idpop = '#myPopupKw'+idblock;
    jQuery(idpop).fadeIn('slow');

    var videoId = jQuery("#"+evt).attr("data-source");
    videoIdStr = videoId.replace(/https|http|www.|youtu.be|watch\?v=|youtube.com|&t=1s|:|\//gi, '');
    var url = '/sites/default/files/videos/syn_'+videoIdStr+'.mp4';

    jQuery('.videoaction iframe').attr('src',url);

}

function closeVideoLBCustom(obj)
{
    jQuery(obj).parent().parent().fadeOut('slow');
    jQuery('#myPopupKt').fadeOut('slow');
    jQuery('.videoaction iframe').attr('src','');
}

function openSetitActionCustom2(idpop,id)
{
    var videoId = jQuery("#"+id).attr("data-media");
    videoId = videoId.replace(/https|http|www.|youtu.be|watch\?v=|youtube.com|&t=1s|:|\//gi, '');

    jQuery('#myPopupKt').fadeIn('slow');
    var popup       = document.getElementById(idpop);
    var url = '/sites/default/files/videos/syn_'+videoId+'.mp4';
    popup.innerHTML='<iframe src="'+url+'?fs=1" allowfullscreen webkitallowfullscreen mozallowfullscreen" class="iframe-media"></iframe>';
}

function playVideoViewCustom(obj){

    jQuery('#myPopupKw'+jQuery(obj).attr('data-popup')).fadeIn('slow');

    if(jQuery(obj).attr("data-rt")!="") {

        var popup       = document.getElementById("videoaction"+jQuery(obj).attr('data-popup'));
        var videoId = jQuery(obj).attr("data-rt");
        videoId = videoId.replace(/https|http|www.|youtu.be|watch\?v=|youtube.com|&t=1s|:|\//gi, '');
        var url = '/sites/default/files/videos/syn_'+videoId+'.mp4';
        popup.innerHTML='<iframe src="'+url+'?fs=1" allowfullscreen webkitallowfullscreen mozallowfullscreen" class="iframe-media"></iframe>';
    } else {
        var popup       = document.getElementById("videoaction"+jQuery(obj).attr('data-popup'));
        popup.innerHTML='<video class="videoherobackground " autoplay="autoplay" controls loop preload muted><source src="'+jQuery(obj).attr("data-lc")+'" type="video/mp4" /></video>';
    }

    return false;
}
