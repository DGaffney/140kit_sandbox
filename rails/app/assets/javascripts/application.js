// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
// require twitter/bootstrap
//= require twitter/bootstrap/alert
//= require twitter/bootstrap/button
// require twitter/bootstrap/carousel
// require twitter/bootstrap/collapse
//= require twitter/bootstrap/dropdown
// require twitter/bootstrap/modal
// require twitter/bootstrap/popover
// require twitter/bootstrap/scrollspy
// require twitter/bootstrap/tab
// require twitter/bootstrap/tooltip
// require twitter/bootstrap/transition
// require twitter/bootstrap/typeahead
// require_tree .

$(function () { 
  $('form input#end_time').change( function() {
      $('form span#time_output').contents().replaceWith(exact_time(parseInt($('form input#end_time').attr("value"))));
  });
} );

function exact_time(seconds) {
  var statement = "";
  var time_set = new Array();
  time_set.push(parseInt(seconds/(60*60*24*7)));
  seconds = seconds-time_set[time_set.length-1]*60*60*24*7
  time_set.push(parseInt(seconds/(60*60*24)));
  seconds = seconds-time_set[time_set.length-1]*60*60*24
  time_set.push(parseInt(seconds/(60*60)));
  seconds = seconds-time_set[time_set.length-1]*60*60
  time_set.push(parseInt(seconds/(60)));
  seconds = seconds-time_set[time_set.length-1]*60
  time_set.push(seconds);
  ordered_set = new Array("Weeks", "Days", "Hours", "Minutes", "Seconds");
  i = 0
  for(var i = 0; i < time_set.length;i++){
      if (time_set[i] == 1){
          statement=statement+time_set[i]+" "+ordered_set[i].substring(0, ordered_set[i].length-1)+", ";
      } else if (time_set[i] != 0){
          statement=statement+time_set[i]+" "+ordered_set[i]+", ";
      };
  };
  return statement.substring(0, statement.length-2);
}