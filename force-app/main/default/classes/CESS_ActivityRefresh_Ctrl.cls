public class CESS_ActivityRefresh_Ctrl {

    @AuraEnabled
    public static List<Task> getTasks(String parentId) {
        if ( parentId.startsWith('006') ) {
            return [select cti_error__c from task where whatid=:parentId];
        } else {
            if ( parentId.startsWith('00Q') ) {
            	return [select cti_error__c from task where whoid=:parentId];
            }
        }
        return new List<Task>();
    }
    
}