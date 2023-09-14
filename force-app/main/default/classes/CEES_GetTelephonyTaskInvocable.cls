/*
@author LeadClic Solutions S.L.
@date 23/09/2021	
@description lightning component's GenesysEventController
a SF.

<pre>
FECHA               AUTOR           ACCION
23/09/2021			LCS - NMN		Creación de la clase
*/

global with sharing class CEES_GetTelephonyTaskInvocable {
	
    global class GetTaskRequest {
        
        @InvocableVariable(
            label = 'Owner ID'
            description = 'ID of user that has created the task'
            required = true
        )
        global ID ownerId;

        @InvocableVariable(
            label = 'Lead Id'
            description = 'Lead Id'
            required = false
        )
        global ID leadId;
    }
    
    global class GetTaskResult {

        @InvocableVariable( label = 'Task ID' )
        global ID taskId;
    }
    
    @InvocableMethod(label = 'GetTelephonyTask')
    global static List<GetTaskResult> getTaskId(List<GetTaskRequest> taskRequest) {
        
        List<task> idList = new List<task>();
        Id recordId=taskRequest.get(0).leadId;
        Id ownerId=taskRequest.get(0).ownerId;
        List<GetTaskResult> result=new List<GetTaskResult>();
        
        Long startTime = DateTime.now().getTime();
		Long finishTime = DateTime.now().getTime();
       
		while ((finishTime - startTime) < 1000) {
   			 //sleep for 9s
    		finishTime = DateTime.now().getTime();
		}
       
        integer i = 0;
        while(idList.size()==0 && i<98){
            
        	idList = [SELECT Id,CreatedDate,WhoId,CampaignMemberId__c, CampanaInboundIVR__c, CallDurationInSeconds,Station__c from task  where  OwnerId=:ownerId  order by createddate desc LIMIT 1];   
            i++;
        }
       	
        
        if(idList.size()>0) {
            GetTaskResult tarea= new GetTaskResult();
        	tarea.taskId=idList[0].id;
        	result.add(tarea); 
            return result;
        } else {
            return null;
        }    
        
    }
    
    
}