/**********************************************************************************
* @name         	CESS_CargasMasivasLXCtrl
* @version			1.0
* @creation date   	04/11/2020
* @author       	María Dolores Sánchez Meroño -mdolores.sanchez@iecisa.com
* @description  	Apex Class with custom controller for Borrado Masivo Puntos de Venta
* @group        	Custom Controller
**********************************************************************************/
public with sharing class CESS_CargasMasivasLXCtrl {

    /* The name of the class */
    private final static String CLASS_NAME = CESS_CargasMasivasLXCtrl.class.getName();
    // CONSTANTS
   	private final static String DEFAULT_HEADER = 'Linea,Nombre,Apellido,Campaña CTI ,Medio,Resultado,Numero Lead,Error';
    //-- ATTRIBUTES

    /**********************************************************************************
    * @author       	Maria Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    30/03/2020
    * @description  	Get a csv object
    * @param csvStr		the string with the csv
    * @return			the csv object
    **********************************************************************************/
    @AuraEnabled
    public static CESS_csvObject getCsvObject(String csvStr) {
        final String methodName = 'getCsvObject';
       	System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, ORG_Constantes.MSG_INIT));
        CESS_csvObject csvObj = new CESS_csvObject(csvStr);
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, ORG_Constantes.MSG_END));
        return csvObj;
    }
    
   /**********************************************************************************
    * @author       	Maria Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    04/11/2020
    * @description  	delete Lead
    * @param csvStr		the string with the csv
    **********************************************************************************/
    @AuraEnabled
    public static void eliminarLeads(CESS_csvObject csvObject) {
        final String methodName = 'eliminarLeads';
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, ORG_Constantes.MSG_INIT));
        Set<String> setIdsLeads = new Set<String>();
       Map<Integer, String> mapLinEstado = new Map<Integer, String>();
       Map<Integer, String> mapLinInfoAdd = new Map<Integer, String>();
       Map<String, Integer> mapLeadLin = new Map<String, Integer>();
        String sep = CESS_Constantes.CESS_SEP;
        Integer numLin = 1;
        for (List<String> line : csvObject.lines) { 
            System.debug('line.size(): ' +line.size());
            mapLinEstado.put(numLin,ORG_Constantes.MSG_EMPTY);	
            if (!String.isEmpty(line.get(0))) {
            	setIdsLeads.add(line.get(0));
                mapLeadLin.put(line.get(0), numLin);
            }
            numLin++;
        }
        List<String> setIdsLeadsFound = new List<String>();
        List<Lead> lstLeadsToDel = new List<Lead>();
        Map<Id,String> mapIdLeadNumber = new Map<Id,String>();
        List<Lead> lstLeadsToDeleteFromSF = new List<Lead>();
        List<Id>lstIdLeadUpdateSuccess = new List<Id>();
        for( Lead ld : [SELECT Id,lead_number__c,Status,sent_cti__c,cti_integrationstatus__c,CTI_DeleteError__c,FirstName,LastName,campaign_cti__c,source_type__c,result__c FROM Lead WHERE lead_number__c IN :setIdsLeads]){
            setIdsLeadsFound.add(ld.lead_number__c);
            Integer currentNumLin = mapLeadLin.get(ld.lead_number__c);
            String FirstName = ld.FirstName <> null && String.isNotBlank(ld.FirstName) ? ld.FirstName : 'null';
            String LastName = ld.LastName <> null && String.isNotBlank(ld.LastName) ? ld.LastName : 'null';
            String campCTI = ld.campaign_cti__c <> null && String.isNotBlank(ld.campaign_cti__c) ? ld.campaign_cti__c : 'null';
            String Medio = ld.source_type__c <> null && String.isNotBlank(ld.source_type__c) ? ld.source_type__c : 'null';
            String infoAdd = FirstName+sep+LastName+sep+campCTI+sep+Medio;
           	mapLinInfoAdd.put(currentNumLin,infoAdd);
            if(ld.Status == CESS_Constantes.LEAD_NEW_STATUS || (ld.result__c == CESS_Constantes.LEAD_DUPLICADO_RESULT && ld.Status == CESS_Constantes.LEAD_UNQUALIFIED_STATUS)){
                System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'El lead:' + ld.lead_number__c +'es New'));
                 if(ld.sent_cti__c == True){
                    System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'El lead:' + ld.lead_number__c +'esta en CTI'));
                     if(ld.CTI_DeleteError__c == CESS_Constantes.INT_DELETE_CTI_SUCCESS){
                        lstLeadsToDeleteFromSF.add(ld);
                        mapLinEstado.put(currentNumLin, ORG_Constantes.MSG_OK); 
                        mapIdLeadNumber.put(ld.Id,ld.lead_number__c);
                     }else{
                        mapLinEstado.put(currentNumLin, ld.CTI_DeleteError__c);
                     }
                } else {
                    System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'El lead:' + ld.lead_number__c +' no esta en CTI'));
                    lstLeadsToDeleteFromSF.add(ld);
                    mapLinEstado.put(currentNumLin, ORG_Constantes.MSG_OK);
            		mapIdLeadNumber.put(ld.Id,ld.lead_number__c);
                } 
                
             }else{
                 System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'numLine:'+currentNumLin+'El lead:' + ld.lead_number__c +' no es NEW'+ Label.CESS_lbl_LeadErrorNotNew));
                 mapLinEstado.put(currentNumLin,Label.CESS_lbl_LeadErrorNotNew);
             }
            
        }
        numLin = 1;
        for (List<String> line : csvObject.lines) { 
            String idLead = line.get(0);
            String state =  mapLinEstado.get(numLin);
            if (!setIdsLeadsFound.contains(line.get(0))) {//el Lead no existe 
                mapLinEstado.put(numLin,Label.CESS_lbl_LeadErrorNoExiste);	
            } 
            numLin++;
        }

        if(lstLeadsToDeleteFromSF.size()>0){
		     deleteLeadsFromSF(lstLeadsToDeleteFromSF,mapLinEstado,mapIdLeadNumber,mapLeadLin); 
        }
        String header = System.Label.CESS_lbl_headerMasivoElimLeadMasivo;
        if (String.isEmpty(header)) {
        	header = DEFAULT_HEADER;
        }
        CESS_csvObject csvOut = CESS_helperMassive.createCsvObj(header, csvObject, mapLinEstado,mapLinInfoAdd);
        String labelEmailAdresses =  UserInfo.getUserEmail();
        String labelEmailCCAdresses = System.Label.CESS_lbl_procMasLeadEmailAddcc;
        String nameCsvOut = System.Label.CESS_proMasivoLeadNameCsv;
        String subject = System.Label.CESS_proMasivoLeadSubjectElim;
        String body = System.Label.CESS_proMasivoLeadBodyEmail;
        CESS_helperEmail.createAndSendEmail(labelEmailAdresses, labelEmailCCAdresses, subject, body, nameCsvOut, csvOut);
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, ORG_Constantes.MSG_END));
    }
    /**********************************************************************************
    * @author       	Maria Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    04/11/2020
    * @description  	delete Lead
    * @param lstLeadsToDeleteFromSF		lst leads to delete from SF
	* @param mapLinEstado				map lin csv, estado
	* @param mapIdLeadNumber			map idLead,numLin
	* @param mapLeadLin					map lead, numLin
    **********************************************************************************/
	public static void deleteLeadsFromSF(List<Lead> lstLeadsToDeleteFromSF,Map<Integer,String> mapLinEstado,Map<Id,String>mapIdLeadNumber,Map<String, Integer>mapLeadLin){
        final String methodName = 'deleteLeadsFromSF';
        if(lstLeadsToDeleteFromSF.size() > 0){
            Database.DeleteResult[] srListDel = System.Database.delete(lstLeadsToDeleteFromSF, false);
            for (Integer i = 0; i < lstLeadsToDeleteFromSF.size(); i++) {
                Database.DeleteResult s = srListDel[i];
                Lead origRecord = lstLeadsToDeleteFromSF[i];
                if (!s.isSuccess()) {
                    String strError = ORG_Constantes.MSG_EMPTY;
                    System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'Id errors: ' + origRecord.Id));
                    for(Database.Error err : s.getErrors()) {
                        strError += err.getMessage();
                        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'ERROR: '+strError));                        
                    }
                    if(mapIdLeadNumber.get(origRecord.Id) != null){
                        String key = mapIdLeadNumber.get(origRecord.Id);
                        Integer currentNumLin = mapLeadLin.get(key);
                        mapLinEstado.put(currentNumLin, strError);
                    }
                }else{
                    System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'Id Delete OK: ' + origRecord.Id ));
                } 
            }
        }
    }
    /**********************************************************************************
    * @author       	Stella Escribano - sescribano@leadclic.com
    * @creation date    14/03/2022
    * @description  	update Lead
    * @param csvStr		the string with the csv
    **********************************************************************************/
    @AuraEnabled
    public static void updateLeadsCTI(CESS_csvObject csvObject){
         final String methodName = 'updateLeadsCTI';
         List<Lead> updateErrorsLeads = new List<Lead>();
         Set<String> setIdsLeads = new Set<String>();
         System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'csvObject.lines.size: ' + csvObject.lines.size()));
        for (List<String> line : csvObject.lines) { 
            if (!String.isEmpty(line.get(0))) {
            	setIdsLeads.add(line.get(0));
            }
        }
        List<Lead> lstLeadsToDel = new List<Lead>();
        for( Lead ld : [SELECT Id,lead_number__c,Status,sent_cti__c,cti_integrationstatus__c,result__c FROM Lead WHERE lead_number__c IN :setIdsLeads]){
             if(ld.Status == CESS_Constantes.LEAD_NEW_STATUS || (ld.result__c == CESS_Constantes.LEAD_DUPLICADO_RESULT && ld.Status == CESS_Constantes.LEAD_UNQUALIFIED_STATUS)){
                System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'El lead:' + ld.lead_number__c +'es New'));
                if(ld.sent_cti__c == True){
                    ld.sent_cti__c = false;
                    lstLeadsToDel.add(ld);
                }
                Integer errors = 0;
        Database.SaveResult[] srListUpdate = System.Database.update(lstLeadsToDel, false);
        for (Integer i = 0; i < lstLeadsToDel.size(); i++) {
            Database.SaveResult s = srListUpdate[i];
            Lead origRecord = lstLeadsToDel[i];
            String statusIntegracion = origRecord.cti_integrationstatus__c;
            System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'El lead:' + origRecord.lead_number__c +'tiene cti status:'+statusIntegracion) );
            if (!s.isSuccess()) {
                origRecord.cti_integrationstatus__c = 'Eliminacion fallida';
                origRecord.CTI_DeleteError__c = 'Error';
                updateErrorsLeads.add(origRecord);
                String strError = ORG_Constantes.MSG_EMPTY;
                System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'Id errors: ' + origRecord.Id));
                for(Database.Error err : s.getErrors()) {
                    strError += err.getMessage();
                    System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'ERROR: '+strError));                        
                }
            } 
        }
        if(updateErrorsLeads.size()>0){
            update updateErrorsLeads;
        }
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, ORG_Constantes.MSG_END));
                
             }
        }
    }
  	/**********************************************************************************
    * @author       	Maria Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    04/11/2020
    * @description  	delete Lead
    * @param csvStr		the string with the csv
    **********************************************************************************/
    @AuraEnabled
    public static void deleteLeadsCTI(CESS_csvObject csvObject){
        final String methodName = 'deleteLeadsCTI';
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, ORG_Constantes.MSG_INIT));
        Set<String> setIdsLeads = new Set<String>();
        List<Lead> updateErrorsLeads = new List<Lead>();
         System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'csvObject.lines.size: ' + csvObject.lines.size()));
        for (List<String> line : csvObject.lines) { 
            if (!String.isEmpty(line.get(0))) {
            	setIdsLeads.add(line.get(0));
            }
        }
        List<Lead> lstLeadsToDel = new List<Lead>();
        for( Lead ld : [SELECT Id,lead_number__c,Status,sent_cti__c,cti_integrationstatus__c,result__c FROM Lead WHERE lead_number__c IN :setIdsLeads]){
             if(ld.Status == CESS_Constantes.LEAD_NEW_STATUS || (ld.result__c == CESS_Constantes.LEAD_DUPLICADO_RESULT && ld.Status == CESS_Constantes.LEAD_UNQUALIFIED_STATUS)){
                System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'El lead:' + ld.lead_number__c +'es New'));
                 if(ld.sent_cti__c == True){
                    //System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'El lead:' + ld.lead_number__c +'esta en CTI'));
                    ld.cti_integrationstatus__c = CESS_Constantes.SUCCESS_DELETE_CTI;
                    ld.CTI_DeleteError__c = ORG_Constantes.MSG_EMPTY;
                    lstLeadsToDel.add(ld);  
                 }
             }
        }
        Integer errors = 0;
        Database.SaveResult[] srListUpdate = System.Database.update(lstLeadsToDel, false);
        for (Integer i = 0; i < lstLeadsToDel.size(); i++) {
            Database.SaveResult s = srListUpdate[i];
            Lead origRecord = lstLeadsToDel[i];
            String statusIntegracion = origRecord.cti_integrationstatus__c;
            System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'El lead:' + origRecord.lead_number__c +'tiene cti status:'+statusIntegracion) );
            if (!s.isSuccess()) {
                origRecord.cti_integrationstatus__c = 'Eliminacion fallida';
                origRecord.CTI_DeleteError__c = 'Error';
                updateErrorsLeads.add(origRecord);
                String strError = ORG_Constantes.MSG_EMPTY;
                System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'Id errors: ' + origRecord.Id));
                for(Database.Error err : s.getErrors()) {
                    strError += err.getMessage();
                    System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, 'ERROR: '+strError));                        
                }
            } 
        }
        if(updateErrorsLeads.size()>0){
            update updateErrorsLeads;
        }
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, methodName, ORG_Constantes.MSG_END));
    }
   
    /**********************************************************************************
    * @author       	Maria Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    09/11/2020
    * @description  	Comprobar si CTI integration Status ha cambiado
    * @param csvStr		the string with the csv
    * @return			Boolean cambio
    **********************************************************************************/
    @AuraEnabled
    public static Boolean comprobarIntegrationCTI(CESS_csvObject csvObject){
       final String METHOD_NAME = 'comprobarIntegrationCTI';
       System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_INIT)); 
       Set<String> setIdsLeads = new Set<String>();
       for (List<String> line : csvObject.lines) { 
            if (!String.isEmpty(line.get(0))) {
            	setIdsLeads.add(line.get(0));
            }
       }
       Integer intentos = 10;
       Integer leadsExisten = 0;
       Integer leadsUpdated = 0;
       Boolean cambio = false;
        for(Lead ld : [SELECT Id,CTI_DeleteError__c FROM Lead WHERE lead_number__c IN :setIdsLeads AND sent_cti__c = True]){
            leadsExisten++;
            System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'ld.CTI_DeleteError__c: ' + ld.CTI_DeleteError__c));
            if(ld.CTI_DeleteError__c <> '' && ld.CTI_DeleteError__c <> null){
                leadsUpdated++;
            }
        }
        if(leadsUpdated == leadsExisten){
            cambio =  true;
        } 
            
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_END));        
        return cambio;
    }
    /**********************************************************************************
    * @author       	Maria Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    09/11/2020
    * @description  	cargar Lead
    * @param csvStr		the string with the csv
    **********************************************************************************/
    @AuraEnabled
    public static void cargarLeads(CESS_csvObject csvObject) {
        final String METHOD_NAME = 'cargarLeads';
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_INIT));
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_END));
        Set<String> setIdsLeads = new Set<String>();
        Integer maxFields = 30;
        String del = System.Label.ORG_lbl_csvDel;
        Map<Integer, String> mapLinEstado = new Map<Integer, String>();
        Map<String,Integer> mapUniqValLinea = new Map<String,Integer>();
        List<String> fieldsApi = new List<String>();
        Integer numLin = 1;
        Integer col = 0;
        String field;
        List<CESS_csvHeader> headers = csvObject.headers;
        List<String> fields = new List<String>();
        for(CESS_csvHeader h : headers){
            if (h.columnName <> null /*&& h.columnName.startsWith(del) && h.columnName.endsWith(del)*/) {
               field = h.columnName.trim().replace(del, ORG_Constantes.MSG_EMPTY); 
               //System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'field Column: ' + field);
               fields.add(field.toLowerCase());
            }
        }
      	Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap();
        Map<String,String> labelApiField = new Map<String,String>();
        Set<String> fieldsUpdateable = new Set<String>();
        for(Schema.SObjectField fieldRef : fieldMap.values()){
             Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
             //System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'fieldResult: ' + fieldResult.getLabel().toLowerCase(),fieldResult.getName()));
           	 labelApiField.put(fieldResult.getLabel().toLowerCase(),fieldResult.getName());
             if(fieldResult.isUpdateable()){     
                 //System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'fieldResult is updateable: ' ));
                 fieldsUpdateable.add(fieldResult.getLabel().toLowerCase());   
             }
        }
        for(String f : fields){
           if(labelApiField.get(f) <> null){
                fieldsApi.add(labelApiField.get(f));
            } 
        }
        List<Lead> lstLeadInsert = new List<Lead>();
        Integer indice = 0;
        System.debug('lines size: ' + csvObject.lines.size());
        System.debug('fields size: ' + fields.size());
        for(List<String> line : csvObject.lines){
            System.debug('line campos: ' + line.size() + 'LINEA:' + numLin);
            Lead ld = new Lead();
            String valorUnico= ORG_Constantes.MSG_EMPTY;
            String error = ORG_Constantes.MSG_OK;
            for(Integer i=0; i<fields.size();i++){
                 if (!String.isEmpty(line.get(i))) {
                     System.debug('fieldName: ' + fields.get(i) + 'valor:' + line.get(i));
                    String fieldName = fields.get(i);
                     if(labelApiField.get(fieldName) <> null){
                        if(labelApiField.get(fieldName) == 'send_cti__c'){
                            if(line.get(i).toLowerCase() == 'true'){
                               error = 'El campo: ' + fieldName + ' no se puede insertar a true en una carga masiva.'; 
                            }
                        }else{
                           if(fieldsUpdateable.contains(fieldName)){
                           valorUnico += line.get(i);
                           ld.put(labelApiField.get(fieldName),line.get(i)); 
                            }else{
                                error = 'El campo: ' + fieldName + ' no se puede insertar.';
                            } 
                        }
                     } else{
                        error = 'El campo: ' + fieldName + ' no existe.'; 
                     }            		
            	}     
            }
            System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'Error: ' + error + 'linea: ' + numLin));
            System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'valorUnico: ' + valorUnico + 'linea: ' + numLin));
            mapLinEstado.put(numLin,error);
            if(error == ORG_Constantes.MSG_OK){
                if( mapUniqValLinea.get(valorUnico) == null ){
                    ld.Bulk_Load__c = true;
                    lstLeadInsert.add(ld);
                    mapUniqValLinea.put(valorUnico,numLin);
                } else{
                    error = 'El Lead esta duplicado en el fichero.'; 
                    mapLinEstado.put(numLin,error);
                }
                indice++;
            }
            numLin++;
        }
        CESS_insertLeadMasivo_batch batch = new CESS_insertLeadMasivo_batch();
        batch.csvObject = csvObject;
        batch.lstLeadInsert = lstLeadInsert;
        batch.mapLinEstado = mapLinEstado;
        batch.mapUniqValLinea = mapUniqValLinea;
        batch.fields = fieldsApi;
        Database.executeBatch(batch, Integer.valueOf(System.Label.CESS_insertLeadBatchLimit));
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_END));
     
    }
 

}