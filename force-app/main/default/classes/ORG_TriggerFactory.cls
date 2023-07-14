/**********************************************************************************
* @author       Aaron Dominguez Sanchez - aaron.sanchez@salesforce.com
* @date         14/03/2018
* @group        Trigger
* @description  Used to instantiate and execute Trigger Handlers associated with sObjects.
* @Revision
**********************************************************************************/
public class ORG_TriggerFactory {

    //-- CONSTRUCTORS
    /**
     * @description Enforce non-instantiability.
     */
    private ORG_TriggerFactory() {
        throw new ORG_TriggerFactoryException('This class cannot be instantiated.');
    }

    //-- PUBLIC STATIC METHODS
    /**
     * @description Public static method to create and execute a trigger handler.
     * @param t the type of handler to instatiate.
     */
    public static void createAndExecuteHandler(final Type t) {
        //Check Trigger custom metadata type record whether it's active or not. If it does not exist then assume is inactive
        if ((ORG_AppSettingsUtils.getSetting(t.getName()) == null || !ORG_AppSettingsUtils.getSetting(t.getName()).equalsIgnoreCase('True')) &&
            !Test.isRunningTest()) return;
            //throw new ORG_TriggerFactoryException(t.getName() + ' setting does not exist, please check its custom metadata type record.');                    

        //Get handler
        final ORG_Trigger handler = getHandler(t);

        //Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null) {
            throw new ORG_TriggerFactoryException('No Trigger Handler found named: ' + t.getName());
        }

        //Execute the handler to fulfil the trigger
        execute(handler);
    }

    //-- PRIVATE METHODS
    /**
     * @description Controls the execution of the handler.
     * @param handler trigger Handler to execute.
     */
    private static void execute(final ORG_Trigger handler) {
        //Before Trigger
        if (Trigger.isBefore) {
            //Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();

            //Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete) {
                for (SObject so : Trigger.old) {
                    handler.beforeDelete(so);
                }
            }
            //Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert) {
                for (SObject so : Trigger.new) {
                    handler.beforeInsert(so);
                }
            }

            //Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate) {
                for (SObject so : Trigger.old) {
                    handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }

        //After Trigger
        else {
            //Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();

            //Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete) {
                for (SObject so : Trigger.old) {
                    handler.afterDelete(so);
                }
            }

            //Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert) {
                for (SObject so : Trigger.new) {
                    handler.afterInsert(so);
                }
            }

            //Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate) {
                for (SObject so : Trigger.old) {
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                }
            }

            //Iterate through the records undelete passing them to the handler.
            else if (Trigger.isUndelete) {
                for (SObject so : Trigger.new) {
                    handler.afterUndelete(so);
                }
            }
        }

        // Perform any post processing
        handler.andFinally();
    }

    /**
     * @description Gets the named handler.
     * @param t the class of handler to instatiate.
     * @return trigger handler if one exists. Null otherwise.
     */
    private static ORG_Trigger getHandler(final Type t) {
        //Instantiate the type
        final Object o = t.newInstance();

        //If its not an instance of ORG_Trigger return null
        if (!(o instanceOf ORG_Trigger)) {
            return null;
        }

        return (ORG_Trigger)o;
    }

    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class ORG_TriggerFactoryException extends Exception {}

}