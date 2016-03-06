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
  enableRecipeDelete();

  $('#recipe_image').bind('change', function() {
    var size_in_megabytes = this.files[0].size/1024/1024;
    console.log(this.files[0]);
    if (size_in_megabytes > 1) {
      alert('Maximum file size is 1MB. Please choose a smaller file.');
    }
  });
});

var enableRecipeDelete = function(){
  $('#delete_confirm').change(function(){
    this.checked ? $('#recipeDeleteButton').removeClass("disabled") : $('#recipeDeleteButton').addClass("disabled");
  });
};

var toggleDishCategorySelectDisplay = function(){
  var recipeTypeSelectField = $('#recipe_type');
  if(recipeTypeSelectField.length == 0){
    $('#newRecipeDishCategory').show();
  }

  recipeTypeSelectField.change(function(){
    this.value == 'Dish' ? $('#newRecipeDishCategory').show() : $('#newRecipeDishCategory').hide();
  });
};