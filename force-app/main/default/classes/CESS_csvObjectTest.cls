/**********************************************************************************
* @name         	CESS_csvObjectTest
* @version			1.0
* @creation date    16/11/2020
* @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @description  	Apex Class to test CESS_csvObject
* @group        	Test
**********************************************************************************/
@isTest
public class CESS_csvObjectTest {
    
    private static final String CSV_STR = 'HA' + System.Label.ORG_lbl_csvSep + 'HB' + ORG_Constantes.MSG_LINE_BREAK + 'A' + System.Label.ORG_lbl_csvSep + 'B';
    
    /***************************************************************************************
    * @author           María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    16/11/2020
    * @description      test csv object
    ****************************************************************************************/
    @isTest
    static void testCsvObject() {
        Test.startTest();
		CESS_csvObject csvObj1 = new CESS_csvObject();
    	CESS_csvObject csvObj2 = new CESS_csvObject(CSV_STR);  
        CESS_csvHeader csvHead1 = new CESS_csvHeader();
        csvHead1.columnName = 'HC';
        CESS_csvHeader csvHead2 = new CESS_csvHeader('HD');
        CESS_csvHeader csvHead3 = new CESS_csvHeader('HE','String');
        List<CESS_csvHeader> lstCsvHea = new List<CESS_csvHeader>();
        lstCsvHea.add(csvHead1);
        lstCsvHea.add(csvHead2);
        lstCsvHea.add(csvHead3);
        List<List<String>> lstCsvLin = new List<List<String>>();
        List<String> lstStr = new List<String>();
        lstStr.add('C');
        lstStr.add('D');
        lstStr.add('E');
        lstCsvLin.add(lstStr);
        CESS_csvObject csvObj3 = new CESS_csvObject(lstCsvHea, lstCsvLin);
        csvObj3.toString();
        Test.stopTest();
    }

}