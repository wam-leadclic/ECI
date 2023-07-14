/********************************************************************************** 
* @author       Francsico José Pérez
* @date         20/06/2020
* @description  Trigger helper class fot the Opportunity entity.
* @Revision
**********************************************************************************/

public with sharing class CESS_OpportunityTriggerHelper {

    public static void selectOppTaskToUpdate(Map<ID, List<Task>> taskMap) {

        List<String> opptysIds = new List<String>();
        for (Sobject to: Trigger.new) {
            Opportunity o = (Opportunity) to;  
            opptysIds.add(o.Id);
        }
        
        if ( opptysIds.size() > 0 ) {
            List<Task> allScheduledTasks = [select id, whatid from task where whatid in :opptysIds and type='Schedule Call' and status != 'Completed'];
            for ( Task t: allScheduledTasks ) {               
                List<Task> currentList = taskMap.get(t.WhatId);
                if ( currentList == null ) {
                    currentList = new List<Task>();
                }
                currentList.add(t);
                taskMap.put(t.WhatId, currentList);
            }
        } 

    }

    public static void checkTaskToDelete(Map<ID, List<Task>> taskMap, Opportunity o,List<Task> totalTasksToDelete){
        
        if ( o.isClosed == true ) { //TODO: validate if there are more cases that should trigger the deletion of scheduled calls            
            List<Task> opptyTasks = taskMap.get(o.Id);
            if ( opptyTasks != null ) {
                for ( Task t: opptyTasks ) {
                    t.Status = 'Completed';
                    totalTasksToDelete.add(t);
                }
            }
        }
    }

}