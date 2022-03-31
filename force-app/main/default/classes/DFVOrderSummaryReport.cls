//Aim : To get user placed orders and its items for a particular program to the frontend actor.
public class DFVOrderSummaryReport {
    
    //To return ordered items(order destination items) for an order destination(order) 
    //for the logged in user and for the selected program. Which matches the below conditions.
        //1.Logged in user.
        //2.Selected Program
        //3.Order Status is not Open
  /**Authors: SN,TP,VB	Date:20-08-2020 CR NO: DFV-20-AUG-24
    * The below is code is commented to meet the requiremts of the CR DFV-20-AUG-24
        @AuraEnabled(cacheable=true)
    public static List<WrapperDFVOrderReport> GetOrderDestinationItems(string programId, string userId){
        if(string.isEmpty(programId)){
            return null;
        }
        else {
            
            //To hold the order destination items of an order, 
            //for a particular program and for order placed by a particular user.
            List<OrderDestinationItem__c> orderDestinationItemsList =
                                        [SELECT OrderDestination__r.ProgramName__c,
                                                POS_Item__r.Brand__r.Brand_Name__c,
                                                OrderDestination__r.OrderName__c,
                                                OrderDestination__r.User__c,
                                                POS_Item__r.Vendor__c,
                                                POS_Item__r.Type_of_Item__r.Item_Type__c,
                                                POS_Item__r.Item_No__c,
                                                POSItemName__c,
                                                POS_Item__r.Item_Descrption__c,
                                                POS_Item__r.Pack_Of__c,
                                                Quantity__c,
                                                POS_Item__r.Price__c,
                                                Total_Line_Amount__c,
                                                OrderDestination__r.ShipToName__c,
                                                OrderDestination__r.ShipToCompany__c,
                                                OrderDestination__r.AddressBook__r.Address__c,
                                                OrderDestination__r.ShipToCity__c,
                                                OrderDestination__r.AddressBook__r.StateCode__c,
                                                OrderDestination__r.AddressBook__r.Zip__c,
                                                OrderDestination__r.AddressBook__r.Phone__c,
                                                OrderDestination__r.AddressBook__r.Email__c,
                                                OrderDestination__r.OrdStatus__c,
                                                CreatedDate
                                                FROM OrderDestinationItem__c 
                                                WHERE ( (OrderDestination__r.Order__r.Program__c = :programId) AND 
                                                        (CreatedBy.Id = :userId) AND
                                                        (OrderDestination__r.OrdStatus__c != 'OPEN') AND
                                                        (Quantity__c > 0))
                                                ORDER BY  POS_Item__r.Item_No__c];
    
            system.debug('orderDestinationItemsList' + orderDestinationItemsList);
            system.debug('orderDestinationItemsList size' + orderDestinationItemsList.size());
            
            //To hold the list of order destination items as List of Object type - (WrapperDFVOrderReport)
            List<WrapperDFVOrderReport> wrapperDFVOrderReportList = new List<WrapperDFVOrderReport>();
            
            //For each order destination item create a wrapper class of type - (WrapperDFVOrderReport) 
                for(OrderDestinationItem__c  orderDestinationItem : orderDestinationItemsList){
                

					//To store the order created date of each order destination item.
                    DateTime createdDate = (Datetime)orderDestinationItem.CreatedDate; 
                    //To set the format of the created date of each order destination item as ‘MM/dd/yyyy’
					String createdDateString =  createdDate.format('MM/dd/yyyy') ;
                    system.debug('createdDateString-->' + createdDateString);                    
                    
                    wrapperDFVOrderReportList.add(new WrapperDFVOrderReport(
                        orderDestinationItem.OrderDestination__r.ProgramName__c,
                        orderDestinationItem.POS_Item__r.Brand__r.Brand_Name__c,
                        orderDestinationItem.OrderDestination__r.OrderName__c,
                        orderDestinationItem.OrderDestination__r.User__c,
                        orderDestinationItem.POS_Item__r.Vendor__c,
                        orderDestinationItem.POS_Item__r.Type_of_Item__r.Item_Type__c,
                        orderDestinationItem.POS_Item__r.Item_No__c,
                        orderDestinationItem.POSItemName__c,
                        orderDestinationItem.POS_Item__r.Item_Descrption__c,
                        Integer.valueOf(orderDestinationItem.POS_Item__r.Pack_Of__c),
                        Integer.valueOf(orderDestinationItem.Quantity__c),
                        orderDestinationItem.POS_Item__r.Price__c ,
                        orderDestinationItem.Total_Line_Amount__c ,
                        orderDestinationItem.OrderDestination__r.ShipToName__c,
                        orderDestinationItem.OrderDestination__r.ShipToCompany__c,
                        orderDestinationItem.OrderDestination__r.AddressBook__r.Address__c,
                        orderDestinationItem.OrderDestination__r.ShipToCity__c, 
                        orderDestinationItem.OrderDestination__r.AddressBook__r.StateCode__c,
                        Integer.valueOf(orderDestinationItem.OrderDestination__r.AddressBook__r.Zip__c) ,
                        String.valueOf(orderDestinationItem.OrderDestination__r.AddressBook__r.Phone__c) ,
                        orderDestinationItem.OrderDestination__r.AddressBook__r.Email__c,
                        orderDestinationItem.OrderDestination__r.OrdStatus__c,
                        createdDateString ));
                }
            
            system.debug('wrapperDFVOrderReportList' + wrapperDFVOrderReportList);
            system.debug('wrapperDFVOrderReportList size' + wrapperDFVOrderReportList.size());
            
            return wrapperDFVOrderReportList;
		}
    }
**/
	@AuraEnabled(cacheable=true)
    public static List<WrapperDFVOrderReport> GetOrderDestinationItems(string programId, string userId){
        if(string.isEmpty(programId)){
            return null;
        }
        else {
            
            //To hold the order destination items of an order, 
            //for a particular program and for order placed by a particular user.
            List<OrderDestinationItem__c> orderDestinationItemsList =
                                        [SELECT OrderDestination__r.ProgramName__c,
                                                POS_Item__r.Brand__r.Brand_Name__c,
                                                OrderDestination__r.OrderName__c,
                                                OrderDestination__r.User__c,
                                                POS_Item__r.Vendor__c,
                                                POS_Item__r.Type_of_Item__r.Item_Type__c,
                                                POS_Item__r.Item_No__c,
                                                POSItemName__c,
                                                POS_Item__r.Item_Descrption__c,
                                                POS_Item__r.Pack_Of__c,
                                                Quantity__c,
                                                POS_Item__r.Price__c,
                                                Total_Line_Amount__c,
                                                OrderDestination__r.ShipToName__c,
                                                OrderDestination__r.ShipToCompany__c,
                                                OrderDestination__r.AddressBook__r.Address__c,
                                                OrderDestination__r.ShipToCity__c,
                                                OrderDestination__r.AddressBook__r.StateCode__c,
                                                OrderDestination__r.AddressBook__r.Zip__c,
                                                OrderDestination__r.AddressBook__r.Phone__c,
                                                OrderDestination__r.AddressBook__r.Email__c,
                                                OrderDestination__r.OrdStatus__c,
                                                OrderDestination__r.TrackingNos__c,
                                                CreatedDate, LastModifiedDate
                                                FROM OrderDestinationItem__c 
                                                WHERE ( (OrderDestination__r.Order__r.Program__c = :programId) AND 
                                                        (CreatedBy.Id = :userId) AND
                                                        (OrderDestination__r.OrdStatus__c != 'OPEN') AND
                                                        (Quantity__c > 0))
                                                ORDER BY OrderDestination__r.OrderName__c];
    
            system.debug('orderDestinationItemsList' + orderDestinationItemsList);
            system.debug('orderDestinationItemsList size' + orderDestinationItemsList.size());
            
            //To hold the list of order destination items as List of Object type - (WrapperDFVOrderReport)
            List<WrapperDFVOrderReport> wrapperDFVOrderReportList = new List<WrapperDFVOrderReport>();
            
            //For each order destination item create a wrapper class of type - (WrapperDFVOrderReport) 
                for(OrderDestinationItem__c  orderDestinationItem : orderDestinationItemsList){
                

					//To store the order created date of each order destination item.
                    DateTime createdDate = (Datetime)orderDestinationItem.CreatedDate; 
                    //To set the format of the created date of each order destination item as ‘MM/dd/yyyy’
					String createdDateString =  createdDate.format('MM/dd/yyyy') ;
                    system.debug('createdDateString-->' + createdDateString);    
                    DateTime lastModifiedDate = (Datetime)orderDestinationItem.LastModifiedDate; 
                    String lastModifiedDateString = lastModifiedDate.format('MM/dd/yyyy') ;            
                    
                    wrapperDFVOrderReportList.add(new WrapperDFVOrderReport(
                        orderDestinationItem.OrderDestination__r.ProgramName__c,
                        orderDestinationItem.POS_Item__r.Brand__r.Brand_Name__c,
                        orderDestinationItem.OrderDestination__r.OrderName__c,
                        orderDestinationItem.OrderDestination__r.User__c,
                        orderDestinationItem.POS_Item__r.Vendor__c,
                        orderDestinationItem.POS_Item__r.Type_of_Item__r.Item_Type__c,
                        orderDestinationItem.POS_Item__r.Item_No__c,
                        orderDestinationItem.POSItemName__c,
                        orderDestinationItem.POS_Item__r.Item_Descrption__c,
                        Integer.valueOf(orderDestinationItem.POS_Item__r.Pack_Of__c),
                        Integer.valueOf(orderDestinationItem.Quantity__c),
                        orderDestinationItem.POS_Item__r.Price__c ,
                        orderDestinationItem.Total_Line_Amount__c ,
                        orderDestinationItem.OrderDestination__r.ShipToName__c,
                        orderDestinationItem.OrderDestination__r.ShipToCompany__c,
                        orderDestinationItem.OrderDestination__r.AddressBook__r.Address__c,
                        orderDestinationItem.OrderDestination__r.ShipToCity__c, 
                        orderDestinationItem.OrderDestination__r.AddressBook__r.StateCode__c,
                        //Authors: SN,TP,VB	Date:20-08-2020 CR NO: DFV-20-AUG-24
                        //the below line is commeted to accepted the Zip code in string format as the zip code can contain special character('-')
                        //Integer.valueOf(orderDestinationItem.OrderDestination__r.AddressBook__r.Zip__c) ,
                        orderDestinationItem.OrderDestination__r.AddressBook__r.Zip__c,
                        String.valueOf(orderDestinationItem.OrderDestination__r.AddressBook__r.Phone__c) ,
                        orderDestinationItem.OrderDestination__r.AddressBook__r.Email__c,
                        orderDestinationItem.OrderDestination__r.OrdStatus__c,
                        createdDateString,
                        lastModifiedDateString,orderDestinationItem.OrderDestination__r.TrackingNos__c
                        ));
                }
            
            system.debug('wrapperDFVOrderReportList' + wrapperDFVOrderReportList);
            system.debug('wrapperDFVOrderReportList size' + wrapperDFVOrderReportList.size());
            
            return wrapperDFVOrderReportList;
		}
    }
}