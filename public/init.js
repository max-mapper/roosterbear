$(document).ready(function() {
  $('input[type="text"]').addClass("idleField");
       $('input[type="text"]').focus(function() {
         $(this).removeClass("idleField").addClass("focusField");
        if (this.value == this.defaultValue){ 
          this.value = '';
    }
    if(this.value != this.defaultValue){
        this.select();
      }
    });
    $('input[type="text"]').blur(function() {
      $(this).removeClass("focusField").addClass("idleField");
        if ($.trim(this.value) == ''){
        this.value = (this.defaultValue ? this.defaultValue : '');
    }
    });
});