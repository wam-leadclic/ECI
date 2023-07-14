/**********************************************************************************
* @name         	CESS_csvHeader
* @version			1.0
* @creation date    04/11/2020
* @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @description  	Apex Class for csv header
* @group        	Class
**********************************************************************************/
global class CESS_csvHeader {

    @AuraEnabled
    public String columnName {get; set;}

    @AuraEnabled 
    public String columnType {get; set;}

    /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    04/11/2020
    * @description  	Constructor
    **********************************************************************************/ 
    global CESS_csvHeader() {}
    
    /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    04/11/2020
    * @description  	Constructor
    * @param columnName	the name column
    * @param columnType the type column
    **********************************************************************************/
    public CESS_csvHeader(String columnName, String columnType) {
        this.columnName = columnName;
        this.columnType = columnType;
    } 

    /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    04/11/2020
    * @description  	Constructor
    * @param columnName	the name column
    **********************************************************************************/
    public CESS_csvHeader(String columnName) {
        this.columnName = columnName;
        this.columnType = '';
    }
}