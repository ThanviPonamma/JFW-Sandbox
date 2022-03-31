public class WrapperDFVOrderReport {

    /**Authors: SN,TP,VB	Date:20-08-2020 CR NO: DFV-20-AUG-24
    * The below is code is commented to meet the requiremts of the CR DFV-20-AUG-24
    //Properties:
    @AuraEnabled
    public string ProgramName{get;set;}
    @AuraEnabled
    public string BrandName{get;set;}
    @AuraEnabled
    public string OrderName{get;set;}
    @AuraEnabled
    public string UserId{get;set;}
    @AuraEnabled
    public string Vendor{get;set;}
    @AuraEnabled
    public string ItemType{get;set;}
    @AuraEnabled
    public string ItemNo{get;set;}
    @AuraEnabled
    public string PosItemName{get;set;}
    @AuraEnabled
    public string PosItemDescrption{get;set;}
    @AuraEnabled
    public Integer PosPackOf{get;set;}
    @AuraEnabled
    public Integer Quantity{get;set;}
    @AuraEnabled
    public Decimal PosItemPrice{get;set;}
    @AuraEnabled
    public Decimal TotalLineAmount{get;set;}
    @AuraEnabled
    public string OrdDestShipToName{get;set;}
    @AuraEnabled
    public string OrdDestShipToCompany{get;set;}
    @AuraEnabled
    public string OrdDestAddress{get;set;}
    @AuraEnabled
    public string OrdDestShipToCity{get;set;}
    @AuraEnabled
    public string OrdDestStateCode{get;set;}
    @AuraEnabled
   	public Integer OrdDestZip{get;set;}
    @AuraEnabled
    public string OrdDestPhone{get;set;}
    @AuraEnabled
    public string OrdDestEmail{get;set;}
    @AuraEnabled
    public string OrdDestOrderStatus{get;set;}
    @AuraEnabled
    //Data Type is String for UI convenience
    public String CreatedDate{get;set;}
    
    
   //Contructor with parameters to create object of type - WrapperDFVOrderReport
    public WrapperDFVOrderReport(string ProgramName, string BrandName,
                                string OrderName, string UserId,
                                string Vendor, string ItemType,
                                string ItemNo, string PosItemName,
                                string PosItemDescrption, Integer PosPackOf,
                                Integer Quantity, Decimal PosItemPrice,
                                Decimal TotalLineAmount, string OrdDestShipToName,
                                string OrdDestShipToCompany, string OrdDestAddress,
                                string OrdDestShipToCity, string OrdDestStateCode,
                                Integer OrdDestZip, string OrdDestPhone,
                                string OrdDestEmail, string OrdDestOrderStatus, String CreatedDate)
    {
         this.ProgramName = ProgramName;
         this.BrandName = BrandName; 
         this.OrderName = OrderName; 
         this.UserId = UserId; 
         this.Vendor = Vendor; 
         this.ItemType = ItemType; 
         this.ItemNo = ItemNo;  
         this.PosItemName = PosItemName;
         this.PosItemDescrption = PosItemDescrption; 
         this.PosPackOf = PosPackOf; 
         this.Quantity = Quantity; 
         this.PosItemPrice = PosItemPrice;
         this.TotalLineAmount = TotalLineAmount;  
         this.OrdDestShipToName = OrdDestShipToName;  
         this.OrdDestShipToCompany = OrdDestShipToCompany;  
         this.OrdDestAddress = OrdDestAddress;  
         this.OrdDestShipToCity = OrdDestShipToCity;  
         this.OrdDestStateCode = OrdDestStateCode;  
         this.OrdDestZip = OrdDestZip;        
         this.OrdDestPhone = OrdDestPhone;  
         this.OrdDestEmail = OrdDestEmail;  
         this.OrdDestOrderStatus = OrdDestOrderStatus;  
         this.CreatedDate = CreatedDate; 
    }**/
    
    
	//Properties:
    @AuraEnabled
    public string ProgramName{get;set;}
    @AuraEnabled
    public string BrandName{get;set;}
    @AuraEnabled
    public string OrderName{get;set;}
    @AuraEnabled
    public string UserId{get;set;}
    @AuraEnabled
    public string Vendor{get;set;}
    @AuraEnabled
    public string ItemType{get;set;}
    @AuraEnabled
    public string ItemNo{get;set;}
    @AuraEnabled
    public string PosItemName{get;set;}
    @AuraEnabled
    public string PosItemDescrption{get;set;}
    @AuraEnabled
    public Integer PosPackOf{get;set;}
    @AuraEnabled
    public Integer Quantity{get;set;}
    @AuraEnabled
    public Decimal PosItemPrice{get;set;}
    @AuraEnabled
    public Decimal TotalLineAmount{get;set;}
    @AuraEnabled
    public string OrdDestShipToName{get;set;}
    @AuraEnabled
    public string OrdDestShipToCompany{get;set;}
    @AuraEnabled
    public string OrdDestAddress{get;set;}
    @AuraEnabled
    public string OrdDestShipToCity{get;set;}
    @AuraEnabled
    public string OrdDestStateCode{get;set;}
    @AuraEnabled
    //Authors: SN,TP,VB	Date:20-08-2020 CR NO: DFV-20-AUG-24
    //the below line is commeted to accepted the Zip code in string format as the zip code can contain special character('-')
    //public Integer OrdDestZip{get;set;}
    
    public string OrdDestZip{get;set;}
    
    @AuraEnabled
    public string OrdDestPhone{get;set;}
    @AuraEnabled
    public string OrdDestEmail{get;set;}
    @AuraEnabled
    public string OrdDestOrderStatus{get;set;}
    @AuraEnabled
    //Data Type is String for UI convenience
    public String CreatedDate{get;set;}
    @AuraEnabled
    public String LastModifiedDate{get;set;}
     /**The below property is added to meet the requiremets of Talking Rain 
     * Requested by : Shawna Date: 08/SEP/21    
     * Authors: Thanvi, Nachappa, Chandan*/
    @AuraEnabled
    public string TrackingNumber{get;set;}
    
   //Contructor with parameters to create object of type - WrapperDFVOrderReport
    public WrapperDFVOrderReport(string ProgramName, string BrandName,
                                string OrderName, string UserId,
                                string Vendor, string ItemType,
                                string ItemNo, string PosItemName,
                                string PosItemDescrption, Integer PosPackOf,
                                Integer Quantity, Decimal PosItemPrice,
                                Decimal TotalLineAmount, string OrdDestShipToName,
                                string OrdDestShipToCompany, string OrdDestAddress,
                                string OrdDestShipToCity, string OrdDestStateCode,
                                 //Authors: SN,TP,VB	Date:20-08-2020 CR NO: DFV-20-AUG-24
    							//the below line is commeted to accepted the Zip code in string format as 
    							//the zip code can contain special character('-')
                                // Integer OrdDestZip, 
                                string OrdDestZip,
                               	string OrdDestPhone,
                                string OrdDestEmail, string OrdDestOrderStatus, String CreatedDate,String LastModifiedDate,string TrackingNumber)
    {
         this.ProgramName = ProgramName;
         this.BrandName = BrandName; 
         this.OrderName = OrderName; 
         this.UserId = UserId; 
         this.Vendor = Vendor; 
         this.ItemType = ItemType; 
         this.ItemNo = ItemNo;  
         this.PosItemName = PosItemName;
         this.PosItemDescrption = PosItemDescrption; 
         this.PosPackOf = PosPackOf; 
         this.Quantity = Quantity; 
         this.PosItemPrice = PosItemPrice;
         this.TotalLineAmount = TotalLineAmount;  
         this.OrdDestShipToName = OrdDestShipToName;  
         this.OrdDestShipToCompany = OrdDestShipToCompany;  
         this.OrdDestAddress = OrdDestAddress;  
         this.OrdDestShipToCity = OrdDestShipToCity;  
         this.OrdDestStateCode = OrdDestStateCode;  
         this.OrdDestZip = OrdDestZip;        
         this.OrdDestPhone = OrdDestPhone;  
         this.OrdDestEmail = OrdDestEmail;  
         this.OrdDestOrderStatus = OrdDestOrderStatus;  
         this.CreatedDate = CreatedDate; 
         this.LastModifiedDate = LastModifiedDate;
         this.TrackingNumber=TrackingNumber;
    }

}