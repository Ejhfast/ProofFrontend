$('document').ready(function(){
  
  // Pull up page to add new ruleset
  
  $('#add_ruleset').click(function(){
    $.get('rulesets/new', function(data){
      $('body').append("<div id='overlay'></div>");
      $('body').append("<div id='popup'>"+data+"</div>");
      $('#cancel').click(function(){
        $('#overlay').remove();
        $('#popup').remove();
      });
    });
  });
  
  // Ditto for assumption
  
  $('#add_assumption').click(function(){
    $.get('assumptions/new', function(data){
      $('body').append("<div id='overlay'></div>");
      $('body').append("<div id='popup'>"+data+"</div>");
      $('#cancel').click(function(){
        $('#overlay').remove();
        $('#popup').remove();
      });
    });
  });
  
  // Ditto for syntax
  
  $('#add_syntax').click(function(){
    $.get('syntaxes/new', function(data){
      $('body').append("<div id='overlay'></div>");
      $('body').append("<div id='popup'>"+data+"</div>");
      $('#cancel').click(function(){
        $('#overlay').remove();
        $('#popup').remove();
      });
    });
  });
  
  // Pull up page to add new assignment
  
  $('#new_assignment').click(function(){
    $.get('/assignments/new', function(data){
      $('body').append("<div id='overlay'></div>");
      $('body').append("<div id='popup'>"+data+"</div>");
      $('#cancel').click(function(){
        $('#overlay').remove();
        $('#popup').remove();
      });
    });
  });
  
  // Pull up a page to add new hint
  
  $('#new_hint').click(function(){
    var assign_id = $('#assign_id').html().replace(/ |\n/g,""),
        n_id = $('#node_id').html().replace(/ |\n/g,""),
        p_id = $('#parent_id').html().replace(/ |\n/g,"");
    console.log(assign_id); 
    $.get('/assignments/'+assign_id+'/hints/new',
      {node_id:n_id,
       parent_id:p_id},
      function(data){
      $('body').append("<div id='overlay'></div>");
      $('body').append("<div id='popup'>"+data+"</div>");
      $('#cancel').click(function(){
        $('#overlay').remove();
        $('#popup').remove();
      });
    });
  });
  
  
  // Verify assignment
  
  $('#verify').click(function(){
    $('#contentbox').spin(opts);
    $('#edit_assignment').fadeTo(0,.3);
    $.get('verify', function(data){
      console.log(data);
      $('#contentbox').spin(false);
      $('#edit_assignment').fadeTo(0,1);
      make_popup("Verification",data);
    })
  });
  
  // Hints
  
  $('.hint').live('click',function(){
    $('body').append("<div id='overlay'></div>");
    $('body').append("<div id='popup'>"+$(this).find('.text').html()+"</div>");
    $('#cancel').click(function(){
      $('#overlay').remove();
      $('#popup').remove();
    });
    $('#overlay').click(function(){
      $('#overlay').remove();
      $('#popup').remove();
    });
  });
  
  
  // Actions...
  
  $('.chzn-select').chosen();
  
  $('.del').live('click', function(){
   // if($('.'+$('.del').parent().attr('class')).length > 1){
      $(this).parent().hide();
      $(this).prev('input').val(1);
  //  } 
  });
  
  $('#proof #add_proof').live('click',function(){
    $('#proof form').submit();
  });
  
  spinner_listener();
  
  // Check for proof changes
  
  $('.proofline input, .proofline select').live('change',function(){
    $(this).parentsUntil('#prooflines_list').find('input[id*="_proven"]').val(false);
    $(this).parentsUntil('#prooflines_list').last().removeClass('proven')
  });
  
  
  // Expan/collapse rulesets
  
  $('.expand span.toggle').live('click',function(){
    console.log($(this).parentsUntil('.expand').last().parent().find('ul').toggle());
  });
  
});

// Add/Delete rules from ruleset form

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}

function add_fields(link,association,content){
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $('#'+association+'_list').append(content.replace(regexp, new_id));
  $('.del').click(function(){
    if($('.'+$('.del').parent().attr('class')).length > 1){
      $(this).parent().hide();
      $(this).prev('input').val(1);
    } 
  });
  // Chose need unique ids
  $('#'+association+'_list').find('select').each(function(i,v){
    $(v).attr('id',i);
  });
  $('.chzn-select').chosen();
};

// Edit ruleset

function edit_ruleset(assignment_id, ruleset_id){
  $.get('/assignments/'+assignment_id+'/rulesets/'+ruleset_id+'/edit', function(data){
    $('body').append("<div id='overlay'></div>");
    $('body').append("<div id='popup'>"+data+"</div>");
    $('#cancel').click(function(){
      $('#overlay').remove();
      $('#popup').remove();
    });
    $('.del').click(function(){
      if($('.'+$('.del').parent().attr('class')).length > 1){
        $(this).parent().hide();
        $(this).prev('input').val(1); 
      }
    });
  });
};

// Edit Assumption

function edit_assumption(assignment_id, assumption_id){
  $.get('/assignments/'+assignment_id+'/assumptions/'+assumption_id+'/edit', function(data){
    $('body').append("<div id='overlay'></div>");
    $('body').append("<div id='popup'>"+data+"</div>");
    $('#cancel').click(function(){
      $('#overlay').remove();
      $('#popup').remove();
    });
  });
};

// Edit Syntax

function edit_syntax(assignment_id, syntax_id){
  $.get('/assignments/'+assignment_id+'/syntaxes/'+syntax_id+'/edit', function(data){
    $('body').append("<div id='overlay'></div>");
    $('body').append("<div id='popup'>"+data+"</div>");
    $('#cancel').click(function(){
      $('#overlay').remove();
      $('#popup').remove();
    });
  });
};


// Spinner

var opts = {
  lines: 12, // The number of lines to draw
  length: 5, // The length of each line
  width: 3, // The line thickness
  radius: 10, // The radius of the inner circle
  color: '#000', // #rgb or #rrggbb
  speed: 1, // Rounds per second
  trail: 60, // Afterglow percentage
  shadow: false // Whether to render a shadow
};

$.fn.spin = function(opts) {
  this.each(function() {
    var $this = $(this),
        data = $this.data();

    if (data.spinner) {
      data.spinner.stop();
      delete data.spinner;
    }
    if (opts !== false) {
      data.spinner = new Spinner($.extend({color: $this.css('color')}, opts)).spin(this);
    }
  });
  return this;
};

function spinner_listener(){
  console.log('running');
  $('#submit_proof').live('click', function(){
    $('#spinner').spin(opts);
    $('#prooflines_list').fadeTo(0,.7)
    $('#prooflines_list').click(function(){
      $('#spinner').spin(false);
      $('#prooflines_list').fadeTo(0,1);
      $('#stop').attr('hit',"true");
    });
  });
};

function make_popup(title,data){
  var popup = "<div id='msg'><div class='sec'><div class='title'>"+title+"</div></div><div class='msg'>"+data+"</div><div class='blue_button' id='cancel'>Ok</div></div>";
  $('body').append("<div id='overlay'></div>");
  $('body').append(popup);
  $('#cancel').click(function(){
    $('#overlay').remove();
    $('#msg').remove();
  });
};