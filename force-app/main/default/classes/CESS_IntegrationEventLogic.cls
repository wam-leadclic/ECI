/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         03/06/2020
* @description  Trigger Handler for the CESS_Integration_Event__e
* @Revision
**********************************************************************************/
public class CESS_IntegrationEventLogic {

    public static void handleEvents(List<CESS_Integration_Event__e> events) {                  
        System.enqueueJob(new CESS_BulkifiedCTIIntegrationQueueable(events));                  
    }
    
}