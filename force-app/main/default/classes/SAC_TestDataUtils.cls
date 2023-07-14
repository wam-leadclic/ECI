/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         22/05/2018
* @group        Test
* @description  Test class for utility test methods. SAC specific
* @Revision
**********************************************************************************/
@isTest
public class SAC_TestDataUtils {
	//CONSTRUCTOR
    private SAC_TestDataUtils() {

    }

    //SINGLETON PATTERN
    private static SAC_TestDataUtils instance;
    public static SAC_TestDataUtils getInstance() {
        if (instance == null) instance = new SAC_TestDataUtils();
        return instance;
    }
    
    //CLIENTE
    public Account completeCliente(Account a) {
        a.personal_document__pc = '123456789';
        a.document_type__pc = 'NIF';
        a.card_eci__pc = 'ECI1234567890';
        
        return a;
    }
    
    /* MMV: COMENTADO PARA EVITAR DEPENDENCIAS
    //EMPRESA
    public Organization__c newEmpresa(String code, String name) {
        return new Organization__c(
            code__c = code,
            Name = code + ' - ' + name,
            date_created__c = Date.today()
        );
    }
    
    //DIVISION
    public CommercialDivision__c newDivision(String code, String name, Id empresaId) {
        return new CommercialDivision__c(
            organization__c = empresaId,
            code__c = code,
            Name = name,
            date_created__c = Date.today()
        );
    }
    
    //CENTRO
    public ShoppingCenter__c newCentro(String code, String name, Id empresaId) {
        return newCentro(code,name,empresaId,false);
    }

    public ShoppingCenter__c newCentro(String code, String name, Id empresaId, Boolean isHipercor) {
        return new ShoppingCenter__c(
            organization__c = empresaId,
            code__c = code,
            Name = name,
            date_created__c = Date.today(),
            isHipercor__c = isHipercor
        );
    }
    
    //UNECO
    public Department__c newUneco(String code, String name, Id divisionId) {
        return new Department__c(
            commercial_division__c = divisionId,
            code__c = code,
            Name = name,
            date_created__c = Date.today()
        );
    }
    
    //ACCION PROMOCIONAL
    public Offer__c newAccionPromocional(String code, String name) {
        return new Offer__c(
            code__c = code,
            Name = name
        );
    }
    
    //CENTRO EXPEDICIÓN
    public DistributionCentre__c newDistributionCenter(String name, String division) {
        return new DistributionCentre__c(
            Name = name,
            queue_desc__c = division
        );
    }*/
}