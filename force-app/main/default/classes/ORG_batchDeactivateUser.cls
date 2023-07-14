/*
* @name: ORG_batchDeactivateUser
* @version: 1
* @creation date: 26/02/2020
* @author: Ramón García Sánchez
* @description: ORG ORG_batchDeactivateUser checks whether unused users should be deactivated or not so that sf license is unlocked               
*/
global class ORG_batchDeactivateUser implements Database.Batchable<sObject>, Database.Stateful{

    private String smyDateMaxBatch;
    private List<String> lstEmailNoDeactivateBatch;
    private Set<ID> setKeysBatch;

    public ORG_batchDeactivateUser(String sMydateMax, List<String> lstEmailNoDeactivate, Set<ID> setKeys) {
        smyDateMaxBatch = sMydateMax;
        lstEmailNoDeactivateBatch = lstEmailNoDeactivate;
        setKeysBatch = setKeys;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('smyDateMaxBatch'+smyDateMaxBatch);
        system.debug('lstEmailNoDeactivate'+lstEmailNoDeactivateBatch);
        system.debug('setKeys'+setKeysBatch);
        string query = 'SELECT Id FROM User '
            + 'WHERE (((LastLoginDate <= ' + smyDateMaxBatch + ' AND isActive=True AND (email NOT IN :lstEmailNoDeactivateBatch)) '
            + 'OR (CreatedDate <= ' + smyDateMaxBatch + '  AND LastLoginDate = NULL AND isActive=True AND (email NOT IN :lstEmailNoDeactivateBatch))) AND (profileId in :setKeysBatch))';
        
        If(Test.isRunningTest()){
            query += ' LIMIT 100';
        }
    	return Database.getQueryLocator(query);
    }

    
    global void execute(Database.BatchableContext BC, List<User> users) {
        System.debug('users size ' + users.size());
        deactivateUsers(users);  
    }   

    global void finish(Database.BatchableContext BC) {
    }
    
    /*
* @creation date: 26/02/2020
* @author: Ramón García Sánchez
* @description: deactivateUsers() checks whether unused users should be deactivated or not so that sf license is unlocked
*/
    private static void deactivateUsers(List<User> users){
        
        for (User user : users){
            System.debug('DeactiveUser: Desactivamos el usuario ' + user.Id);
            user.isActive = false;
        }  
        try
        {
            Database.SaveResult[] results = Database.update(users, false);  
            for(Integer i=0; i<results.size(); i++){
                if (!results.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = results.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();                    
                    System.Debug('Error al desactivar el usuario: '+ failedDML);                   
                }  
            }                     
        }
        catch (Exception ex){
            system.debug('ORG_batchDeactivateUser');
        }
        
    }
    
}