//Author:Thanvi ; Date: 06/Aug/2021
//Aim : To send emil notifications
public with sharing class CopperEmailNotifications {
    public static void sendNotification (String errorPlace,String errorMessage)
    {
        List<String> emailList=new List<String> ();
        Messaging.SingleEmailMessage emailMessage=new Messaging.SingleEmailMessage ();
        emailMessage.setSubject('Error occured at '+errorPlace);
        emailMessage.setPlainTextBody(errorMessage);
        for(String email : Copper_Cane_Email_Notifications__c.getValues('CopperCane').Cc_Addresses_List__c.split(','))
        {
            emailList.add(email.trim());
        }
        emailMessage.setCcAddresses(emailList);
        if(!emailList.isEmpty())
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMessage});
    }
}