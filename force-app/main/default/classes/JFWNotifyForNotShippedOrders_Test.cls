@isTest
private class JFWNotifyForNotShippedOrders_Test
{
    @isTest(SeeAllData=true)
    private static void constructorTest ()
    {
        Test.startTest();
        system.schedule('test job1','0 42 11 * * ? *',new JFWNotifyForNotShippedOrders_Scheduler ());
        system.schedule('test job2','0 42 11 * * ? *',new JFWNotifyOverNightNotShipped_Scheduler ());
        Test.stopTest();
    }
}