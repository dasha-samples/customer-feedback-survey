import "commonReactions/all.dsl";

context 
{
    input phone: string;
    input name: string?=null; 

    q1_rate: string = "";
    q1_number: number?=null;
    q2_rate: string = "";
    q3_rate: string = "";
    q1_feeback: string = "";
    q2_feedback: string = "";
    q3_feedback: string = "";
    open_feedback: string = "";
    call_back: string = "";

}

external function check_rating(rate: string): boolean;

start node root 
{
    do 
    {
        #connectSafe($phone);
        #waitForSpeech(500);
        #say("greeting", {name: $name} );
        wait *;
    }   
    transitions
    {
        question_1: goto question_1 on #messageHasIntent("yes");
        all_back: goto call_back on #messageHasIntent("no");
    }
}


node when_call_back
{
    do
    {
        #say("when_callback");
        wait *;
    }
    transitions
    {
       call_back: goto call_back;
    } 
    onexit
    {
        call_back: do 
        {
            set $call_back = #getMessageText();
            // external call_back($call_back);
        }
    }
} 


node call_back
{
    do
    {
        #say("i_will_call_back");
        exit;
    }
}

node question_1
{
    do 
    {
        #say("question_1");
        wait *;
    }
    transitions 
    {
        q1Evaluate: goto q1Evaluate on #messageHasData("rating");
    }
}

node q1Evaluate 
{
    do
    {
        set $q1_rate =  #messageGetData("rating")[0]?.value??"";
        var is_good_rating = external check_rating($q1_rate);
        if (is_good_rating)
        {
            goto question_2;
        }
        else
        {
            goto question_1_n;
        }
    }
    transitions
    {
        question_2: goto question_2;
        question_1_n: goto question_1_n;
    }

}

node question_1_n
{
    do 
    {
        #say("question_1_n");
        wait *;
    }
    transitions
    {
        question_1_a: goto question_1_n on #messageHasData("rating");
        question_2: goto question_2 on #messageHasData("rating");
    }
    onexit 
        {
           
           
        }
}

node question_2
{
    do 
    {
        #say("question_2_n");
        wait *;
    }
 /**   transitions
    {
        question_2_n: goto question_2_n on #messageHasData("rating" >= 3);
        question_3: goto question_2 on #messageHasData("rating");
    }
    onexit 
        {
            question_2_n: do 
            { 
                set q2_rate =  #messageGetData("rating", { value: true })[0]?.value??"";
            }
        } */
}
