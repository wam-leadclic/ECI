/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         24/04/2020
* @description  Helper class to make the bulkified callout of the events in a Queueable
* @Revision
**********************************************************************************/
public class CESS_BulkifiedCTIIntegrationQueueable implements Queueable, Database.AllowsCallouts{

    List<CESS_Integration_Event__e> events {get; set;}
    
    public CESS_BulkifiedCTIIntegrationQueueable(List<CESS_Integration_Event__e> events) {
        this.events = events;
    }
    
    public void execute(QueueableContext context) {

        CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
        bctil.insertCallsFromIntegrationEvents(this.events);
        
    }
        
    
}