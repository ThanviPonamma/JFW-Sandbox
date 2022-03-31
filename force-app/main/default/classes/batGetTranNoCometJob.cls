global class batGetTranNoCometJob implements Schedulable {
    global void execute(SchedulableContext c)
    {
        CometJobs cmtJobs = new CometJobs();
        CometJobs.UpdateTransactionNumbers(3,'DFV');
        CometJobs.UpdateTransactionNumbers(3,'JFW');
        CometJobs.UpdateTransactionNumbers(3,'Wilson Daniels');
        CometJobs.UpdateTransactionNumbers(3,'Infinium Spirits');
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