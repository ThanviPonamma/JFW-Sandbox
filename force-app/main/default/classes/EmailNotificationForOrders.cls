//Authors: NK, SN, TP, VB ; Date: 06/07/2020
//Aim of the class : To send email notifications to the user on successful submission of the wave order and 
//on failure to submit a wave order to the warehouse

public class EmailNotificationForOrders
{

//Authors: NK, SN, TP, VB ; Date: 06/07/2020
//Aim of the method: this method is used to send a notification for Successfully submitted wave orders to comet.
    public static void sendNotificationForSubmittedWaveOrders(List<String> waveOrderTransactionNumbersList)
    {
        //Declare a variable cometOrderItems of type List holding the elements of sObject OrderDestinationItem__c
        List<OrderDestinationItem__c> cometOrderItems=[SELECT Id,OrderDestination__r.Order__r.Owner.Email,
                                                       OrderDestination__r.Order__r.Owner.Name,OrderDestination__r.Order__r.Account__r.Name,
                                                       POS_Item__r.Item_Name__c,
                                                       POS_Item__r.Brand__r.Brand_Name__c,
                                                       Quantity__c,POS_Item__r.Pack_Of__c,
                                                       Wave_Order_Number__c,OrderDestination__r.AddressBook__r.Shipto_Name__c,
                                                       Warehouse_Transaction_Number__c,OrderDestination__r.AddressBook__r.Shipto_Company__c,
                                                       OrderDestination__r.AddressBook__r.City__c,
                                                       OrderDestination__r.Order__r.Account__r.Comet_API_Key__c 
                                                       FROM OrderDestinationItem__c 
                                                       WHERE Warehouse_Transaction_Number__c IN : waveOrderTransactionNumbersList 
                                                       AND OrderDestination__r.Order__r.Account__r.Comet_API_Key__c != NULL 
                                                       AND Wave_Order_Number__c!=NULL];
        
        //Declare a variable waveOrderTransactionNoWithOrderedItems of type Map holding the String and List of elements of sObject OrderDestinationItem__c
        Map<String,List<OrderDestinationItem__c>> waveOrderTransactionNoWithOrderedItems=new Map<String,List<OrderDestinationItem__c>> ();
        
        //Declare a variable organisationEmailAddresses of type List holding the elements of object OrgWideEmailAddress and 
        //Fetch Id from OrgWideEmailAddress where DisplayName is 'Emerge Help Desk' and store it in the variable organisationEmailAddresses
        List<OrgWideEmailAddress> organisationEmailAddresses=[SELECT Id 
                                                              FROM OrgWideEmailAddress 
                                                              WHERE DisplayName='Emerge Help Desk'];
        
        //For all the cometOrderItems held in the variable cometOrderItem of type OrderDestinationItem__c , 
        for(OrderDestinationItem__c cometOrderItem : cometOrderItems)
        {
            //check if waveOrderTransactionNoWithOrderedItems doesnot contain  Warehouse_Transaction_Number__c of OrderDestinationItem__c . If so,
            if(!waveOrderTransactionNoWithOrderedItems.containsKey(cometOrderItem.Warehouse_Transaction_Number__c))
            {
                //Load Warehouse_Transaction_Number__c  with the list of cometOrderItem of type List<OrderDestinationItem__c> to the variable waveOrderTransactionNoWithOrderedItems
                waveOrderTransactionNoWithOrderedItems.put(cometOrderItem.Warehouse_Transaction_Number__c,new List<OrderDestinationItem__c> {cometOrderItem});
            }
            else
            {
                //Declare a variable addedCometOrderItems of type List holding the elements of sObject OrderDestinationItem__c
                List<OrderDestinationItem__c> addedCometOrderItems=waveOrderTransactionNoWithOrderedItems.get(cometOrderItem.Warehouse_Transaction_Number__c);
                
                //Check if addedCometOrderItems is null. If so,
                if(addedCometOrderItems==null)
                    //Create an instance of addedCometOrderItems 
                    addedCometOrderItems=new List<OrderDestinationItem__c> ();
                //Else, add cometOrderItem to the variable addedCometOrderItems 
                addedCometOrderItems.add(cometOrderItem);
                
                //add the Warehouse_Transaction_Number__c in the cometOrderItem and addedCometOrderItems to the variable 
                //waveOrderTransactionNoWithOrderedItems
                waveOrderTransactionNoWithOrderedItems.put(cometOrderItem.Warehouse_Transaction_Number__c,addedCometOrderItems);
            }
        }
        
        //Declare a variable emailList of type List holding the elements of apex method Messaging.SingleEmailMessage
        List<Messaging.SingleEmailMessage> emailList=new List<Messaging.SingleEmailMessage> ();
        
        //For all the order destination items in waveOrderTransactionNoWithOrderedItems held by the 
        //variable warehouseTransactionNumber of type String
        for(String warehouseTransactionNumber : waveOrderTransactionNoWithOrderedItems.keySet())
        {
            //Declare a variable singleEmail of type Messaging.SingleEmailMessage 
            Messaging.SingleEmailMessage singleEmail=new Messaging.SingleEmailMessage ();
            //Declare a variable commonEmailsList of type Set holding the elements of type string 
            Set<String> toAddressList;
            //Declare a variable developerEmailsList of type Set holding the elements of type string 
            Set<String> ccAddressList; 
            //Declare a variable HTMLbody of type String
            String HTMLbody='';
            //Set a subject to singleEmail using setSubject as "Order Submitted successfully to the Warehouse"
            singleEmail.setSubject('Order Submitted successfully to the Warehouse');
            //check if organisationEmailAddresses is not empty
            if(!organisationEmailAddresses.isEmpty())
                //Set email address Id to singleEmail using setOrgWideEmailAddressId
                singleEmail.setOrgWideEmailAddressId(organisationEmailAddresses[0].Id);
          
            HTMLbody='<!DOCTYPE html> <html> <head> <title>Page Title</title> <style>  </style> </head> <body>  <div >      <center>';
            
            //Add Html body with Page title. The page title being Wave_Order_Number__c
            HTMLbody+='<h3>Order Details Of '+waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber)[0].Wave_Order_Number__c;
            
            //Add a greeting to the user with user name telling "Your seasonal order has been submitted successfully to the warehouse" 
            //and "The details are mentioned below."
            HTMLbody+='</center><div><font face="arial" size="2"><p>Hi '+waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.Order__r.Owner.Name+',</p><p>Your '+(waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.Order__r.Account__r.Name.contains('DFV')?'Seasonal ':(waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.Order__r.Account__r.Name.contains('Mionetto')?'Program ':''))+'Order has been submitted successfully to the Warehouse. <br><br>The details are mentioned below.</p><h4>Order No : ';
            
            //Add wave order number, ship to name, ship to company , city and warehouse order number to the HTMLBody
            HTMLbody+=waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber)[0].Wave_Order_Number__c+'<br>';
            HTMLbody+='Ship To Name : '+waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.AddressBook__r.Shipto_Name__c+'<br>';
            HTMLbody+='Ship To Company : '+waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.AddressBook__r.Shipto_Company__c+'<br>';
            HTMLbody+='City : '+waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.AddressBook__r.City__c+'<br>';
            HTMLbody+='Warehouse Order Number : '+warehouseTransactionNumber+'<br>';
            HTMLbody+='</h4><br><p>POS Items are :</p><table style="width:100%;" border="1"><tbody><tr><th width="120">Item Name</th><th width="100">Brand</th><th>Ordered Qty</th><th>Pack Of</th></tr>';
            
            //For all the waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber) held by the variable cometOrderItem of type OrderDestinationItem__c 
            for(OrderDestinationItem__c cometOrderItem : waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber))
            {
                HTMLbody+='<tr style="text-align:center;">';
                //Add PosItem name to HTMLBody
                HTMLbody+='<td style="width:25%;">'+cometOrderItem.POS_Item__r.Item_Name__c+'</td>';
                //Add PosItem brandto HTMLBody
                HTMLbody+='<td style="width:25%;">'+cometOrderItem.POS_Item__r.Brand__r.Brand_Name__c+'</td>';
                //Add PosItem Ordered quantity to HTMLBody
                HTMLbody+='<td style="width:25%;">'+cometOrderItem.Quantity__c+'</td>';
                //Add PosItem pack of to HTMLBody
                HTMLbody+='<td style="width:25%;">'+cometOrderItem.POS_Item__r.Pack_Of__c+'</td> </tr>';
            }
            HTMLbody+='</tbody></table></font></div>';
            
            //Check if there is a record called "DFVSubmitted Order" in the custom setting Email_Notification__c
            if(Email_Notification__c.getInstance('DFV Submitted Order')!=null)
            {
                //Check if the account name of the instance "DFVSubmitted Order" matches with the incoming order destination's account name 
                if(Email_Notification__c.getInstance('DFV Submitted Order').Account_Name__c == waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.Order__r.Account__r.Name)
                {
                    toAddressList=new Set<String> ();
                    ccAddressList=new Set<String> (); 
                    
                    //Add a hyper link to HTMLBody  saying "For more information login to the Emerge application" with the target being Safe_Redirect_URL__c
                    HTMLbody+='<p><span ><a href="'+Email_Notification__c.getInstance('DFV Submitted Order').Footer_HTML_URL__c+'" target="_blank" data-saferedirecturl="'+Email_Notification__c.getInstance('DFV Submitted Order').Safe_Redirect_URL__c+'">For more information login to the Emerge application</a></span></p><p>Thank you very much !<br><br>Emerge System Administrator</p></div></body></html>';
                    //Set HTMLBody using setHtmlBody to singleEmail
                    singleEmail.setHtmlBody(HTMLbody);
                    
                    //Check if To_Addresses_List__c under the instance "DFV Submitted Order" is not null
                    if(String.isNotBlank(Email_Notification__c.getInstance('DFV Submitted Order').To_Addresses_List__c))
                    {
                        //Add all the values under To_Addresses_List__c of the instance " DFV Submitted Order " to a variable toAddressList of type String
                        for(String toAddress: Email_Notification__c.getInstance('DFV Submitted Order').To_Addresses_List__c.split(','))
                            toAddressList.add(toAddress.trim());     
                    }    
                    //Check if the Active_For_Record_User__c is true under the instance "DFV Submitted Order"
                    if(Email_Notification__c.getInstance('DFV Submitted Order').Active_For_Record_User__c) 
                        //Add the incoming order destination's owner name to the variable toAddressList 
                        toAddressList.add(waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.Order__r.Owner.Email);
                    //Check if the Cc_Addresses_List__c is not null under the instance "DFV Submitted Order"
                    if(String.isNotBlank(Email_Notification__c.getInstance('DFV Submitted Order').Cc_Addresses_List__c))
                    {
                        //Add all the values under Cc_Addresses_List__c of the instance " DFV Submitted Order " to a variable ccAddressList of type String
                        for(String ccAddress : Email_Notification__c.getInstance('DFV Submitted Order').Cc_Addresses_List__c.split(','))
                            ccAddressList.add(ccAddress.trim());
                    }
                    //Set toAddressList to singleEmail using setToAddresses
                    singleEmail.setToAddresses(new List<String> (toAddressList));
                    //Set ccAddressList to singleEmail using setCcAddresses
                    singleEmail.setCcAddresses(new List<String> (ccAddressList));
                    //Add singleEmail to the variable emailList if Active__c under "DFV Submitted Order" is true and ccAddressList  is not empty
                    if(Email_Notification__c.getInstance('DFV Submitted Order').Active__c && !toAddressList.isEmpty())    
                        
                        emailList.add(singleEmail);
                }
            }  
                       
        }
        //Check if emailList is not empty. If emailList is not empty,
        if(!emailList.isEmpty())
        {
            //Send the emailList using Messaging.sendEmail or an error message using exception handling
            try
            {
                Messaging.sendEmail(emailList);
            }catch(exception ex)
            {
                System.debug('email error is ---> '+ex.getMessage());
            }
        }
    }  
      
   
    //Authors: NK, SN, TP, VB ; Date: 06/07/2020
    //Aim of this method : this method is used to send a notification for failed waveorders to customers.  
    public static void sendNotificationForFailedToSubmitWaveOrders (List<String> waveOrderNumbersList)
    {
        //Declare a variable cometOrderItems of type List holding the elements of sObject OrderDestinationItem__c
        List<OrderDestinationItem__c> cometOrderItems=[SELECT Id,Comet_Response__c,Tracking_Numbers__c,Carrier__c,OrderDestination__r.Order__r.Owner.Email,OrderDestination__r.Order__r.Owner.Name,OrderDestination__r.Order__r.Account__r.Name,POS_Item__r.Item_Name__c,POS_Item__r.Brand__r.Brand_Name__c,Quantity__c,POS_Item__r.Pack_Of__c,Wave_Order_Number__c,OrderDestination__r.AddressBook__r.Shipto_Name__c,Warehouse_Transaction_Number__c,OrderDestination__r.AddressBook__r.Shipto_Company__c,OrderDestination__r.AddressBook__r.City__c,OrderDestination__r.Order__r.Account__r.Comet_API_Key__c FROM OrderDestinationItem__c WHERE Wave_Order_Number__c IN : waveOrderNumbersList AND OrderDestination__r.Order__r.Account__r.Comet_API_Key__c != NULL AND Warehouse_Transaction_Number__c=NULL AND Order_Destination_Item_Status__c LIKE '%FAIL%'];
        
        //Declare a variable waveOrderNoWithOrderedItems of type Map holding the String and List of elements of sObject OrderDestinationItem__c
        Map<String,List<OrderDestinationItem__c>> waveOrderNoWithOrderedItems=new Map<String,List<OrderDestinationItem__c>> ();
        
        //Declare a variable organisationEmailAddresses of type List holding the elements of object OrgWideEmailAddress
        List<OrgWideEmailAddress> organisationEmailAddresses=[SELECT Id FROM OrgWideEmailAddress WHERE DisplayName='Emerge Help Desk'];
        
        //For all the cometOrderItems held in the variable cometOrderItem of type OrderDestinationItem__c , 
        for(OrderDestinationItem__c cometOrderItem : cometOrderItems)
        {
            //check if waveOrderNoWithOrderedItems doesnot contain  Wave_Order_Number__c of OrderDestinationItem__c . If so,
            if(!waveOrderNoWithOrderedItems.containsKey(cometOrderItem.Wave_Order_Number__c ))
            {
                //Add Wave_Order_Number__c and order destination items to the variable waveOrderNoWithOrderedItems
                waveOrderNoWithOrderedItems.put(cometOrderItem.Wave_Order_Number__c ,new List<OrderDestinationItem__c> {cometOrderItem});
            }
            else
            {
                //Else, get the Wave_Order_Number__c from the comet order item and store it in  variable addedCometOrderItems
                List<OrderDestinationItem__c> addedCometOrderItems=waveOrderNoWithOrderedItems.get(cometOrderItem.Wave_Order_Number__c );
                //Check if addedCometOrderItems is null. If so,
                if(addedCometOrderItems==null)
                    //Create an instance of addedCometOrderItems 
                    addedCometOrderItems=new List<OrderDestinationItem__c> ();
                	//Else, add cometOrderItem to the variable addedCometOrderItems 
                    addedCometOrderItems.add(cometOrderItem);
                	//Add Wave_Order_Number__c and addedCometOrderItems to the variable waveOrderNoWithOrderedItems
                    waveOrderNoWithOrderedItems.put(cometOrderItem.Wave_Order_Number__c ,addedCometOrderItems);
            }
        }
        //Declare a variable emailList of type List holding the elements of apex method Messaging.SingleEmailMessage
        List<Messaging.SingleEmailMessage> emailList=new List<Messaging.SingleEmailMessage> ();
        //For all the order destination items in waveOrderTransactionNoWithOrderedItems held by the variable warehouseTransactionNumber of type String
        for(String warehouseTransactionNumber : waveOrderNoWithOrderedItems.keySet())
        {
            //Declare a variable singleEmail of type Messaging.SingleEmailMessage 
            Messaging.SingleEmailMessage singleEmail=new Messaging.SingleEmailMessage ();
            Set<String> ccAddressList;
            Set<String> toAddressList; 
            //Declare a variable HTMLbody of type String
            String HTMLbody='';
            //Set a subject to singleEmail using setSubject as "Order failed to submit to Warehouse"
            singleEmail.setSubject('Order failed to submit to Warehouse');
            //If organisationEmailAddresses is not empty
            if(!organisationEmailAddresses.isEmpty())
                //Set email address Id to singleEmail using setOrgWideEmailAddressId
                singleEmail.setOrgWideEmailAddressId(organisationEmailAddresses[0].Id);
            HTMLbody='<!DOCTYPE html> <html> <head> <title>Page Title</title> <style>  </style> </head> <body>  <div >      <center>';
            //Add Html body with Page title. The page title being Wave_Order_Number__c
            HTMLbody+='<h3>Order Details Of '+waveOrderNoWithOrderedItems.get(warehouseTransactionNumber)[0].Wave_Order_Number__c;
            //Add a greeting to the user with user name telling "Your seasonal order has failed to submit to the Warehouse." and 
            //"The details are mentioned below."
            HTMLbody+='</center><div><font face="arial" size="2"><p>Hi '+waveOrderNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.Order__r.Owner.Name+',</p><p>Your '+(waveOrderNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.Order__r.Account__r.Name.contains('DFV')?'Seasonal ':(waveOrderNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.Order__r.Account__r.Name.contains('Mionetto')?'Program ':''))+'Order failed to submit to the Warehouse. <br><br>The details are mentioned below.</p><h4>Order No : ';
            //Add wave order number, ship to name, ship to company , city and reason to the HTMLBody
            HTMLbody+=waveOrderNoWithOrderedItems.get(warehouseTransactionNumber)[0].Wave_Order_Number__c+'<br>';
            HTMLbody+='Ship To Name : '+waveOrderNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.AddressBook__r.Shipto_Name__c+'<br>';
            HTMLbody+='Ship To Company : '+waveOrderNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.AddressBook__r.Shipto_Company__c+'<br>';
            HTMLbody+='City : '+waveOrderNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.AddressBook__r.City__c+'<br>';
            HTMLbody+='Reason : '+waveOrderNoWithOrderedItems.get(warehouseTransactionNumber)[0].Comet_Response__c;
            HTMLbody+='</h4><br><p>POS Items are :</p><table style="width:100%;" border="1"><tbody><tr><th width="120">Item Name</th><th width="100">Brand</th><th>Ordered Qty</th><th>Pack Of</th></tr>';
            //For all the waveOrderTransactionNoWithOrderedItems.get(warehouseTransactionNumber) held by the variable cometOrderItem of type OrderDestinationItem__c 
            for(OrderDestinationItem__c cometOrderItem : waveOrderNoWithOrderedItems.get(warehouseTransactionNumber))
            {
                HTMLbody+='<tr style="text-align:center;">';
                //Add PosItem name to HTMLBody
                HTMLbody+='<td style="width:25%;">'+cometOrderItem.POS_Item__r.Item_Name__c+'</td>';
                //Add PosItem brand HTMLBody
                HTMLbody+='<td style="width:25%;">'+cometOrderItem.POS_Item__r.Brand__r.Brand_Name__c+'</td>';
                //Add PosItem Ordered quantity to HTMLBody
                HTMLbody+='<td style="width:25%;">'+cometOrderItem.Quantity__c+'</td>';
                //Add PosItem pack of to HTMLBody
                HTMLbody+='<td style="width:25%;">'+cometOrderItem.POS_Item__r.Pack_Of__c+'</td> </tr>';
            }
            HTMLbody+='</tbody></table></font></div>';
            
            //Check if there is a record called "DFVSubmitted Order" in the custom setting Email_Notification__c
            if(Email_Notification__c.getInstance('DFV Failed Order')!=null)
            {
                //Check if the account name of the instance "DFVSubmitted Order" matches with the incoming order destination's account name 
                if(Email_Notification__c.getInstance('DFV Failed Order').Account_Name__c == waveOrderNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.Order__r.Account__r.Name)
                {
                    ccAddressList=new Set<String> ();
                    toAddressList=new Set<String> ();
                    //Add a hyper link to HTMLBody  saying "For more information login to the Emerge application" with the target being Safe_Redirect_URL__c
                    HTMLbody+='<p><span ><a href="'+Email_Notification__c.getInstance('DFV Failed Order').Footer_HTML_URL__c+'" target="_blank" data-saferedirecturl="'+Email_Notification__c.getInstance('DFV Failed Order').Safe_Redirect_URL__c+'">For more information login to the Emerge application</a></span></p><p>Thank you very much !<br><br>Emerge System Administrator</p></div></body></html>';
                    //Set HTMLBody using setHtmlBody to singleEmail
                    singleEmail.setHtmlBody(HTMLbody);
                    //Check if To_Addresses_List__c under the instance "DFV Failed Order" is not null 
                    if(String.isNotBlank(Email_Notification__c.getInstance('DFV Failed Order').To_Addresses_List__c))
                    {
                        //Add all the values under To_Addresses_List__c of the instance " DFV Failed Order" to a variable toAddressList of type String
                        for(String toAddress: Email_Notification__c.getInstance('DFV Failed Order').To_Addresses_List__c.split(','))
                            
                            toAddressList.add(toAddress.trim());     
                    }  
                    //Check if the Active_For_Record_User__c is true under the instance "DFV Failed Order"
                    if(Email_Notification__c.getInstance('DFV Failed Order').Active_For_Record_User__c) 
                        //Add the incoming order destination's owner name to the variable toAddressList
                        toAddressList.add(waveOrderNoWithOrderedItems.get(warehouseTransactionNumber)[0].OrderDestination__r.Order__r.Owner.Email);
                    
                    //Check if the Cc_Addresses_List__c is not null under the instance "DFV Failed Order"
                    if(String.isNotBlank(Email_Notification__c.getInstance('DFV Failed Order').Cc_Addresses_List__c))
                    {
                        //Add all the values under Cc_Addresses_List__c of the instance " DFV Failed Order " to a variable ccAddressList of type String
                        for(String ccAddress : Email_Notification__c.getInstance('DFV Failed Order').Cc_Addresses_List__c.split(','))
                            ccAddressList.add(ccAddress.trim());
                    }
                    //Set toAddressList to singleEmail using setToAddresses
                    singleEmail.setToAddresses(new List<String> (toAddressList)); 
                    //Set ccAddressList to singleEmail using setCcAddresses
                    singleEmail.setCcAddresses(new List<String> (ccAddressList));
                    //Add singleEmail to the variable emailList if Active__c under "DFV Failed Order" is true and ccAddressList  is not empty
                    if(Email_Notification__c.getInstance('DFV Failed Order').Active__c && !toAddressList.isEmpty())    
                        emailList.add(singleEmail);
                }
            }  
             
           
        }
        //Check if emailList is not empty. If emailList is not empty,
        if(!emailList.isEmpty())
        {
            //Send the emailList using Messaging.sendEmail or an error message using exception handling
            try
            {
                Messaging.sendEmail(emailList);
            }catch(exception ex)
            {
                System.debug('email error is ---> '+ex.getMessage());
            }
        }
    }
}