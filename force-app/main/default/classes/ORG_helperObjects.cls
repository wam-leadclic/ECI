/**********************************************************************************
* @name         	DQ_cls_helperObjects
* @version			1.0
* @creation date   	29/04/2020
* @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
* @description  	Apex Class with the functionality of the helper for the objects Sf.
* @group        	Helper
**********************************************************************************/
public class ORG_helperObjects {
	//Private constants
    private static final String LETRAS_NIFNIE = 'TRWAGMYFPDXBNJZSQVHLCKE';
    private static final String VALORES_CIF = 'ABCDEFGHJKLMNPQRSUVW';
    private static final List<Integer> NC_MULTIPLIERS = new List<Integer>{9,8,7,6,5,4,3,2};
    /**
     * @description Validates a NIF number being correct.
     * @param nifNumber the number to be validated.
     * @return true or false.
     */
    public static Boolean isNifValid(final String nifNumber) {
        
        boolean resultado = false;
        Pattern p = Pattern.compile('[0-9]{8}[' + LETRAS_NIFNIE + ']');
        String [] chars_LETRAS_NIF = LETRAS_NIFNIE.split('');
        //chars_LETRAS_NIF.remove(0);
        
        try {
            String nif1 = nifNumber.toUpperCase();
            //nif1 = nif1.replace('X','0');
            //nif1 = nif1.replace('Y','1');
            //nif1 = nif1.replace('Z','2'); 
            String [] chars_nif1 = nif1.split('');
            //chars_nif1.remove(0);
            Matcher pm = p.matcher(nif1);
            if( pm.matches() ) {
                Integer dni = Integer.valueOf(nif1.substring(0, 8));
                String letraCalculada = chars_LETRAS_NIF[math.mod(dni,23)];
                
                if (letraCalculada == chars_nif1[8]) {
                    resultado = true;
                }
            }
        } catch (Exception e) {
            // Si ha habido algun error es porque hay algun parseo que tira bien.
            System.debug(LoggingLevel.ERROR, '*** Error al parserar NIF: ' + e.getMessage());
            resultado = false;
        }
        
        return resultado;
    }
    
    /**
     * @description Validates a CIF number being correct.
     * @param nifNumber the number to be validated.
     * @return true or false.
     */
    public static Boolean isCifValid(final String cifNumber) {
        
        boolean resultado = false;     
        try {
            String vCif = cifNumber.trim();

            Integer suma = 0;
            Integer contador = 0;
            Integer temporal = 0;
            Integer codigoControl = 0;
            String cadenaTemporal = null;
            String letraControlCIF = '0123456789';
            String letraSociedadNumerica = 'KLMNPQRSW';
            String[] sociedadLetraFinal = new List<String>{'J', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'};
            String primeraLetra = null;
            String ultimaLetra = null;

            // Comprueba la longitud correcta del CIF.
            if (!(vCif.length() == 9)){
                return false;
            }

            // Si encuentra algun caracter que no sea una letra o un numero, el cif no es valido.
            Pattern p = Pattern.compile('[^A-Za-z0-9]');
            Matcher pm = p.matcher(vCif);
            if( pm.matches() ){
                return false;
            }

            // Convierte a mayusculas la cadena.
            vCif = vCif.toUpperCase();

            // Obtiene la primera letra (letra de la sociedad) y la ultima letra del
            // CIF (letra de control).
            primeraLetra = vCif.substring(0, 1);

            // Obtiene la ultima letra del CIF, para comprobar si es valida.
            ultimaLetra = vCif.substring(8, 9);

            // Comprueba si la primera letra es valida.
            if (VALORES_CIF.indexOf(primeraLetra) < 0){
                return false;
            }

            // Obtiene el codigo de control.
            // Sumamos las cifras pares
            suma = Integer.valueOf(vCif.substring(2, 3)) + 
                   Integer.valueOf(vCif.substring(4, 5)) + 
                   Integer.valueOf(vCif.substring(6, 7));	                                

            // Ahora cada cifra impar la multiplicamos por dos y sumamos las cifras
            // del resultado.
            for (contador = 1; contador < 8; contador = contador + 2) {
                // Multiplica por 2
                temporal = (Integer.valueOf(vCif.substring(contador, contador + 1)) * 2);

                // Suma los digitos.
                // Diferencia si tiene una cifra, por ejemplo: 8 = 8
                // o si tiene varias, por ejemplo: 16 -> 6 + 1 = 7
                if (temporal < 10)
                    suma = suma + temporal;
                else {
                    cadenaTemporal = String.valueOf(temporal);
                    suma = suma + (Integer.valueOf(cadenaTemporal.substring(0, 1)))
                            + (Integer.valueOf(cadenaTemporal.substring(1, 2)));
                }
            }

            // Obtiene las unidades de la suma y se las resta a 10, para obtener el digito de control.
            codigoControl = 10 - (math.mod(suma,10)) ;

            // Si la letra es K, L, M, N, P, Q, R, S, W entonces al codigo de control le suma 64 y
            // obtengo su ASCII para ver si coincide con la ultima letra del cif.
            if (letraSociedadNumerica.indexOf(primeraLetra) >= 0) {
                
                // Obtiene el codigo ASCII asociado, al sumar 64 al codigo de control.
                if (codigoControl == 0){
                    codigoControl = 10;
                }
                codigoControl = codigoControl + 64;

                // El ultimo digito tiene que coincidir con el digito de control obtenido
                resultado = (ultimaLetra.getChars()[0] == codigoControl );

            } else {
                // Para el resto de letras de comienzo de CIF el ultimo digito debe ser:
                // numerico que coincida con el codigo de control, o debe ser una letra del array sociedadLetraFinal y coincidir en la posicion de codigoControl.
                resultado = ( (codigoControl == letraControlCIF.indexOf(ultimaLetra)) || 
                              (ultimaLetra == sociedadLetraFinal[codigoControl]) );
            }
        } catch (Exception e) {
            // Si ha habido algun error es porque hay algun parseo que tira bien.
            System.debug(LoggingLevel.ERROR, '*** Error al parserar CIF: ' + e.getMessage());
            resultado = false;
        }

        return resultado;
    } 

    /**
     * @description Validates a NIF (PT) number being correct.
     * https://pt.wikipedia.org/wiki/N%C3%BAmero_de_identifica%C3%A7%C3%A3o_fiscal
     * @param nifNumber the number to be validated.
     * @return true or false.
     */
    public static Boolean isNCValid(final String ncNumber) {
        
        Boolean resultado = false;

        try {

            String [] chars_nc = ncNumber.split('');

            if (chars_nc.size() <> 9) return false;

            // Step 1.- Se multiplicará el valor de cada uno de los dígitos que componen dicho número 
            // por los valores 2,3,4,5,6,7,8,9 empezando por la derecha del mismo y se sumarán dichos productos.  
            Integer multiplerSum = 0;

            for (Integer i = 0; i < 8; i++)
                multiplerSum += Integer.valueOf(chars_nc.get(i)) * NC_MULTIPLIERS.get(i);
            
            // Step 2.- Se divide el resultado de la suma entre 11 y nos quedamos con el resto
            final Integer reminder = Math.mod(multiplerSum,11);

            // Step 3.- Se resta del valor 11 el resto de la división
            final Integer diff = 11 - reminder;

            // Step 4.- Si el resultado de dicha resta son los valores 10 u 11, el dígito de control será 0. 
            // En caso contrario, el dígito de control será el resultado de dicha resta.
            final Integer control = diff > 9 && diff < 12 ? 0 : diff;

            // Step 5.- Verificar nc con el dígito de control
            resultado = Integer.valueOf(chars_nc[8]) == control ? true : false;

        } catch (Exception e) {
            // Si ha habido algun error es porque hay algun parseo que tira bien.
            System.debug(LoggingLevel.ERROR, '*** Error al parserar NIF Portugues: ' + e.getMessage());
            resultado = false;
        }

        return resultado;

    }
    
        /**********************************************************************************
    * @name         	isNIEValid
    * @version			1.0
    * @creation date   	29/04/2020
    * @author       	Maria Dolores Sanchez Meroño -mdolores.sanchez@iecisa.com
    * @description  	Function to check if a NIE is valid
    * @param nieNumber	the number of NIE to be validated
    * @return Boolean	returns true if its valid, false if not.
    **********************************************************************************/
    public static Boolean isNieValid(String nie){
        Boolean isValid = false;
        Integer i = 1;
        String letra =' ';
        Integer miNIE = 0;
        Integer resto = 0;
        Integer caracterASCII = 0;
        String[] asignacionLetra = LETRAS_NIFNIE.split('');
        String [] nieList = nie.split('');          
        if(nie.length() == 9 &&  nieList[8].isAlpha() 
          && (nieList[0].toUpperCase() == 'X'
          || nieList[0].toUpperCase() == 'Y'
          || nieList[0].toUpperCase() == 'Z')){
            
              do{
                  caracterASCII = nie.codePointAt(i);
                  isValid = (caracterASCII > 47 && caracterASCII<58 );
                  i++;
              } while(i<nie.length()-1 && isValid);
        }
        if(isValid && nie.substring(0,1).toUpperCase().equals('X')){
            nie = '0' +nie.substring(1,9);
        } else if(isValid && nie.substring(0,1).toUpperCase().equals('Y')){
        	nie = '1' +nie.substring(1,9);
        } else if(isValid && nie.substring(0,1).toUpperCase().equals('Z')){
            nie = '2' +nie.substring(1,9);   
        }else{
            isValid = false;
        }
        if(isValid){
            isValid = isNifValid(nie);
        }      
       return isValid;
    }
    
}