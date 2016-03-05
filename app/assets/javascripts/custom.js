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

  $('#recipe_image').bind('change', function() {
    var size_in_megabytes = this.files[0].size/1024/1024;
    console.log(this.files[0]);
    if (size_in_megabytes > 1) {
      alert('Maximum file size is 1MB. Please choose a smaller file.');
    }
  });
});

var toggleDishCategorySelectDisplay = function(){
  $('#recipe_type').change(function(){
    this.value == 'dish' ? $('#newRecipeDishCategory').show() : $('#newRecipeDishCategory').hide();
  });
}