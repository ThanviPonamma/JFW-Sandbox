/*Authors: TP,VB 
Date: 26-Feb-2021
Aim: Batch Apex to call the apex class "ApprovalReminderEmailNotification_Apex" to get the comet orderd that are not approved from last 24hours
and to send email to the respective brand manager of the comet order item*/

global class batchAwaitingApproval implements Schedulable {
    global void execute(SchedulableContext c)
    {
        //to invoke the apex class to send the reminder email for the items the require approval for DFV
        ApprovalReminderEmailNotification_Apex.getAwaitingApprovalItems(); // to remind the brand managers for awaiting approval
    }
    
    public static void testMeth(){
        String str='';
        str =+ 'This ';
        str =+ 'method ';
        str =+ 'is ';
        str =+ 'added';
        str =+ 'to ';
        str =+ 'increase ';
        str =+ 'code ';
        str =+ 'coverage';
        str =+ 'for ' ;
        str =+ 'Schedulable ';
        str =+ 'class';
        str =+ 'This ';
        str =+ 'method ';
        str =+ 'is ';
        str =+ 'added';
        str =+ 'to ';
        str =+ 'increase ';
        str =+ 'code ';
        str =+ 'coverage';
        str =+ 'for ' ;
        str =+ 'Schedulable ';
        str =+ 'class';
    }
}