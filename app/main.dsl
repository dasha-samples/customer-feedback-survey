context 
{
    input phone: string;
    food: {[x:string]:string;}[]?=null;
}

/**
* External call declarations.
external function send_order(food: {[x:string]:string;}): string;
*/


/**
* Script.
*/

start node root 
{
    do 
    {
        #connectSafe($phone);
        #waitForSpeech(1000);
        #sayText("Hi, this is Dasha, your AI server, at Acme Burgers Main Street location. Would you like to place an order for pick-up?"	);
        wait *;
    }    
    transitions 
    {
        place_order: goto place_order on #messageHasIntent("yes");
        can_help_then: goto can_help_then on #messageHasIntent("no");
    }
}

digression place_order
{
    conditions {on #messageHasIntent("place_order");}
    do 
    {
        #sayText("Great! What can I get for you today?");
        wait *;
    }
    transitions 
    {
       confirm_food_order: goto confirm_food_order on #messageHasData("food");
    }
    onexit
    {
        confirm_food_order: do {
               set $food =  #messageGetData("food", { value: true });
       }
    }

}

node place_order
{
    do 
    {
        #sayText("Great! What can I get for you today?");
        wait *;
    }
    transitions 
    {
       confirm_food_order: goto confirm_food_order on #messageHasData("food");
    }
    onexit
    {
        confirm_food_order: do {
        set $food = #messageGetData("food");
       }
    }
}

node confirm_food_order
{
    do
    {
        #sayText("Perfect. Let me just make sure I got that right. You want ");
        var food = #messageGetData("food");
        for (var item in food)
            {
                #sayText(item.value ?? "and");
            }
        #sayText(" is that right?");
        wait *;
    }
     transitions 
    {
        order_confirmed: goto payment on #messageHasIntent("yes");
        repeat_order: goto repeat_order on #messageHasIntent("no");
    }
}

node repeat_order
{
    do 
    {
        #sayText("Let's try this again. What can I get for you today?");
        wait *;
    }
    transitions 
    {
       confirm_food_order: goto confirm_food_order on #messageHasData("food");
    }
    onexit
    {
        confirm_food_order: do {
        set $food = #messageGetData("food");
       }
    }
}

node payment
{
    do
    {
        #sayText("Great. Will you be paying at the store?");
        wait *;
    }
     transitions 
    {
        in_store: goto pay_in_store on #messageHasIntent("pay in store");
        by_card: goto by_card on #messageHasIntent("pay by card");
    }
}

node pay_in_store
{
    do
    {
        #sayText("Your order will be ready in 15 minutes. Once you’re in the store, head to the pickup counter. Anything else I can help you with? ");
        wait *;
    }
     transitions 
    {
        can_help: goto can_help on #messageHasIntent("yes");
        bye: goto success_bye on #messageHasIntent("no");
    }
}

node by_card
{
    do
    {
        #sayText("I'm sorry, I'm just a demo and can't take your credit card number. If okay, would you please pay in store. Your order will be ready in 15 minutes. Anything else I can help you with? ");
        wait *;
    }
     transitions 
    {
        can_help: goto can_help on #messageHasIntent("yes");
        bye: goto success_bye on #messageHasIntent("no");
    }
}

digression soda_on_tap 
{
    conditions {on #messageHasIntent("soda_on_tap");}
    do 
    {
        #sayText("We’ve got Dr. Pepper, Coke Zero, Raspberry Sprite and a mystery flavor. Will you be wanting a soda with your food?");
        wait *;
    }
    transitions 
    {
        place_order: goto place_order on #messageHasIntent("yes");
        can_help_then: goto can_help_then on #messageHasIntent("no");
    }
}

digression food_available 
{
    conditions {on #messageHasIntent("food_available");}
    do 
    {
        #sayText("We’ve got burgers, hot dogs, grilled cheese sandwiches, fries, milkshakes and soda pop. Would you like to order now?");
        wait *;
    }
    transitions 
    {
        place_order: goto place_order on #messageHasIntent("yes");
        can_help_then: goto can_help_then on #messageHasIntent("no");
    }
}

digression delivery 
{
    conditions {on #messageHasIntent("delivery");}
    do 
    {
        #sayText("Unfortunately we only offer pick up service through this channel at the moment. Would you like to place an order for pick up now?");
        wait *;
    }
    transitions 
    {
        place_order: goto place_order on #messageHasIntent("yes");
        can_help_then: goto no_dice_bye  on #messageHasIntent("no");
    }
}

digression connect_me 
{
    conditions {on #messageHasIntent("connect_me");}
    do 
    {
        #sayText("Certainly. Please hold, I will now transfer you. Good bye!");
        #forward("79231017918");
    }
}

node can_help_then 
{
    do
    {
        #sayText("How can I help you then?");
        wait *;
    }
}

node can_help
{
    do
    {
        #sayText("How can I help?");
        wait *;
    }
}

node success_bye 
{
    do 
    {
        #sayText("Thank you so much for your order. Have a great day. Bye!");
        #disconnect();
        exit;
    }
}

digression bye 
{
    conditions { on #messageHasIntent("bye"); }
    do 
    {
        #sayText("Thanks for your time. Have a great day. Bye!");
        #disconnect();
        exit;
    }
}

node no_dice_bye 
{
    do 
    {
        #sayText("Sorry I couldn't help you today. Have a great day. Bye!");
        #disconnect();
        exit;
    }
}