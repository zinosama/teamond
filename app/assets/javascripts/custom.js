$(document).ready(function(){
  if(($('.ui.error.message').length > 0 || $('.ui.warning.message').length > 0) && $('div.ui.message.column').length > 0){
    $('#checkoutButton').addClass('disabled');
  };

  $('div.ui.label.browse').popup({
    on : 'hover'
  });

  $('#showCategories').on('click', function(e){
    $('#categoryListing').slideToggle(function(){
      $('.categoryButton').toggle();
    });
  });

  $('#showAddon').on('click', function(e){
    $('#addonListing').slideToggle(function(){
      $('.addonButton').toggle();
    });
  });

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
  toggleStoreSelectDisplay();
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

  if($('select[name="order[payment_method]"]').length && $('select[name="order[payment_method]"]')[0].value === 'online'){
    $('#placeOrderButton').hide();
    $('#payOnlineButton').show();
  }else if($('select[name="order[payment_method]"]').length && $('select[name="order[payment_method]"]')[0].value === 'cash'){
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
    if(this.value === 'online'){
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
    $('input:checked.milkteaSize')[0].value === "regular_size" ? updateMilkteaTotal(-1) : updateMilkteaTotal(1);
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

var toggleStoreSelectDisplay = function() {
  var roleTypeSelectField = $('#user_role_type');
  roleTypeSelectField.change(function() {
    this.value == 'Provider' ? $('#newStore').show() : $('#newStore').hide();
  });
};