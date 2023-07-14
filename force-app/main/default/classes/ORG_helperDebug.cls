/**********************************************************************************
* @name         	ORG_helperDebug
* @version			1.0
* @creation date    06/11/2020
* @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @description  	Apex Class with the methods to build strings for debug
* @group        	Helper
**********************************************************************************/
public class ORG_helperDebug {

    /* Separator between the name of the class and the name of the method */
    private static String SEP_CLASS = '.';
    /* Separator for the message */
    private static String SEP_MSG = ': ';
    /* Separator for the exception */
    private static String SEP_EXC = ' -> ';
    
    /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    06/11/2020
    * @description  	Get the string for a info message for debug
    * @param nameClass	the name of the class
    * @param nameMethod	the name of the method
    * @param msg		the message
    * @return			the string with the info of the class and the message
    **********************************************************************************/
    public static String getInfo(String nameClass, String nameMethod, String msg) {
    
     	return nameClass + SEP_CLASS + nameMethod + SEP_MSG + msg;    
       
    }
    
    /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    06/11/2020
    * @description  	Get the string for a exception message for debug
    * @param nameClass	the name of the class
    * @param nameMethod	the name of the method
    * @param exc		the exception
    * @return			the string with the info of the class and the exception
    **********************************************************************************/
    public static String getException(String nameClass, String nameMethod, Exception exc) {
    
        return nameClass + SEP_CLASS + nameMethod + SEP_MSG + ORG_Constantes.MSG_EXC + SEP_EXC + exc.getMessage();
    }
    
}