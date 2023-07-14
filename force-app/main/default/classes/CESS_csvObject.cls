/**********************************************************************************
* @name         	CESS_csvObject
* @version			1.0
* @creation date    04/11/2020
* @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
* @description  	Apex Class for csv object
* @group        	Class
**********************************************************************************/
global class CESS_csvObject {
    
    @AuraEnabled
    public List<CESS_csvHeader> headers {get; set;}

    @AuraEnabled
    public List<List<String>> lines {get; set;}

    @AuraEnabled
    public Integer lineCount {get; set;}
	
    /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    04/11/2020
    * @description  	Constructor
    **********************************************************************************/    
    global CESS_csvObject() {}

    /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    17/02/2020
    * @description  	04/11/2020
    * @param csvStr		the string with csv
    **********************************************************************************/
    public CESS_csvObject(String csvStr) {
        String del = System.Label.ORG_lbl_csvDel;
        String sep = System.Label.ORG_lbl_csvSep;
        Integer regexFindLimit = 100;
        Integer regexFindCount = 0;
        List<String> linesRaw = new List<String>();
        Matcher m = Pattern.compile(ORG_Constantes.MSG_LINE_BREAK).matcher(csvStr);
        Integer lastEnd = 0;
        while (!m.hitEnd()) {
            while (regexFindCount < regexFindLimit && !m.hitEnd()) {
                if (m.find()) {
                    linesRaw.add(csvStr.substring(lastEnd, m.start()));  
                    lastEnd = m.end();
                } else {
                    linesRaw.add(csvStr.substring(lastEnd));
                    lastEnd = csvStr.length();
                }                
                regexFindCount++;
            }
            // Note: Using region() to advance instead of substring() saves 
            // drastically on heap size. Nonetheless, we still must reset the 
            // (unmodified) input sequence to avoid a 'Regex too complicated' 
            // error.
            m.reset(csvStr);        
            m.region(lastEnd, m.regionEnd());
            regexFindCount = 0;
        }
        List<String> headersRaw = separateCommas(linesRaw[0]);
        this.lines = new List<List<String>>();
        this.headers = new List<CESS_csvHeader>();
        linesRaw.remove(0);
        for (String line : linesRaw) {
            if (!String.isEmpty(line)) {
                List<String> lineSep = separateCommas(line);
                List<String> fields = new List<String>();
                Boolean makeCompositeField = false;
                String compositeField;
                for (String field : lineSep) {
                    if (field.startsWith(del) && field.endsWith(del)) {
                        fields.add(field.trim().replace(del, ORG_Constantes.MSG_EMPTY)); 
                    } else if (field.startsWith(del)) {
                        makeCompositeField = true;
                        compositeField = field;                    
                    } else if (field.endsWith(del)) {
                        compositeField += sep + field;
                        fields.add(compositeField.trim().replace(del, ORG_Constantes.MSG_EMPTY)); 					
                        makeCompositeField = false;
                    } else if (makeCompositeField) {
                        compositeField += sep + field;                   
                    } else {
                        fields.add(field.trim().replace(del, ORG_Constantes.MSG_EMPTY));  
                    }
                }
                this.lines.add(fields);
            }
        }
        for(String header : headersRaw) {
            this.headers.add(new CESS_csvHeader(header.trim().replace(del, ORG_Constantes.MSG_EMPTY)));
        }
    }
    
    /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    04/11/2020
    * @description  	Constructor
    * @param headers	the list of csv headers
    * @param lines 		the list of csv lines
    **********************************************************************************/
    public CESS_csvObject(List<CESS_csvHeader> headers, List<List<String>> lines) {
        this.headers = headers;
        this.lines = lines;
        this.lineCount = lines.size();
    }
    
    /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    11/04/2020
    * @description  	to string
    **********************************************************************************/
    public override String toString() {        
        String del = System.Label.ORG_lbl_csvDel;
        String sep = System.Label.ORG_lbl_csvSep;
        String csvStringHeader = ORG_Constantes.MSG_EMPTY;
        for (CESS_csvHeader header : this.headers) {
            if (csvStringHeader != ORG_Constantes.MSG_EMPTY) {
                csvStringHeader += sep;
            }
            csvStringHeader += del + header.columnName + del;
        }
        csvStringHeader += ORG_Constantes.MSG_LINE_BREAK;   
        String csvString = csvStringHeader;
        for (List<String> line : this.lines) {
            String csvRows = ORG_Constantes.MSG_EMPTY;
            for (String valueLine : line) {
                if (csvRows != ORG_Constantes.MSG_EMPTY) {
                    csvRows += sep;
                }
                csvRows += del + valueLine + del;
            }
            csvRows += ORG_Constantes.MSG_LINE_BREAK;
            csvString += csvRows;
        }
        return csvString;
    }
    
    /**********************************************************************************
    * @author       	María Dolores Sánchez Meroño - mdolores.sanchez@iecisa.com
    * @creation date    04/11/2020
    * @description  	Separate by commas
    * @param input		the string to separate
    **********************************************************************************/
    private static List<String> separateCommas(String input) {
        String del = System.Label.ORG_lbl_csvDel;
        String sep = System.Label.ORG_lbl_csvSep;
        List<String> results = input.split(sep);
        for(String result : results) {
            result = result.trim();
        }
        if(input.endsWith(sep)){
            results.add('');
        }
        return results;
    }
    
}