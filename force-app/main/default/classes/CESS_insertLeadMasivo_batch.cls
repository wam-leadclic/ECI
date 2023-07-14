/**********************************************************************************
* @name         	CESS_insertLeadMasivo_batch
* @version			1.0
* @creation date    10/11/2020
* @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @description  	Apex Class with the batch to insert Lead
* @group        	Batch
**********************************************************************************/
global class CESS_insertLeadMasivo_batch implements Database.Batchable<sObject>, Database.Stateful {

    /* The name of the class */
    private static String CLASS_NAME = CESS_insertLeadMasivo_batch.class.getName();
    /*CONSTANTS*/
   	private final static String DEFAULT_HEADER = 'Linea,Nombre,Apellido,Campaña CTI ,Medio,Resultado,Numero Lead,Error';
	/*VARIABLES*/
    global CESS_csvObject csvObject {get;set;}
    global List<Lead> lstLeadInsert {get;set;}
    global Map<Integer, String> mapLinEstado {get;set;}
    global Map<String, Integer> mapUniqValLinea {get;set;}
    global List<String> fields{get;set;}
   	global Set<Id> setIdsLead {get;set;}
    global Map<Integer,Id> mapLeadInserted {get;set;}
    /* (non-Javadoc)
     *  @see Batchable#start()
     */
     public List<Lead> start(Database.BatchableContext bc) {
        String METHOD_NAME = 'start';
         mapLeadInserted = new Map<Integer,Id>();
        setIdsLead = new Set<Id>();
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_INIT));
      	System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'lstLeadInsert size: ' + lstLeadInsert.size()));
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_END));
        return lstLeadInsert;
    }
    
     /* (non-Javadoc)
     *  @see Batchable#execute()
     */
    global void execute(Database.BatchableContext bc, List<Lead> lstLeadInsert) { 
        String METHOD_NAME = 'execute';
       
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_INIT));
        if (lstLeadInsert.size() > 0) {
            Integer numLin;
            System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'lstLeadInsert size: ' + lstLeadInsert.size())); 
            Database.SaveResult[] srList = System.Database.insert(lstLeadInsert, false);
            for (Integer i = 0; i < lstLeadInsert.size(); i++) {
                numLin = null;
                Database.SaveResult s = srList[i];
                Lead origRecord = lstLeadInsert[i];
                String valorUnico = obtenerValorUnico(origRecord,fields);
                if(mapUniqValLinea.get(valorUnico) != null) numLin = mapUniqValLinea.get(valorUnico);
                System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'valorUnico: ' + valorUnico + 'linea: ' + numLin));
                if (!s.isSuccess()) {
                    String strError = ORG_Constantes.MSG_EMPTY;
                    for(Database.Error err : s.getErrors()) {
                        strError += err.getMessage(); 
                    }
                    System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'Error insert: ' + origRecord.FirstName + ', ' + strError));
                    if(numLin != null) mapLinEstado.put(numLin, strError);
                 } else{
                     System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'Succes insert: ' + s.getId() + 'numLin: ' +numLin));
                     if(numLin != null){
                         mapLeadInserted.put(numLin,s.getId());
                         setIdsLead.add(s.getId());
                     }
                }
			}
        }
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_END));
    }
  	
    /* (non-Javadoc)
     *  @see Batchable#finish()
     */
    global void finish(Database.BatchableContext bc) {
        String METHOD_NAME = 'finish';
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_INIT));
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'setIdsLead.size()'+setIdsLead.size()));
       	CESS_csvObject csvOut = createCsvObj(csvObject, mapLinEstado, setIdsLead,mapLeadInserted);
        String labelEmailAdresses =  UserInfo.getUserEmail();
        String labelEmailCCAdresses = System.Label.CESS_lbl_procMasLeadEmailAddcc;
        String nameCsvOut = System.Label.CESS_proMasivoLeadNameCsv;
        String subject = System.Label.CESS_proMasivoLeadSubjectEmail;
        String body = System.Label.CESS_proMasivoLeadBodyEmail;
        CESS_helperEmail.createAndSendEmail(labelEmailAdresses, labelEmailCCAdresses, subject, body, nameCsvOut, csvOut);
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_END));
    }
	 /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    10/11/2020
    * @description  		Create a out csv object
    * @param csvObject		the in csv object
    * @param mapLinEstado	the map with the line and states
    * @param setIdsLeads		the set of Ids Lead
    * @return				the out csv object 
    **********************************************************************************/
    private static CESS_csvObject createCsvObj(CESS_csvObject csvObject, Map<Integer,String> mapLinEstado, Set<Id> setIdsLeads,Map<Integer,Id>mapLeadInserted) {
        String METHOD_NAME = 'createCsvResult';
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_INIT));
        List<List<String>> lines = new List<List<String>>();
        List<String> lstStr = new List<String>();
        Map<Id, String> mapLead = new Map<Id, String>();
        Map<Id, String> mapName = new Map<Id, String>();
        Map<Id, String> mapLastName = new Map<Id, String>();
        Map<Id, String> mapCampaignCTI = new Map<Id, String>();
        Map<Id, String> mapMedio = new Map<Id, String>();
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'setIdsLeads: ' + setIdsLeads.size()));
        for (Lead ld : [SELECT Id,lead_number__c,FirstName,LastName,campaign_cti__c,source_type__c FROM Lead WHERE Id IN :setIdsLeads]) {
            mapLead.put(ld.id, ld.lead_number__c);
            String FirstName = ld.FirstName <> null && String.isNotBlank(ld.FirstName) ? ld.FirstName : '';
            String LastName = ld.LastName <> null && String.isNotBlank(ld.LastName) ? ld.LastName : '';
            String campCTI = ld.campaign_cti__c <> null && String.isNotBlank(ld.campaign_cti__c) ? ld.campaign_cti__c : '';
            String Medio = ld.source_type__c <> null && String.isNotBlank(ld.source_type__c) ? ld.source_type__c : '';
            mapName.put(ld.Id,FirstName);
            mapLastName.put(ld.Id,LastName);
            mapCampaignCTI.put(ld.Id,campCTI);
            mapMedio.put(ld.Id,Medio);
        }
        Integer numLine = 1;
        for (List<String> line : csvObject.lines) { 
            String ldNumber = ORG_Constantes.MSG_EMPTY;
            String ldName = ORG_Constantes.MSG_EMPTY;
            String ldLastName = ORG_Constantes.MSG_EMPTY;
            String ldCampCTI = ORG_Constantes.MSG_EMPTY;
            String ldMedio = ORG_Constantes.MSG_EMPTY;
            String estado = ORG_Constantes.MSG_OK;
            String errorMsg = ORG_Constantes.MSG_EMPTY;
            if (mapLinEstado.get(numLine) != ORG_Constantes.MSG_OK) {
                estado = ORG_Constantes.MSG_ERROR;
                errorMsg = mapLinEstado.get(numLine);
            }
            System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'numLin: ' + numLine + 'mapLeadInserted: '+ mapLeadInserted.get(numLine)));
            if(mapLeadInserted.get(numLine) <> null){
                Id idLead = mapLeadInserted.get(numLine);
                ldNumber = mapLead.get(idLead);
                ldName = mapName.get(idLead);
                ldLastName = mapLastName.get(idLead);
                ldCampCTI = mapCampaignCTI.get(idLead);
                ldMedio = mapMedio.get(idLead);
            }
            
            lstStr = new List<String>{String.valueof(numLine),ldName,ldLastName,ldCampCTI,ldMedio,estado,ldNumber,errorMsg};
            lines.add(lstStr);
            numLine++;
        }
        String labelsHeaders = System.Label.CESS_lbl_headerMasivoCargarLead;
        List<String> lstColumnas = new List<String>();
        if(!String.isEmpty(labelsHeaders)){
            lstColumnas = labelsHeaders.split(CESS_Constantes.CESS_SEP);
        }else{
            lstColumnas =  DEFAULT_HEADER.split(CESS_Constantes.CESS_SEP);        
        }
        List<CESS_csvHeader> headers = new List<CESS_csvHeader>();
        for(String header : lstColumnas) {
            headers.add(new CESS_csvHeader(header));
        }
        CESS_csvObject csvObj = new CESS_csvObject(headers, lines);
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_END));
        return csvObj;
    }
     /**********************************************************************************
    * @author       		María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    	10/11/2020
    * @description  		create a unique value for each Lead based on the fields inserted 
    * @param Lead			the Lead inserted
    * @param fields			List of the fields inserted for each Lead
    * @return				the out csv object 
    **********************************************************************************/
    private static String obtenerValorUnico(Lead ld, List<String> fields){
        String METHOD_NAME = 'obtenerValorUnico';
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_INIT));
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'fields.size(): ' + fields.size()));
        String valorUnico = ORG_Constantes.MSG_EMPTY;
        for(String field: fields){
            System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, 'field: ' + field +'lead field:'+ ld.get(field)));
            if(ld.get(field) <> null ){
                valorUnico += ld.get(field);
            }
        }
        
        System.debug(ORG_helperDebug.getInfo(CLASS_NAME, METHOD_NAME, ORG_Constantes.MSG_END));
        return valorUnico;
    }
}