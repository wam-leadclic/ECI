/**
@description
<pre>Clase batch schedulable para la actualización de Miembros de campaña cuyo estado sea Working
y no hayan sufrido modificación durante un tiempo determinado (metadato)</br>
FECHA       AUTOR       DESCRIPCION<br/>
30/03/2023  LCS-JCB     Creación
</pre>
@author Leadclic Solutions
@date 30/03/2023             
*/
public with sharing class CESS_CampaignMemberBatchStatus implements Database.Batchable<sObject>, Schedulable {
    Datetime DIFERENCIA_HORAS;
    public CESS_CampaignMemberBatchStatus() {
    }

    /********* QUERY ******/
    private String getQueryString(){
        ORG_ApplicationSettings__mdt hoursSinceLastActivity = ORG_ApplicationSettings__mdt.getInstance('CESS_HorasInactividadCMWorking');
        String query;
        if(Test.isRunningTest()){
            query = 'select Id, LeadId, RelatedCTICampaignMemberId__c, Status, Result__c, LastModifiedDate from CampaignMember where Status = \'Working\' and Lead.Id != null and lead.IsConverted = false';
        }else{
            if(hoursSinceLastActivity != null){
                DIFERENCIA_HORAS = datetime.now().addHours(Integer.valueOf(hoursSinceLastActivity.Value__c)*-1);
                System.debug('valor:'+String.valueOf(DIFERENCIA_HORAS));
            query = 'select Id, LeadId, RelatedCTICampaignMemberId__c, Status, Result__c, LastModifiedDate from CampaignMember where Status = \'Working\' and RecordType.Name = \'Marketing\' and Lead.Id != null and lead.IsConverted = false and LastModifiedDate < :DIFERENCIA_HORAS';
            }
        }
        return query;
        
    }

    /********* START ******/
    public Iterable<sObject> start(Database.BatchableContext BC){
        String query = getQueryString();
        System.debug('Query batch:'+query);
        if(query != null){
            return Database.getQueryLocator(getQueryString());
        }else{
            return new List<SObject>();
        }
    }

    /********* EXECUTE ******/
    public void execute(Database.BatchableContext info, List<CampaignMember> records){
        List<CampaignMember> cmsToUpdate = new List<CampaignMember>();
        List<Id> idsCMCTIRelationed = new List<Id>();
        Set<CampaignMember> cmsToSend = new Set<CampaignMember>();
        //Se recorren los registros devueltos por la iteración del batch
        for(CampaignMember i : records){
            i.Status = 'Not contacted';
            i.Result__c = 'No Contesta Enviar Email';
            cmsToUpdate.add(i);
            idsCMCTIRelationed.add(i.RelatedCTICampaignMemberId__c);
        }
        if(cmsToUpdate.size()>0){
            //update cmsToUpdate;
            List<Database.SaveResult> SRWorking = Database.update(cmsToUpdate, false);
            System.debug('Result Update CMs Working:'+ SRWorking );
        }
        //Búsqueda si existen CM MKT en estado New con el mismo CM CTI relacionado, para proceder a marcar su envío
        for(CampaignMember cmNew : [SELECT Id,RelatedCTICampaignMemberId__c  FROM CampaignMember WHERE RecordType.Name = 'Marketing' and Status = 'New' and RelatedCTICampaignMemberId__c IN :idsCMCTIRelationed ]){
            CampaignMember cm = new CampaignMember();
            cm.Id = cmNew.RelatedCTICampaignMemberId__c;
            cm.CTISend__c = true;
            cmsToSend.add(cm);
        }
        if(cmsToSend.size()>0){
            //update cmsToSend;
            List<CampaignMember> cmsSend = new List<CampaignMember>();
            for(CampaignMember c : cmsToSend){
                cmsSend.add(c);
            }
            List<Database.SaveResult> SRNew = Database.update(cmsSend, false);
            System.debug('Result Update CMs News:'+ SRNew );
        }
    }

    /********* FINISH ******/
    public void finish(Database.BatchableContext info){
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CESS_CampaignMemberBatchStatus(), 100);
    }

}