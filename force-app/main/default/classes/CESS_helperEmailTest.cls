/**********************************************************************************
* @name         	CESS_helperEmailTest
* @version			1.0
* @creation date    17/11/2020
* @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @description  	Apex Test Class of CESS_helperEmail
* @group        	Custom Controller
**********************************************************************************/
@isTest
public class CESS_helperEmailTest {

    /***************************************************************************************
    * @creation date    02/04/2020
    * @author           Maria Dolores Sanchez Meroño - mdolores.sanchez@iecisa.com
    * @description      test setup
    ****************************************************************************************/
    @TestSetup
    static void setup() {
	
    }
    
    /***************************************************************************************
    * @creation date    17/11/2020
    * @author           Maria Dolores Sanchez Meroño - mdolores.sanchez@iecisa.com
    * @description      test 
    ****************************************************************************************/
    @isTest
    static void testMethods() {
         //lines
        List<List<String>> lines = new List<List<String>>();
        List<String> line = new List<String>{'Error','1'};
        lines.add(line); 
        //FORMAR HEADER
        List<String> lstColumnas = new List<String>();
        String labelsHeaders = ORG_TestDataUtils.header;
        if(!String.isEmpty(labelsHeaders)){
            lstColumnas = labelsHeaders.split(CESS_Constantes.CESS_SEP);
        }
        List<CESS_csvHeader> headers = new List<CESS_csvHeader>();
        for(String header : lstColumnas) {
            headers.add(new CESS_csvHeader(header));
        }
        CESS_csvObject csv = new CESS_csvObject(headers, lines);
        String labelEmailAdresses = ORG_TestDataUtils.labelEmailAdresses;
        String labelEmailCCAdresses = ORG_TestDataUtils.labelEmailCCAdresses;
        String nameCsvOut = ORG_TestDataUtils.nameCsvOut;
        String subject = ORG_TestDataUtils.subject;
        String body = ORG_TestDataUtils.body;
        Test.startTest();    
        CESS_helperEmail.createAndSendEmail(labelEmailAdresses, labelEmailCCAdresses, subject, body, nameCsvOut, csv);
        Test.stopTest();

    } 
}