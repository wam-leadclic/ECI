/*
* @name: ORG_scheduledDeactivateUser
* @version: 1
* @creation date: 26/02/2020
* @author: Ramón García Sánchez
* @description: ORG deactivates users that did not login into SF for the last 2,5 months
*               there's a notification mail that is sent if User did not login for the last 2 months                
*/
global class ORG_scheduledDeactivateUser implements Schedulable {
    
    global void execute(SchedulableContext sc){    
        deactivate();
    }    
    /*
	* @creation date: 26/02/2020
	* @author: Ramón García Sánchez
	* @description: deactivate() deactivates users that did not login into SF for the last 2,5 months (call ORG_batchDeactivateUser)
	*               there's a notification mail that is sent if User did not login for the last 2 months 
	*/
    public static void deactivate(){
    	Integer daysFromDeactivate = Integer.valueOf(ORG_AppSettingsUtils.getSetting('ORG_daysDeactivateUsers'));
        String emailNoDeactivate = ORG_AppSettingsUtils.getSetting('ORG_noDeactivateUsers');        
        String profiles = ORG_AppSettingsUtils.getSetting('ORG_profilesDeactivate');           
        List<String> lstEmailNoDeactivate = emailNoDeactivate.split(',');
        List<String> lstProfiles = profiles.split(',');     
        System.debug('daysFromDeactivate: ' + daysFromDeactivate);
        System.debug('lstEmailNoDeactivate: ' + lstEmailNoDeactivate);
        System.debug('lstProfiles: ' + lstProfiles);             
        Datetime myDT = DateTime.now();
        Datetime myDTMax = myDT.addDays(daysFromDeactivate);    
        //El schedule ha de ejecutarse diariamente para que avise sucesivamente
        
        Map<Id,Profile> profileIds = new Map<id,Profile>([SELECT Id FROM Profile where name IN :lstProfiles]);
		//SET<ID> profileKeys = profileIds.Keyset();
        System.debug('ProfileIds: ' + profileIds);
        //SI LOS USUARIOS ESTAN MAS DE 75 DIAS SE DESACTIVA
        String sMydateMax = myDTMax.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        Set<ID> setKeys = profileIds.Keyset();
        System.debug('setKeys: ' + setKeys);    
        ORG_batchDeactivateUser osdu = new ORG_batchDeactivateUser(sMydateMax, lstEmailNoDeactivate, setKeys);
        Database.executeBatch(osdu,200);      
    }    
}