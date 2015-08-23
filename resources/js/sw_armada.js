$(document).ready(function(){ 

    $("div.flags").click(function() {
        if(!$(this).hasClass("active")) {
        $(".flags").removeClass("active");
        $(".flags").nextAll(".lists").hide();
        $(this).addClass("active");
        $(this).nextAll(".lists").show();
   /*     $(this).next("div").children("div").show();
     */   }
        else {
           $(this).removeClass("active");
           $(this).nextAll(".lists").hide();
       /*    $(this).next("div").children("div").hide();
         */   
        }
        });
        
        
        $("div.button").click(function() {
        $(".button").hide();
        $(this).nextAll("div").show();
        $(this).nextAll("div").children("div").show();
        });
        
        $("div.button2").click(function() {
           $(this).hide();
           $(this).next("div").hide();
           $(this).next("div").children("div").hide();
           $(".button").show();
        });
        
        $("div.ships div.img_ships").click(function(){
           if(!$(this).hasClass("active")) {
               var fact = $(this).children(".data").children(".data-faction").text();
               $(this).clone().appendTo("#Choosen_"+fact);
               $("#Choosen_"+fact).children("div.img_ships").wrap("<div class='selectedShip'></div>")
           }
           
        $("div.ChoosenShips div div.img_ships").click(function() {
            alert("Hi");
        });   
        
        });
});