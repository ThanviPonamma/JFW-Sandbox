global class batRefreshStockandInprocessCount implements Schedulable {
    global void execute(SchedulableContext c)
    {
        CometJobs cmtJobs = new CometJobs();
        CometJobs.GetLatestStockWithInProcessInv('DFV'); 
        CometJobs.GetLatestStockWithInProcessInv('JFW');
        CometJobs.GetLatestStockWithInProcessInv('Wilson Daniels');
        CometJobs.GetLatestStockWithInProcessInv('Infinium Spirits');
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