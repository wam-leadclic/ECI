/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         23/04/2020
* @description  DTO for the bulkified response of CTI Client
* @Revision
**********************************************************************************/
public class CESS_BulkifiedCTIResponseDto {
    
    public class InsertCampaingCalls {
        public Response response {get; set;}
                
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this, suppressApexObjectNulls);
        }
    }
    
    public class InsertScheduleCalls {
		public Response response {get; set;}
                
        public String serialize(Boolean suppressApexObjectNulls ) {
            //return '{"lst_contact":'+ JSON.serialize(this, suppressApexObjectNulls) +'}';FPEREZ. no se necesita porque cambia en función del método que se invoca
            return JSON.serialize(this, suppressApexObjectNulls);
        }
    }
    
    public class UnscheduledCalls {
		public Response response {get; set;}
                
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this, suppressApexObjectNulls);
        }
    }
    public class DeleteCalls {
		public Response response {get; set;}
                
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this, suppressApexObjectNulls);
        }
    }
    
    public class UpdateCalls {
		public Response response {get; set;}
                
        public String serialize(Boolean suppressApexObjectNulls ) {
            return JSON.serialize(this, suppressApexObjectNulls);
        }
    }

    public class Response {
        public String details {get; set;}
        public String request_id {get; set;}
        public String message {get; set;}
        public String total {get; set;}
        public String total_ok {get; set;}
        public String total_error {get; set;}
        public List<String> results {get; set;}
        
        public Response() {
            results = new List<String>();
        }

    }

    public static InsertCampaingCalls deserializeInsertCampaingCalls(String json) {
        try {
            Response res = (Response) deserializeResponse(json);
            InsertCampaingCalls ret = new InsertCampaingCalls();
            ret.response = res;
            return ret;
        } catch (Exception e) {
            System.debug('ERROR parsing response: '+e);
            return null;
        }
    }
    
   	public static InsertScheduleCalls deserializeInsertScheduleCalls(String json) {
		try {

            Response res = (Response) deserializeResponse(json);
            InsertScheduleCalls ret = new InsertScheduleCalls();
            ret.response = res;
            return ret;
        } catch (Exception e) {
            System.debug('ERROR parsing response: '+e);
            return null;
        }
 	}
    
    public static DeleteCalls deserializeDeleteCalls(String json) {
        try {
            Response res = (Response) deserializeResponse(json);
            DeleteCalls ret = new DeleteCalls();
            ret.response = res;
            return ret;
        } catch (Exception e) {
            System.debug('ERROR parsing response: '+e);
            return null;
        }
    }
    
    public static UpdateCalls deserializeUpdateCalls(String json) {
        try {
            Response res = (Response) deserializeResponse(json);
            UpdateCalls ret = new UpdateCalls();
            ret.response = res;
            return ret;
        } catch (Exception e) {
            System.debug('ERROR parsing response: '+e);
            return null;
        }
    }
    public static UnscheduledCalls deserializeUnscheduledUpdateCalls(String json) {
        try {
            Response res = (Response) deserializeResponse(json);
            UnscheduledCalls ret = new UnscheduledCalls();
            ret.response = res;
            return ret;
        } catch (Exception e) {
            System.debug('ERROR parsing response: '+e);
            return null;
        }
    }

    private static Response deserializeResponse(String json) {
        //FPEREZ. Al añadir la etiqueta response en la respuesta se cambia el modelo de clases. 
        //Lo suprimimos aqui del mensaje recibido.
        json = json.replace('{\"response\":', '');
        json = json.substring(0,json.length()-1);
        return (Response) System.JSON.deserialize(json, Response.class);
    }
    
    

}