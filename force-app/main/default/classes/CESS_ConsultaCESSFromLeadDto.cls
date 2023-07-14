public with sharing class CESS_ConsultaCESSFromLeadDto {

	@AuraEnabled public String codRetorno;
    @AuraEnabled public String desRetorno;
    @AuraEnabled public String identifier_aneto;
    @AuraEnabled public String cessAneto;    //FPEREZ. Información de dónde está la info. cess, aneto o ambos. teniendo id's, no nos hace falta.
    @AuraEnabled public String documentoSecuencia;   //FPEREZ en principio no se trata. es para sacar el listado de clientes en el componente. por ver con leticia y aaron.
    @AuraEnabled public String surname_first;   //FPEREZ los apellidos se concatenan en lastName
    @AuraEnabled public String surname_second;
    @AuraEnabled public String birthdate;      
    @AuraEnabled public contacto contacto;      //bucle de contacto. 
    @AuraEnabled public String cesionDatosGrupo; 
    @AuraEnabled public ramosProhibidos ramosProhibidos;

    //Lead object api names.
    @AuraEnabled public String identifier_cess;
    @AuraEnabled public String document_type;
	@AuraEnabled public String document_number;
	@AuraEnabled public String gender;      //FPEREZ. Aquí es u flag, en la aplicación una picklist. Que hacemos? para aaron.
    @AuraEnabled public String eci_card_number;   //FPEREZ. Campo de Account.
    @AuraEnabled public String name;

//FPEREZ. Datos dummi rellenados. + name
    @AuraEnabled public String tlf;
    @AuraEnabled public String nif;
    @AuraEnabled public String email;
	@AuraEnabled public String cessId;

    //-- INNER CLASSES 
    /**
     * Class that represents a contacto.
     */
    public class contacto {
        @AuraEnabled public String id_x;  //FPEREZ Es necesario? no viaja.
        @AuraEnabled public String tipoContacto;   //picklist 3 valores.
        @AuraEnabled public String datoContacto;  //FPEREZ. Tenemos fijo, movil e email. tres campos en función del tipoContacto.
    }

    /**
     * Class that represents a ramosProhibidos.
     */
    public class ramosProhibidos {
        @AuraEnabled public String id_x;  //FPEREZ Es necesario? no viaja.
        @AuraEnabled public String businesslines_prohibited; //el plural es el texto, singular el flag.
    }

    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class CESS_ConsultaCESSFromLeadtoException extends Exception { }

    

}