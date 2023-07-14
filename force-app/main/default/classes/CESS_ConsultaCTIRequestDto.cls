/********************************************************************************** 
* @author       Francisco José Pérez - franciscojose.perez@salesforce.com
* @date         12/06/2019
* @group        Integrations
* @description  DTO for the consulta request of CTI Client
* @Revision
**********************************************************************************/
public class CESS_ConsultaCTIRequestDto {

   //-- CONSTANTS
    private static final String CESS_CTI_FRONTCODE = ORG_AppSettingsUtils.getSetting('CESS_CTI_FRONTCODE'); 
    private static final String CESS_CTI_COLUMNFILTER = ORG_AppSettingsUtils.getSetting('CESS_CTI_COLUMNFILTER'); 
    private static final String CESS_CTIPLAN_CAMPAIGN = ORG_AppSettingsUtils.getSetting('CESS_CTIPLAN_CAMPAIGN'); 

    @AuraEnabled public String front_code;
    @AuraEnabled public String campaign_name;
    @AuraEnabled public List <String> columns;
    @AuraEnabled public List <String> values;
    @AuraEnabled public String column_filter;
    @AuraEnabled public scheduled_planning_call scheduled_planning_call;

    public CESS_ConsultaCTIRequestDto(final String campaign_name,
                                      final List < String > columns, 
                                      final List <String> values) {
        this.front_code = CESS_CTI_FRONTCODE;
        this.campaign_name = campaign_name;
        this.columns = columns;
        this.values = values;
        this.column_filter = CESS_CTI_COLUMNFILTER;
        this.scheduled_planning_call = new scheduled_planning_call(new List <String> {'','',''});
    }

    public CESS_ConsultaCTIRequestDto(final List < String > columns, 
                                      final List <String> values,
                                      final List<String> sched,
                                      String CTIcampaign) {
        
        this.front_code =  CESS_CTI_FRONTCODE ;
        this.campaign_name = String.isEmpty(CTIcampaign) ? CESS_CTIPLAN_CAMPAIGN : CTIcampaign;
        this.columns = columns;
        this.values = values;
        this.column_filter = CESS_CTI_COLUMNFILTER;

        this.scheduled_planning_call = new scheduled_planning_call(sched);
    }

    public class scheduled_planning_call{

        @AuraEnabled public String phone_number; 
        @AuraEnabled public String agent_id;
        @AuraEnabled public String sched_time; 

        public scheduled_planning_call(final List<String> sched) {
            this.agent_id = sched[0];
            this.phone_number = sched[1];
            this.sched_time =  sched[2];
        }
        
    }

        /*
        como hemos comentado os paso detalle del body de la invocación del método 'Add' expuesto por el WS.

        Se ha enviar una estructura tipo json conteniendo un tipo 'contact':
        {"contact":
        {
            "front_code":"25FEE590",
            "campaign_name":"",
            "column_filter":"lead_number",
            "columns":["lead_number","order_number","skills","source_datetime","tel_contact1","tel_contact2"],
            "values":["K00002","10","0001,0002,0003","2019-05-31 19:00:00","910121111","910121112"],
            "scheduled_planning_call":
            {
            "phone_number":"910121111",
            "sched_time":"2019-06-05 21:30:10",
            "agent_id":"" 
            }
        }
        }

        El "front_code" es un identificador que referencia el origen de la petición, por defecto tiene asociada una campaña Genesys en la que se generará el contacto. El código que se ha generado para Salesforce es "25FEE590", por lo que debéis especificarlo en todas las peticiones.
        "campaign_name" es un campo opcional, que en caso de utilizarse referencia a un nombre de campaña (que de existir) en Genesys, sobre la que realizar la inserción del contacto. En el escenario inicial del proyecto, única campaña, no es necesario que lo especifiquéis, esta establecido por la configuración por defecto asociada al "front_code".
        "column_filter" establece el campo clave de la contact list asociada a la campaña. En todas las peticiones se ha especificar el valor "lead_number", que es el que aplica en todo caso en el proyecto. Este valor a de ser siempre único en cada inserción, una inserción de un valor ya existente en la contact list devolverá un error (400) en la ejecución.
        "columns" array con los nombres de los campos de negocio a insertar. Los especificados en el ejemplo son los valores que se establecieron como obligatorios y que se deben consignar en toda petición. El resto de valores de negocio opcionales (dados de alta en Genesys) corresponde con los definidos y aparecen referenciados en la definición del swagger. Con esta estructura de array podemos añadir a futuro nuevos campos de negocio a futuro, sin más que añadirlos por configuración en Genesys, sin modificar el WS.
        "values" array de valores asociados a los campos definidos en "columnus" por posición.
        El parámetro opcional "scheduled_planning_call" permite crear adicionalmente a la inserción del contacto, una planificación concreta para la realización de llamada.
        "phone_number": número a marcar. Debe corresponder con alguno de los referenciados en los campos "tel_contact1" o "tel_contact2".
        "sched_time": especificación en formato datetime de la hora de realización de la llamada.
        "agent_id": campo opcional de especificación del id del agente concreto a quien presentar la llamada.
        */

}