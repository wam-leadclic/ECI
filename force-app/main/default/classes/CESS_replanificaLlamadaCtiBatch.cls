global class CESS_replanificaLlamadaCtiBatch implements Database.AllowsCallouts, Database.Batchable<sObject>{

    // start
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, WhoId, WhatId, Status, Type, AccountId, ReminderDateTime, OwnerId, owner_ctiuser__c, cti_error__c, Account.Phone, Account.PersonMobilePhone FROM Task WHERE Status = \'Not Started\' and Type = \'Schedule Call\' and ReminderDateTime = TODAY LIMIT 45';
		return Database.getQueryLocator(query);
	}

    // execute
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Task> tsList = (List<Task>)scope;
        if (tsList.isEmpty()) return;

        for (Task t : tsList) {
            System.debug('Task a procesar: ' + t.id);
            CESS_ctiResponseDto response = ORG_LeadLogic.replanificaLlamadaCTI(t);

            if (ORG_LeadLogic.getErrorCtiResponse(response.message)){
                t.cti_error__c = response.message;
            }else{  //no hay error, update task y siguiente.
                t.Status = 'Completed';
            }
        }//for

        try{
            update tsList;
        }catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }

    // finish
	global void finish(Database.BatchableContext BC) {
	}

}