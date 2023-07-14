/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         23/04/2020
* @description  DTO for the bulkified request of CTI Client
* @Revision		SER   10/01/2022    UnscheduledCalls method created in order to update the opp and lead status to 'U'
**********************************************************************************/
public class CESS_BulkifiedCTIRequestDto {
    
    public class InsertCampaingCalls {
        public List<RequestUpsertContact> requestInsertContactList {get; set;}

        public InsertCampaingCalls() {
            requestInsertContactList = new List<RequestUpsertContact>();
        }
                       
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this.requestInsertContactList, suppressApexObjectNulls);
        }
    }
    
    public class InsertScheduleCalls {
        public List<RequestUpsertContact> requestInsertContactList {get; set;}

        public InsertScheduleCalls() {
            requestInsertContactList = new List<RequestUpsertContact>();
        }
                       
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this.requestInsertContactList, suppressApexObjectNulls);
        }
    }
    
    public class DeleteCalls {
        public List<RequestDeleteContact> requestDeleteContactList {get; set;}
		
        public DeleteCalls() {
            requestDeleteContactList = new List<RequestDeleteContact>();
        }
                       
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this.requestDeleteContactList, suppressApexObjectNulls);
        }
    }
    public class UnscheduledCalls {
        public List<RequestUnscheduledContact> requestUnscheduledContactList {get; set;}
		
        public UnscheduledCalls() {
            requestUnscheduledContactList = new List<RequestUnscheduledContact>();
        }
                       
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this.requestUnscheduledContactList, suppressApexObjectNulls);
        }
    }
    
    public class UpdateCalls {
        public List<RequestUpsertContact> requestUpdateContactList {get; set;}

        public UpdateCalls() {
            requestUpdateContactList = new List<RequestUpsertContact>();
        }
                       
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this.requestUpdateContactList, suppressApexObjectNulls);
        }
    }
    
    public class RequestUpsertContact {
        public String front_code {get; set;}
        public String campaign_name {get; set;}
        public List<String> columns {get; set;}
        public List<String> values {get; set;}
        public String column_filter {get; set;}
        public ScheduledPlanningCall scheduled_planning_call {get; set;}
        
        public RequestUpsertContact() {
            columns = new List<String>();
            values = new List<String>();
        }
        
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this, suppressApexObjectNulls);
        } 
    }
    
    public class RequestDeleteContact {
        public String front_code {get; set;}
        public String campaign_name {get; set;}
        public List<String> columns {get; set;}
        public List<String> values {get; set;}
        public String column_filter {get; set;}
        
        public RequestDeleteContact() {
            columns = new List<String>();
            values = new List<String>();
        }
        
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this, suppressApexObjectNulls);
        } 
    }
/////////////////////////////////
  public class RequestUnscheduledContact {
        public String front_code {get; set;}
        public String campaign_name {get; set;}
        public List<String> columns {get; set;}
        public List<String> values {get; set;}
        public String column_filter {get; set;}
        
        public RequestUnscheduledContact() {
            columns = new List<String>();
            values = new List<String>();
        }
        
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this, suppressApexObjectNulls);
        } 
    }
//////////////////////////////////
    public class ScheduledPlanningCall {
        public String phone_number {get; set;}
        public String agent_id {get; set;}
        public String sched_time {get; set;}
    }
    
    public static InsertCampaingCalls deserializeInsertCampaingCalls(String json) {
        return (InsertCampaingCalls) System.JSON.deserialize(json, InsertCampaingCalls.class);
    }
    
    public static InsertScheduleCalls deserializeInsertScheduleCalls(String json) {
        return (InsertScheduleCalls) System.JSON.deserialize(json, InsertScheduleCalls.class);
    }
    
    public static DeleteCalls deserializeInsertDeleteCalls(String json) {
        return (DeleteCalls) System.JSON.deserialize(json, DeleteCalls.class);
    }
    public static UnscheduledCalls deserializeInsertUnscheduledCalls(String json) {
        return (UnscheduledCalls) System.JSON.deserialize(json, UnscheduledCalls.class);
    }
    
    public static UpdateCalls deserializeIUpdateCalls(String json) {
        return (UpdateCalls) System.JSON.deserialize(json, UpdateCalls.class);
    }
    
    
}