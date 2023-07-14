/**********************************************************************************
* @name         	CESS_helperMassive
* @version			1.0
* @creation date    05/11/2020
* @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @description  	Apex Class with the functionality of the helper for Procesos Masivos
* @group        	Helper
**********************************************************************************/
public with sharing class CESS_helperMassive {

	/* The name of the class */
    private final static String CLASS_NAME = CESS_helperMassive.class.getName();

  
    /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    05/11/2020
    * @description  	Create the out csv object
    * @param header			the header for out csv
    * @param csvObject		the in csv object
    * @param mapLinEstado	the map number of line with the states
    * return				the out csv object
    **********************************************************************************/
    public static CESS_csvObject createCsvObj(String header, CESS_csvObject csvObject, Map<Integer, String> mapLinEstado,Map<Integer,String> mapLinInfoAdd) {
        final String methodName = 'createCsvObj';
        CESS_csvObject csvObj = null;
     	if (!String.isEmpty(header)) {
          	List<String> lstColumnas = header.split(Label.ORG_lbl_csvSep);
            List<CESS_csvHeader> headers = new List<CESS_csvHeader>();
            for(String col : lstColumnas) {
                headers.add(new CESS_csvHeader(col));
            }
            List<List<String>> lines = new List<List<String>>();
            List<String> lstStr = new List<String>();
            Integer numLine = 1;
            List<String> infoAdd = new List<String>();
            for (List<String> line : csvObject.lines) { 
                String estado = ORG_Constantes.MSG_OK;
                String error = ORG_Constantes.MSG_EMPTY;
                String ldName = ORG_Constantes.MSG_EMPTY;
                String ldLastName = ORG_Constantes.MSG_EMPTY;
                String ldCampCTI = ORG_Constantes.MSG_EMPTY;
                String ldMedio = ORG_Constantes.MSG_EMPTY;
                if (mapLinEstado.get(numLine) != ORG_Constantes.MSG_OK) {
                    estado = ORG_Constantes.MSG_ERROR;
                    error = mapLinEstado.get(numLine);
                }
                if(mapLinInfoAdd.get(numLine) <> null){
                    infoAdd = mapLinInfoAdd.get(numLine).split(CESS_Constantes.CESS_SEP);
                    if(infoAdd[0]<>'null')ldName = infoAdd[0];
                    if(infoAdd[1]<>'null')ldLastName = infoAdd[1];
                    if(infoAdd[2]<>'null')ldCampCTI = infoAdd[2];
                    if(infoAdd[3]<>'null')ldMedio = infoAdd[3];
                }
                lstStr = new List<String>{String.valueof(numLine),ldName,ldLastName,ldCampCTI,ldMedio,estado,line.get(0),error};
                lines.add(lstStr);
                numLine++;
            }
            csvObj = new CESS_csvObject(headers, lines);
      	}
        return csvObj;
    }
    
   

}