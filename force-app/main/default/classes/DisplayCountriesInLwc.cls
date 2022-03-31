/**
 * @File Name          : DisplayCountriesInLwc.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 24/4/2020, 4:18:10 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    24/4/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class DisplayCountriesInLwc {

    @AuraEnabled(cacheable=true)
    public static List<country__c> displayCountries()
    {
        List<country__c> countries = [SELECT country_name__c from country__c];
        system.debug('countries------->'+countries);
        return countries;
    }
}