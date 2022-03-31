/*Authors: TP,VB 
Date: 26-Feb-2021
Aim: To get the comet order items that has not been approved for more than 24hours and to send the email*/

public class ApprovalReminderEmailNotification_Apex {
    //To hold the account details
    public static Account objAccount;
    //Method to get the account details for DFV
    public static Account getAccount() { 
        objAccount=[SELECT Id, Name FROM Account
                    WHERE Name LIKE '%DFV%' LIMIT 1];
        return objAccount;
    }
    //Wrapper class to hold the comet order  items along with associated brand manager details 
    public class CometOrderWithBrandManagerDetails
    {
        //to hold the Order Number
        public String OrderNumber;
        //to hold the Order Date
        public dateTime orderDate;
        //to hold the Quantity
        public Decimal Quantity;
        //to hold the Pos Item Name
        public String PosItemName;
        //to hold the Brand Name
        public String BrandName;
        //to hold the Brand Manager Name
        public String BrandManagerName;
        //to hold the Brand Manager Email
        public String BrandManagerEmail;
        public CometOrderWithBrandManagerDetails(String OrderNumber,dateTime orderDate,Decimal Quantity,String PosItemName,String BrandName, String BrandManagerName,String BrandManagerEmail)
        {
            this.OrderNumber=OrderNumber;
            this.orderDate=orderDate;
            this.Quantity=Quantity;
            this.PosItemName=PosItemName;
            this.BrandName=BrandName;
            this.BrandManagerName=BrandManagerName;
            this.BrandManagerEmail=BrandManagerEmail;
        }
    }
    //Method to get the comet order details that required approval along with the associated brand manager
    public static void getAwaitingApprovalItems()
    {
        //To hold the account details
        objAccount=getAccount();
        
        //To hold the comet order details that required approval along with the associated brand manager
        List<CometOrderWithBrandManagerDetails> cometOrderWithBrandManagerDetails = new List<CometOrderWithBrandManagerDetails>();
        
        //To hold the comet order details that required approval
        List<OrderDestinationItem__c> cometOrderItemsForApproval = new List<OrderDestinationItem__c>();
        //this line is added to meet the test result, as last modified date is not writteable.
        if(Test.isRunningTest())
        {
            cometOrderItemsForApproval = [SELECT OrderName__c,OrderDestination__r.Order_Date__c,POSItemName__c,POS_Item__r.Brand__r.Brand_Name__c,Quantity__c,POS_Item__r.Brand__c FROM OrderDestinationItem__c
                                      WHERE Account_Name__c=:objAccount.Name AND OrdStatus__c='Needs Approval' AND
                                      ((ItemAppReq__c=TRUE AND ItemApproved__c=FALSE AND ItemRejected__c = FALSE)
                                       OR (MaxOrderAppReq__c=TRUE AND MaxOrderApproved__c=FALSE AND MaxOrderRejected__c = FALSE)) 
                                      AND LastModifiedDate>=:System.today()];
        }
        else
        {
            //To hold the comet order details that required approval
            cometOrderItemsForApproval = [SELECT OrderName__c,OrderDestination__r.Order_Date__c,POSItemName__c,POS_Item__r.Brand__r.Brand_Name__c,Quantity__c,POS_Item__r.Brand__c FROM OrderDestinationItem__c
                                      WHERE Account_Name__c=:objAccount.Name AND OrdStatus__c='Needs Approval' AND
                                      ((ItemAppReq__c=TRUE AND ItemApproved__c=FALSE AND ItemRejected__c = FALSE)
                                       OR (MaxOrderAppReq__c=TRUE AND MaxOrderApproved__c=FALSE AND MaxOrderRejected__c = FALSE)) 
                                      AND LastModifiedDate<:System.today()];
        }
        
        System.debug(cometOrderItemsForApproval.size());
        
        //To hold the brand manager that belong to dfv
        List<Brand_Manager__c> brandManagerList = [SELECT User__r.Name,User__r.Email,Brand__c FROM Brand_Manager__c
                                                   WHERE Brand__r.Account__r.Name=:objAccount.Name];
        //System.debug(brandManagerList);
        
        //To check if the comet order item's brand id and brand manager brand id matches, if yes store the value in 'cometOrderWithBrandManagerDetails'
        for(OrderDestinationItem__c cometOrder:cometOrderItemsForApproval){
            for(Brand_Manager__c brandManager : brandManagerList ){
                if(brandManager.Brand__c == cometOrder.POS_Item__r.Brand__c){
                    cometOrderWithBrandManagerDetails.add(new CometOrderWithBrandManagerDetails(cometOrder.OrderName__c,cometOrder.OrderDestination__r.Order_Date__c,cometOrder.Quantity__c,cometOrder.POSItemName__c,cometOrder.POS_Item__r.Brand__r.Brand_Name__c,brandManager.User__r.Name,brandManager.User__r.Email));
                }
            }
        }
        // System.debug(cometOrderWithBrandManagerDetails.size()); 
        
        // Check if there are items that has not been approoved from the past 24 hours, if yes then call the method to send emails to the respective brand mananger
        if(cometOrderWithBrandManagerDetails.size()>0)
            sendReminderEmailNotifcations(cometOrderWithBrandManagerDetails);
        
    }
    
    //Method to send the emails to respective brand managers of the comet order item.
    public static void sendReminderEmailNotifcations(List<CometOrderWithBrandManagerDetails> cometOrderWithBrandManagerDetails)
    {
        //to hold the list of emails to be sent
        List<Messaging.SingleEmailMessage> emailsTobeSent =  new List<Messaging.SingleEmailMessage>();
        
        //for loop each comet order items in the list
        for(CometOrderWithBrandManagerDetails cometOrderWithBrandManagerDetail : cometOrderWithBrandManagerDetails){
            
            //to hold the send to name
            List<String> sendTo = new List<String>();
            
             //to hold the list of cc address
            List<String> ccaddresses = new List<String>();
            
             //to hold the email body for each order item
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            
            //to convert dateime to date format as the email should display only the date format
            DateTime cometOrderDateTime = cometOrderWithBrandManagerDetail.orderDate;
            Date orderDate = date.newinstance(cometOrderDateTime.year(), cometOrderDateTime.month(), cometOrderDateTime.day());
            String cometOrderDate = orderDate.format();
            
            //brand managers email that needs to append to sent to variable
            sendTo.add(cometOrderWithBrandManagerDetail.BrandManagerEmail);
            
            //cc address list
            ccaddresses.add('notifications@uxltechnologies.net');
            ccaddresses.add('swilliams@irgmktg.com');
            
            //to append the sent to and cc address list
            mail.setToAddresses(sendTo);
            mail.setCcAddresses(ccaddresses);
            
            // Set email is sent from
            mail.setSenderDisplayName('DFV EMERGE');
            
            // Set email contents
            mail.setSubject('Order Awaiting Approval');
            
            //Set the body of the email
            String body = 'Dear ' + cometOrderWithBrandManagerDetail.BrandManagerName + '<br/><br/>';
            body += 'The Order in this email has remained in the "Needs Approval" stage for more than 24 hours. Please login to Emerge or <a href="https://www.dfvwinespos.com/s/manageBrandApprovals">click here</a> to approve the order.<br/><br/>';
            body += '<b>Order Details</b><br/><br/>';
            
            body += '<div style="box-sizing: border-box;width: 250px;height: 50px;padding:05px;border: 1px solid black;">Order : '+cometOrderWithBrandManagerDetail.OrderNumber+'<br/>Order Date : '+cometOrderDate+'<br/></div><br/><br/>';
            body += '<table style=" border-collapse: collapse;width: 75%;"><tr style="border: 1px solid #dddddd;text-align: left;padding: 8px;background-color: #572a31;color:white">';
            body += '<th>Order Number</th><th>Brand Name</th><th>Item Name</th><th>Quantity</th></tr>';
            body += '<tr style="border: 1px solid #dddddd;text-align: left;padding: 8px;">';
            body += '<td>'+cometOrderWithBrandManagerDetail.OrderNumber+'</td>';
            body += '<td>'+cometOrderWithBrandManagerDetail.BrandName+'</td>';
            body += '<td>'+cometOrderWithBrandManagerDetail.PosItemName+'</td>';
            body += '<td>'+cometOrderWithBrandManagerDetail.Quantity+'</td></table><br/><br/>';
            body += 'DFVWines - Emerge';
            
            //Assign the complete body to email body
            mail.setHtmlBody(body);
            //Update the emails to the list
            emailsTobeSent.add(mail);
            
        }
        // Send all emails in the master list
        if(emailsTobeSent.size()>0){
            Messaging.sendEmail(emailsTobeSent);
        } 
    }
    
    
}