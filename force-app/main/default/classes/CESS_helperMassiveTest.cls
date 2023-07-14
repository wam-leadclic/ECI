/**********************************************************************************
* @name         	CESS_helperMassiveTest
* @version			1.0
* @author           María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @creation date    16/11/2020
* @description  	Apex Class with test for CESS_helperMassive
* @group        	Test
**********************************************************************************/
@isTest
public class CESS_helperMassiveTest {
    
     private final static String HEADER_2 = 'Linea,Resultado,Id Lead,Error';    
    
    /**********************************************************************************
    * @author           María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
	* @creation date    16/11/2020
    * @description  	Test setup
    **********************************************************************************/
    @testSetup
    private static void setup() {
       ORG_TestDataUtils orgDataUtils = ORG_TestDataUtils.getInstance();
       List <Lead> lstLd = new List <Lead>();
       lstLd.add(new Lead (LastName='Test1', source_manualrecord__c='Otros', Email = 'test1@email.com',
                            MobilePhone='666778899',Status='Unqualified',result__c='Duplicado'));
       lstLd.add(new Lead (LastName='Test2', source_manualrecord__c='Otros', Email = 'test2@email.com',
                            MobilePhone='666778898',Status='New'));
       lstLd.add(new Lead (LastName='Test3', source_manualrecord__c='Otros', Email = 'test3@email.com',
                            MobilePhone='666778897',Status='New',sent_cti__c = True));
       insert lstLd;
    }
    
 /**********************************************************************************
    * @author       	Alejandro Martínez Hernández - alejandro.martinez@iecisa.com
    * @creation date    14/04/2020
    * @description  	Test createCsvObj
    **********************************************************************************/
    @isTest
    static void createCsvObj_test() {
        String sep = System.Label.ORG_lbl_csvSep;
        String header = 'Id Lead'+ORG_Constantes.MSG_LINE_BREAK;
        String csvString = header ;	
        Integer numLin = 1;
        Map<Integer, String> mapInfoAdd = new Map<Integer, String>();
        for(Lead ld : [SELECT Id,lead_number__c,FirstName,LastName,campaign_cti__c,source_type__c FROM Lead]){
            String recordLine = ld.lead_number__c+ORG_Constantes.MSG_LINE_BREAK;
        	csvString = csvString + recordLine; 
            String infoAdd = ld.FirstName+CESS_Constantes.CESS_SEP+ld.LastName+CESS_Constantes.CESS_SEP+ld.campaign_cti__c+CESS_Constantes.CESS_SEP+ld.source_type__c;
            mapInfoAdd.put(numLin,infoAdd);
            numLin++;
        } 
        csvString = csvString + '1234'+ORG_Constantes.MSG_LINE_BREAK;
        CESS_csvObject csvObj = new CESS_csvObject(csvString);
        Map<Integer, String> mapLinEstado = new Map<Integer, String>();
        
        numLin = 1;
        for (List<String> line : csvObj.lines) { 
            mapLinEstado.put(numLin, ORG_Constantes.MSG_EMPTY);	
            numLin++;
        }      
        Test.startTest();
        CESS_csvObject outCsv = CESS_helperMassive.createCsvObj(HEADER_2, csvObj, mapLinEstado,mapInfoAdd);
        Test.stopTest();
        System.assertNotEquals(null, outCsv, 'El objeto csv de salida debe ser distinto de null');
    }
}