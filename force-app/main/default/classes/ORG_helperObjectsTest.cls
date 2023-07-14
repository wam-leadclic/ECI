/**********************************************************************************
* @name         	DQ_cls_helperObjectsTest
* @version			1.0
* @creation date   	29/04/2020
* @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
* @description  	Test to the DQ_cls_helperObjects class
* @group        	Helper
**********************************************************************************/
@isTest
private class ORG_helperObjectsTest {
	/**
     * @description 
     */
	/*@testSetup
    private static void setup() {
        
    }*/
    /**
     * @description 
     */
    @isTest
    private static void testCheckIsNIFValid() {
        String personal_document = '15213308G';   
        Boolean resultado;
        Test.startTest();
        resultado = ORG_helperObjects.isNifValid(personal_document);
        Test.stopTest();
        System.assertEquals(true, resultado);

    }   
    
    /**
     * @description 
     */
    @isTest
    private static void testCheckIsCIFValid() {
        String personal_document = 'G0076915H';    
        String personal_document_FrsLetter = 'K0076915H';    
        String personal_document_NOK_FrsLetter = 'I0076915H';    

        String personal_document_NOK_length = 'G90076915H';        
		String personal_document_NOK_pattern = 'G900-6915H:';        

        Test.startTest();
        Boolean resultado;
        Boolean resultado_NOK_length;
        Boolean resultado_NOK_pattern;
		Boolean resultado_OK_FstLetter;
		Boolean resultado_NOK_FstLetter;
		
        resultado = ORG_helperObjects.isCifValid(personal_document);
        resultado_NOK_length = ORG_helperObjects.isCifValid(personal_document_NOK_length);
        resultado_NOK_pattern = ORG_helperObjects.isCifValid(personal_document_NOK_pattern);
        resultado_OK_FstLetter = ORG_helperObjects.isCifValid(personal_document_FrsLetter);
        resultado_NOK_FstLetter = ORG_helperObjects.isCifValid(personal_document_NOK_FrsLetter);

        Test.stopTest();
        System.assertEquals(true, resultado);
        System.assertEquals(false, resultado_NOK_length);
        System.assertEquals(false, resultado_NOK_pattern);
        System.assertEquals(true, resultado_OK_FstLetter);
        System.assertEquals(false, resultado_NOK_FstLetter);

    }  
    /**
     * @description 
     */
    @isTest
    private static void testCheckisNcValid() {
        String personal_document = '123456789';
        Boolean resultado;
        Test.startTest();
        resultado = ORG_helperObjects.isNCValid(personal_document);
        Test.stopTest();
        System.assertEquals(true, resultado);
    } 
    
    /**
     * @description 
     */
    @isTest
    private static void testCheckisNieNotValid() {
        String personal_document = 'X1234567P';
        String personal_document_noFstLetter = 'H1234567P';

        Boolean resultado;
        Boolean resultado_NOK_FstLetter;

        Test.startTest();
        resultado = ORG_helperObjects.isNieValid(personal_document);
        resultado_NOK_FstLetter = ORG_helperObjects.isNieValid(personal_document_noFstLetter);

        Test.stopTest();
        System.assertEquals(false, resultado);
        System.assertEquals(false, resultado_NOK_FstLetter);

    } 
    @isTest
    private static void testCheckisNieValid() {
        String personal_document_X = 'X0030330Q';
        String personal_document_Y = 'Y2893132E';
        String personal_document_Z = 'Z8644735Y';

        Boolean resultado_X;
        Boolean resultado_Y;
        Boolean resultado_Z;

        Test.startTest();
        resultado_X = ORG_helperObjects.isNieValid(personal_document_X);
        resultado_Y = ORG_helperObjects.isNieValid(personal_document_Y);
        resultado_Z = ORG_helperObjects.isNieValid(personal_document_Z);

        Test.stopTest();
        System.assertEquals(true, resultado_X);
        System.assertEquals(true, resultado_Y);
        System.assertEquals(true, resultado_Z);
    }
    
}