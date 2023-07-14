/**
@description
<pre>
Clase Ctrl para planificación de Tareas tipo Llamada (crear, cancelar, consultar ) desde Lead u Oportunidad,  </br>

FECHA       AUTOR       DESCRIPCION<br/>
26/08/2020  LCS JCB	   	Modificacion de método createTaskFromLead para conseguir 2.2.23 (doc. técnico), se añade param de entrada id Miembro de Campaña CTI
                        (campMemberId) y se utiliza en el campo CampaignMemberId__c al crear Tarea.
01/08/2022  LCS MKB	   	Se añade la posibilidad de registrar una llamada planificada para contactos sin oportunidad asociada
02/08/2022  LCS JCL	   	Revisión código
</pre>
@author Leadclic Solutions
@date 26/04/2022
*/
public without sharing class CESS_ScheduleTaskLWCCtrl {

    // ---------------------------- CONSTANTS ----------------------------
    @testVisible
    private static final String TASK_PRIORITY_NORMAL = 'Normal';
    @testVisible
    private static final String TASK_STATUS_NOT_STARTED = 'Not Started';
    @testVisible
    private static final String TASK_SUBJECT = 'Llamada Planificada';
    @testVisible
    private static final String TASK_TYPE = 'Schedule Call';

    @AuraEnabled
    public static List<Task> obtainRecordTasks( Id relatedTo, String obj ) {

        List<Task> lstTasks = new List<Task>();
        String query = 'SELECT Id, ActivityDate, CESS_Fecha_Planificada__c, Status FROM Task WHERE Status != \'Cancelled\' AND Status != \'Completed\' AND ';
        if( obj == 'Lead' ) {
            query += 'WhoId = \'' + relatedTo + '\'';
        } else if( obj == 'Opportunity' ) {
            query+= 'WhatId = \'' + relatedTo + '\'';
        } else if( obj == 'Contact' ) {
            query+= 'WhoId = \'' + relatedTo + '\'';
        }
        lstTasks = Database.query(query);
        return lstTasks;

    }

    @AuraEnabled
    public static List<Task> obtainTasksInCenterForThatDay( String day, String centro ) {

        List<Task> lstTasks = new List<Task>();
        String query = 'SELECT Id, ActivityDate, CESS_Fecha_Planificada__c FROM Task WHERE ActivityDate = ' + day + ' AND CESS_Fecha_Planificada__c != null' +
                        ' AND CESS_AreaUserAssigned__c = \'' + centro + '\'';

        lstTasks = Database.query(query);
        return lstTasks;

    }

    @AuraEnabled(cacheable = true)
    public static List<PlanificacionLlamadas__c> getPlanificacion( String cessArea ) {

        List<PlanificacionLlamadas__c> lstPlan = new List<PlanificacionLlamadas__c>();
        String query = 'SELECT CESS_Type__c,CESS_Date__c, CESS_DayOfWeek__c, CESS_LlamadasP0900__c, CESS_LlamadasP1000__c, CESS_LlamadasP1100__c,'+
        'CESS_LlamadasP1200__c, CESS_LlamadasP1300__c,CESS_LlamadasP1400__c, CESS_LlamadasP1500__c, CESS_LlamadasP1600__c, CESS_LlamadasP1700__c, CESS_LlamadasP1800__c,'+
        'CESS_LlamadasP1900__c, CESS_LlamadasP2000__c FROM PlanificacionLlamadas__c where CESS_Area__c = \'' + cessArea + '\'';

        lstPlan = Database.query(query);
        return lstPlan;

    }

    @AuraEnabled
    public static void cancelarTask( Id relatedTo, String obj ) {

        List<Task> lstTasks = new List<Task>();
        lstTasks = obtainRecordTasks( relatedTo, obj );
        for( Task t : lstTasks ) {
            t.Status = 'Cancelled';
        }

        update lstTasks;

    }

    //Para tareas desde Lead con el campo CampaignMemberId__c relleno
    @AuraEnabled
    public static void createTaskFromLead( Integer year, Integer mes, Integer dia, Integer hora, Integer minutos, Id leadId, String campMemberId ) {

        DateTime myDateTime = DateTime.newInstance( year, mes, dia, hora, minutos, 0 );
        Task t = new Task();
        t.CESS_Fecha_Planificada__c = myDateTime;
        t.IsReminderSet = false;
        t.Priority = TASK_PRIORITY_NORMAL;
        t.Status = TASK_STATUS_NOT_STARTED;
        t.Subject = TASK_SUBJECT;
        t.Type = TASK_TYPE;
        t.WhoId = leadId;
        t.CampaignMemberId__c = campMemberId;
        insert t;

    }

    @AuraEnabled
    public static void createTaskFromOpp( Integer year, Integer mes, Integer dia, Integer hora, Integer minutos, Id oppId, Id perContactId ) {

        DateTime myDateTime = DateTime.newInstance( year, mes, dia, hora, minutos, 0 );
        Task t = new Task();
        t.CESS_Fecha_Planificada__c = myDateTime;
        t.IsReminderSet = false;
        t.Priority = TASK_PRIORITY_NORMAL;
        t.Status = TASK_STATUS_NOT_STARTED;
        t.Subject = TASK_SUBJECT;
        t.Type = TASK_TYPE;
        t.WhatId = oppId;
        t.WhoId = perContactId;
        insert t;

    }

    @AuraEnabled
    public static void createTaskFromContact( Integer year, Integer mes, Integer dia, Integer hora, Integer minutos, Id contactId, String campMemberId ) {

        DateTime myDateTime = DateTime.newInstance( year, mes, dia, hora, minutos, 0 );
        Task t = new Task();
        t.CESS_Fecha_Planificada__c = myDateTime;
        t.IsReminderSet = false;
        t.Priority = TASK_PRIORITY_NORMAL;
        t.Status = TASK_STATUS_NOT_STARTED;
        t.Subject = TASK_SUBJECT;
        t.Type = TASK_TYPE;
        t.WhoId = contactId;
        t.CampaignMemberId__c = campMemberId;
        insert t;

    }

}