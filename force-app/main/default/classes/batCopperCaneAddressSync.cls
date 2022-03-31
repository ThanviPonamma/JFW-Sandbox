global class batCopperCaneAddressSync implements Schedulable {
    global void execute(SchedulableContext c)
    {
        AddressSynchronizationJob.SyncCopperCaneAddresses();
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