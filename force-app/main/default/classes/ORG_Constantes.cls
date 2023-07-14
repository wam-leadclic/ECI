/**********************************************************************************
* @author       María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @date         04/11/2019
* @group        Constantes 
* @description  Constantes class 
* @Revision 
**********************************************************************************/

public class ORG_Constantes {

    /* SOQL operator equal */
    public static final String SOQL_OPE_EQUAL = '=';
    /* SOQL Today */
    public static final String SOQL_DATE_TODAY = 'Today';
    /* Formato Fecha/Hora */
    public static final String DATETIME_FORMAT_ES = 'dd/MM/yyyy HH:mm:ss';
    /* valor ES */
    public static final String CON_ES = 'ES';
    /* String HYPHEN*/
    public static final String MSG_HYPHEN = '-';
    /* String EMPTY*/
    public static final String MSG_EMPTY = '';
    /* String SEP*/
    public static final String MSG_SEP = ', ';
    /* String DOT*/
    public static final String MSG_DOT = '. ';
    /* String SEP*/
    public static final String MSG_AMP = '&';
     /* String SEP*/
    public static final String MSG_DEL = '"';
    /* Separator Multi Pick List */
    public static final String MULTI_SEP = ';';
    /*Separador for the URI*/
    public static final String URI_SEP = '/';
    
    /*String Salto linea*/
    public static final String MSG_LINE_BREAK = '\r\n';
    /* String SPACE*/
    public static final String MSG_SPACE = ' ';
    /* String OK*/
    public static final String MSG_OK = 'OK';
    /* String OK con ERROR*/
    public static final String MSG_OK_ERROR = 'OK & ERROR';
    /* String ERROR*/
    public static final String MSG_ERROR = 'ERROR';
    /* String ERROR*/
    public static final String MSG_RESULTADO = 'Resultado';
    /* String INIT*/
    public static final String MSG_INIT = 'INIT';
    /* String END*/
    public static final String MSG_END = 'END';
    /* String for exception*/
    public static final String MSG_EXC = 'An unexpected error has occurred';
    /* String for database error*/
    public static final String MSG_DBE = 'The following error has occurred';
    /*First Number of telephoneNumber*/
    public static final List<String> firstNumberTelephone = new List<String>{'6','7','8','9'};
   /*First Number of telephoneNumber*/
    public static final Integer telephoneLengthValid = 9;
    
    /*Case stage Pendiente Gestionar*/
    public static final String STAGE_PEND_GESTIONAR = 'Pendiente de gestionar caso';
    /*Case Status Cancelado*/
    public static final String CASE_STATUS_CANCELADO = 'SAC_04_Cancelado';
    /*Case Closed reason automatico*/
    /*Case Status Cerrado*/
    public static final String CASE_STATUS_CLOSED = 'SAC_03_Closed';
    /*Case Closed reason automatico*/
    public static final String CIERRE_FALTA_RESPUSTA = 'SAC_13_Falta de respuesta de cliente';
    /*Case Closed comment falta contestación Cliente*/
    public static final String COMMENT_FALTA_RESPUESTA = 'Falta respuesta del cliente';
    

     /*QUEUE CENTRAL SIN ASIGNAR*/
    public static final String QUEUE_CENTRAL_SIN_ASIGNAR = 'CENTRAL SIN ASIGNAR';
    /*QUEUE CENTRAL OUTLET COMPRAS*/
    public static final String QUEUE_COMPRAS_OUTLET = 'COMPRAS-OUTLET';
    /*QUEUE CENTRAL OUTLET MARKETING*/
    public static final String QUEUE_MARKETING_OUTLET = 'MARKETING-OUTLET';
     /*QUEUE CENTRAL CONTROL MARKETING*/
    public static final String QUEUE_CONTROL_MARKETING = 'CONTROL MARKETING';

    
    //TYPES
    public static final String MOTIVO_PRO_CALIDAD = 'Producto calidad';
    public static final String SUBMOTIVO_ALERT_SAN = 'Alerta Salud/Seguridad';
    public static final String MOTIVO_SICOR = 'SICOR';
    public static final String SUBMOTIVO_ALARMAS = 'Alarmas';
}