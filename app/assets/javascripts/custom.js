$(document).ready(function(){
	$('.right.menu.open').on("click",function(e){
    e.preventDefault();
		$('.ui.vertical.menu').toggle();
	});

	$('.message .close')
  .on('click', function() {
    $(this)
      .closest('.message')
      .transition('fade')
    ;
  });

  $('.ui.checkbox').checkbox();

  $('select.dropdown').dropdown();

  toggleDishCategorySelectDisplay();
});

var toggleDishCategorySelectDisplay = function(){
  $('#recipe_type').change(function(){
    this.value == 1 ? $('#newRecipeDishCategory').show() : $('#newRecipeDishCategory').hide();
  });
}