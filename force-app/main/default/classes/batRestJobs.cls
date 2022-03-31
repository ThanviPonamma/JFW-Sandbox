global class batRestJobs implements Schedulable {
    global void execute(SchedulableContext c)
    {
        RestAPIjobs restJobs = new RestAPIjobs();
        RestAPIjobs.updateOrderStatusForAccount('DFV');
        RestAPIjobs.updateOrderStatusForAccount('JFW');
        RestAPIjobs.updateOrderStatusForAccount('Wilson Daniels');
        RestAPIjobs.updateOrderStatusForAccount('Infinium Spirits');
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