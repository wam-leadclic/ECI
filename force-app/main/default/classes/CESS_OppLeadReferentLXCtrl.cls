/**********************************************************************************
* @author       María Dolores Sánchez Meroño -mdolores.sanchez@iecisa.com
* @date         08/05/2018
* @group        Lead
* @description  Controller class for CESS_OppLeadReferentLXCtrl component.
* @Revision
**********************************************************************************/

public with sharing class CESS_OppLeadReferentLXCtrl {

    //-- PUBLIC METHODS
    //Get referente Lead and accountId
    
    @AuraEnabled
    public static Lead getReferent (Id idLeadPre) {
        System.debug('HOLA' +' '+idLeadPre);
        List<Lead> lstleads = [SELECT Id,ConvertedOpportunityId from Lead WHERE Id = :idLeadPre LIMIT 1];
        System.debug(lstleads.size());
        if(lstLeads.size()>0){
            System.debug(lstleads[0]);
            return lstleads[0];
        }else{
            return null;
        }
    }
	@AuraEnabled
    public static List<Opportunity> getOpp(String idOpp) {
        List<Opportunity> lstOpp = [SELECT Id,StageName,Amount,Name,CloseDate,Owner.Name,Account.Name,Account.Id from Opportunity WHERE Id = :idOpp LIMIT 1];
        if(lstOpp.size()>0){
            return lstOpp;
        }else{
            return null;
        }
    }
    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class CESS_OppLeadReferentLXCtrlException extends Exception {}

}