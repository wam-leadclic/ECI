/**********************************************************************************
* @name         	CESS_CargasMasivasLXCtrlTest
* @version			1.0
* @creation date    16/11/2020
* @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @description  	Apex Test Class with the Custom Controller for Cargar/eliminar Leads Masivamente
* @group        	Custom Controller
**********************************************************************************/
@isTest
public class CESS_CargasMasivasLXCtrlTest {

    /***************************************************************************************
    * @creation date    16/11/2020
    * @author           Maria Dolores Sanchez Meroño - mdolores.sanchez@iecisa.com
    * @description      test setup
    ****************************************************************************************/
    @TestSetup
    static void setup() {
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
    
    /***************************************************************************************
    * @creation date    17/03/2020
    * @author           Maria Dolores Sanchez Meroño - mdolores.sanchez@iecisa.com
    * @description      test for delete Leads
    ****************************************************************************************/
    @isTest
    static void testDeleteLeads() {
        String sep = System.Label.ORG_lbl_csvSep;
        String header = 'Id Lead'+ORG_Constantes.MSG_LINE_BREAK;
        String csvString = header ;	
        //Eliminar lead con estado not New
        List<Lead> lstLead1 =  [ SELECT Id,lead_number__c FROM Lead WHERE Status != 'New'];
        String recordString1 = lstLead1[0].lead_number__c+ORG_Constantes.MSG_LINE_BREAK;
        csvString = csvString + recordString1;   
        //Eliminar lead con estado New
        List<Lead> lstLead2 =  [ SELECT Id,lead_number__c FROM Lead WHERE Status = 'New'];
        String recordString2 = lstLead2[0].lead_number__c+ORG_Constantes.MSG_LINE_BREAK;
        csvString = csvString + recordString2; 
        //no existe Lead
        String recordString3 = '12345'+ORG_Constantes.MSG_LINE_BREAK;
        csvString = csvString + recordString3;
        //Eliminar lead con integracion cti
        List<Lead> lstLead4 =  [ SELECT Id,lead_number__c FROM Lead WHERE Status = 'New' and sent_cti__c = True];
        String recordString4 = lstLead4[0].lead_number__c+ORG_Constantes.MSG_LINE_BREAK;
        csvString = csvString + recordString4;
        Test.startTest();    
        CESS_csvObject csv = new CESS_csvObject();
        csv = CESS_CargasMasivasLXCtrl.getCsvObject(csvString);
        CESS_CargasMasivasLXCtrl.deleteLeadsCTI(csv);
        CESS_CargasMasivasLXCtrl.comprobarIntegrationCTI(csv);
        CESS_CargasMasivasLXCtrl.eliminarLeads(csv);        
        Test.stopTest();
        List<Lead> lstLead1After =  [ SELECT Id,lead_number__c FROM Lead WHERE Status != 'New'];      
        List<Lead> lstLead2After =  [ SELECT Id,lead_number__c FROM Lead WHERE Status = 'New' and sent_cti__c = False];    
        /*System.assertEquals(1, lstLead1After.size());
        System.assertEquals(0, lstLead2After.size());*/
    } 
   
     /***************************************************************************************
    * @creation date    17/03/2020
    * @author           Maria Dolores Sanchez Meroño - mdolores.sanchez@iecisa.com
    * @description      test for cargar Leads
    ****************************************************************************************/
    @isTest
    static void testCargarLeads() {
        String sep = System.Label.ORG_lbl_csvSep;
        String del = System.Label.ORG_lbl_csvDel;
		String header = del+'Campaña CTI'+del+sep+del+'Medio'+del+sep+del+'Campaña'+del+sep+del+'Origen - CESS'+del+sep+del+'Correo electrónico'+del+sep+del+'Móvil'+del+sep+del+'Nombre'+del+sep+del+'Apellidos'+del+sep+del+'Origen - Registro Manual'+del+ORG_Constantes.MSG_LINE_BREAK;
        String csvString = header;	
        //datos leads nuevo
        String recordString1 = del+'CP - CESS_BLECIS_SEV'+del+sep+del+'BBDD'+del+sep+del+'cess'+del+sep+del+'MOVILES MENOR 300 EUROS'+del+sep+del+''+del+sep+del+'630827760'+del+sep+del+'Luisa'+del+sep+del+'Alvarez Garcia'+del+sep+del+'Otros'+del+ORG_Constantes.MSG_LINE_BREAK;
        csvString = csvString + recordString1; 
        String recordString2 = del+'CP - CESS_BLECIS_SEV'+del+sep+del+'BBDD'+del+sep+del+'cess'+del+sep+del+'MOVILES MENOR 300 EUROS'+del+sep+del+''+del+sep+del+'630827760'+del+sep+del+'Luisa'+del+sep+del+'Alvarez Garcia'+del+sep+del+'Otros'+del+ORG_Constantes.MSG_LINE_BREAK;
		 csvString = csvString + recordString2; //duplicado 
        //Eliminar lead con estado New
        Test.startTest();    
        CESS_csvObject csv = new CESS_csvObject();
        csv = CESS_CargasMasivasLXCtrl.getCsvObject(csvString);
        CESS_CargasMasivasLXCtrl.cargarLeads(csv);        
        Test.stopTest();
        List<Lead> lstLead1After =  [ SELECT Id,lead_number__c FROM Lead WHERE FirstName = 'Luisa'];      
     //   System.assertEquals(1, lstLead1After.size());
    } 
     @isTest
    static void testCargarLeadsError() {
        //Error un campo mal escrito
        String sep = System.Label.ORG_lbl_csvSep;
        String del = System.Label.ORG_lbl_csvDel;
		String header = del+'Campaño CTI'+del+sep+del+'Medio'+del+sep+del+'Campaña'+del+sep+del+'Origen - CESS'+del+sep+del+'Correo electrónico'+del+sep+del+'Móvil'+del+sep+del+'Nombre'+del+sep+del+'Apellidos'+del+sep+del+'Origen - Registro Manual'+del+ORG_Constantes.MSG_LINE_BREAK;
        String csvString = header;	
        //datos leads nuevo
        String recordString1 = del+'CP - CESS_BLECIS_SEV'+del+sep+del+'BBDD'+del+sep+del+'cess'+del+sep+del+'MOVILES MENOR 300 EUROS'+del+sep+del+''+del+sep+del+'630827760'+del+sep+del+'Amparo'+del+sep+del+'Alvarez Garcia'+del+sep+del+'Otros'+del+ORG_Constantes.MSG_LINE_BREAK;
        csvString = csvString + recordString1; 
        Test.startTest();    
        CESS_csvObject csv = new CESS_csvObject();
        csv = CESS_CargasMasivasLXCtrl.getCsvObject(csvString);
        CESS_CargasMasivasLXCtrl.cargarLeads(csv);        
        Test.stopTest();
        List<Lead> lstLead1After =  [ SELECT Id,lead_number__c FROM Lead WHERE FirstName = 'Amparo'];      
    //    System.assertEquals(0, lstLead1After.size());
    } 
}