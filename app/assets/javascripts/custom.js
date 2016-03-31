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

  $('.ui.rating').rating('setting', 'onRate', function(value) {
    $('#order_satisfaction').val(value);
  });


  toggleDishCategorySelectDisplay();
  enableRecipeDelete();

  $('#recipe_image').bind('change', function() {
    var size_in_megabytes = this.files[0].size/1024/1024;
    console.log(this.files[0]);
    if (size_in_megabytes > 1) {
      alert('Maximum file size is 1MB. Please choose a smaller file.');
    }

  });
  

  watchMilkteaAddons();
  watchMilkteaSizes();

  if($('select[name="order[payment_method]"]').length && $('select[name="order[payment_method]"]')[0].value === '0'){
    $('#placeOrderButton').hide();
    $('#payOnlineButton').show();
  }else if($('select[name="order[payment_method]"]').length && $('select[name="order[payment_method]"]')[0].value === '1'){
    $('#payOnlineButton').hide();
    $('#placeOrderButton').show();
  }

  toggleOnlinePaymentForm();
  watchPlaceOrderButton();
});


var watchPlaceOrderButton = function(){
  $('#placeOrderButton').click(function(){
    $('iframe')[0].remove();
    $('#placeOrderForm').submit();
  });
};

var toggleOnlinePaymentForm = function(){
  $('select[name="order[payment_method]"]').change(function(){
    if(this.value === '0'){
      $('#placeOrderButton').hide();
      $('#payOnlineButton').show();
    }else{
      $('#payOnlineButton').hide();
      $('#placeOrderButton').show();
    }
  });
};

var watchMilkteaSizes = function(){
  $(".milkteaSize").change(function(){
    $('input:checked.milkteaSize')[0].value === "0" ? updateMilkteaTotal(-1) : updateMilkteaTotal(1);
  });
};

var watchMilkteaAddons = function(){
  $('.addonSelect.dropdown').dropdown({
    onAdd: function(){ updateMilkteaTotal(0.5);},
    onRemove: function(){ updateMilkteaTotal(-0.5); }
  });
};

var updateMilkteaTotal = function(difference){
  var newPrice = parseFloat($('#milkteaOrderableRuningTotal').text(), 10) + difference;
  $('#milkteaOrderableRuningTotal').text(newPrice.toFixed(2));
};

var enableRecipeDelete = function(){
  $('#delete_confirm').change(function(){
    this.checked ? $('.deleteButton').removeClass("disabled") : $('.deleteButton').addClass("disabled");
  });
};

var toggleDishCategorySelectDisplay = function(){
  var recipeTypeSelectField = $('#recipe_type');
  recipeTypeSelectField.change(function(){
    this.value == 'Dish' ? $('#newRecipeDishCategory').show() : $('#newRecipeDishCategory').hide();
  });
};