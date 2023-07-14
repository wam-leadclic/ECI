({
	doInit : function(component, event, helper) {
        
	},
    
    doRecordUpdated : function(component, event, helper) {
        var logRecord = component.get("v.logRecord");
        console.log(logRecord);
        var recordId = logRecord.identifier__c;
        if(recordId) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": recordId
            });
            navEvt.fire();            
        }

	}
})