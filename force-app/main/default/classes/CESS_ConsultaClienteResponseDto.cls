/**********************************************************************************
* @author       Francisco José Pérez - franciscojose.perez@salesforce.com
* @date         21/05/2019
* @group        Integrations
* @description  DTO for the EmpleadoInformation response of Consulta CESS Client
* @Revision
**********************************************************************************/
public class CESS_ConsultaClienteResponseDto {

    //para concatenar los ramos prohibidos
    @AuraEnabled public String businesslines_prohibited;

    @AuraEnabled public String fijo;
    @AuraEnabled public String email;
    @AuraEnabled public String movil;

    @AuraEnabled public String return_code;
    @AuraEnabled public String error_message;
    @AuraEnabled public String cess_identifier;
    @AuraEnabled public String aneto_identifier;

    @AuraEnabled public List <List_document> list_document;
    @AuraEnabled public String first_name;
    @AuraEnabled public String surname_first;
    @AuraEnabled public String surname_second;
    @AuraEnabled public String birthdate;
    @AuraEnabled public String gender;
    @AuraEnabled public String eci_card;
    @AuraEnabled public List <List_contact_dc> list_contact_dc;
    @AuraEnabled public String group_permission;

    @AuraEnabled public String rating_type;  //no está en el acuerdo de interfaz. ahora no se muestra.
    @AuraEnabled public List <Line_forbidden> line_forbidden;
    @AuraEnabled public String result_descriptions;  //concatenación de los ramos prohibidos

    public class List_document {
        @AuraEnabled public String document_type; 
        @AuraEnabled public String document_number;   
        @AuraEnabled public String sequence;
    }

    public class Line_forbidden {
        @AuraEnabled public String insurance_code; 
        @AuraEnabled public String insurance_description;
    }


    public class List_contact_dc {
        @AuraEnabled public String contact_type; 
        @AuraEnabled public String contact_data;
    }

    //campos del error
    @AuraEnabled public String message;
    @AuraEnabled public String request_id;
    @AuraEnabled public Details details;


    public class Details {
        @AuraEnabled public String code; 
        @AuraEnabled public String message;
        @AuraEnabled public String description;
    }

   public CESS_ConsultaClienteResponseDto(){
    }

    //para pruebas
    public CESS_ConsultaClienteResponseDto(String c, String m, String ic, String ia, 
                                          String dt, String dn, String s, String fn,
                                          String sf, String ss, String b, String g,
                                          Map<String,String>  lc, String gp, String tf, 
                                          String ecn) {
        this.return_code = c;
        this.error_message = m;
        this.cess_identifier = ic;
        this.aneto_identifier = ia;
        //this.list_document.document_type = dt;
        //,dn,s); 
        this.first_name = fn;
        this.surname_first = sf;
        this.surname_second = ss;
        this.birthdate = b;
        this.gender = g;
        //this.listaContactos = lc;
        this.group_permission = gp;
        //this.businesslines_prohibited = tf;
        this.eci_card = ecn;
    }

}