/**
@description
<preClClase de controlador para cubrir la VisualForce RedirectToNewLead</br>

FECHA       AUTOR       DESCRIPCION<br/>
18/05/2022  LCS - DME   Creación
</pre>
@author Leadclic Solutions
@date 18/05/2022
                AUTHOR          DATE        Reason
* @Revision     Marta           21/06/22    Metemos un delay porque open CTI tarda en crear la tarea
                LCS - MMV       31/08/22    Modificación de el número de iteraciones y los tiempos de delay para evitar fallo de CPU TIME          
                LCS - MMV       02/09/22    Si no se encuentra la tarea se manda el concatenate sin mobil number
                LCS - MMV       15/09/22    Se añade la condición de tiempo en la tarea para que no encuentre tareas antiguas
                MHG - LCS       10/10/2022  Se añaden comentarios en la clase y se reduce el número de iteraciones con query para que no impacte en los límites (se baja a 90)
                MHG - LCS       11/10/2022  Se modifica para que aunque no se espere que existe el LEAD/Contact, busque si está a partir de los datos de CTI, en cuyo caso redirige al Lead/Contact encontrado
                MHG - LCS       14/10/2022  Se incluyen los tiempos de espera e iteraciones como valores en el CMT de ORG_ApplicationSettings__mdt
                MHG - LCS       17/10/2022  Se incluyen la actualización del WhoId de la tarea encontrada para que quede asociada al lead o al contacto
                MHG - LCS       18/10/2022  Fix de la consulta ante la posibilidad de devolver más de un Lead o Contacto
                LCS - JCB       15/12/2022  Modificaciones para casos transferencia de llamada (redirigir a Flow de búsqueda de contactos/leads) 
                
*/
 
public class RedirectToNewLeadCtrl {
    
    public PageReference redirect(){
        
        //se tiene que activar el check asociarLeadLlamada__c de asociar el nuevo lead a la llamada en curso, 
        //y rellenar el campo source_manualrecord__c para que este lead no se envie a CTI
        String redirectURL = '/lightning/o/Lead/new?defaultFieldValues=asociarLeadLlamada__c=true,source_manualrecord__c=Llamada Entrante';
        String incomingPhoneNumber;   
        String destinationPhoneNumber;
        // Definimos los tiempos de espera para los dos bucles de espera así como las iteraciones permitidas desde ORG_ApplicationSettings__mdt
        ORG_ApplicationSettings__mdt CESS_CTI_TiempoEsperaCorto = ORG_ApplicationSettings__mdt.getInstance('CESS_CTI_TiempoEsperaCorto');
        ORG_ApplicationSettings__mdt CESS_CTI_TiempoEsperaLargo = ORG_ApplicationSettings__mdt.getInstance('CESS_CTI_TiempoEsperaLargo');
        ORG_ApplicationSettings__mdt CESS_CTI_IteracoinesTareas = ORG_ApplicationSettings__mdt.getInstance('CESS_CTI_IteracoinesTareas');
        integer tiempoEsperaCorto = CESS_CTI_TiempoEsperaCorto == null ? 10 : integer.valueof(CESS_CTI_TiempoEsperaCorto.Value__c);
        integer tiempoEsperaLargo = CESS_CTI_TiempoEsperaLargo == null ? 10 : integer.valueof(CESS_CTI_TiempoEsperaLargo.Value__c);
        integer iteracionesTareas = CESS_CTI_IteracoinesTareas == null ? 10 : integer.valueof(CESS_CTI_IteracoinesTareas.Value__c);
        
        // Obtencíón de los valores de los número de teléfono del C. Metadata (telefonos de trasferencia, para realizar filtrado)
        Map<String, TelefonosTransferencia__mdt> phoneCMTMap = TelefonosTransferencia__mdt.getAll();

        // Si estamos ejecutando tests, bajamos los tiempos de espera para evitar el error de CPU limit
        if (Test.isRunningTest()){
            tiempoEsperaCorto = 1;
            tiempoEsperaLargo = 1;
            iteracionesTareas = 1;
        }
		
        // Se aguarda un lapso de tiempo para permitir que se creen los registros que se esperan de tareas
        Long startTime = DateTime.now().getTime();
		Long finishTime = DateTime.now().getTime();
       
		while ((finishTime - startTime) < tiempoEsperaLargo) {
            
    		finishTime = DateTime.now().getTime();
		}
        
        
        integer i = 0;
        List<Task> taskList=new List<Task>();
        while(taskList.size()<=0 && i<iteracionesTareas){
            
        	taskList = [SELECT Id, inin_remoteani__c, inin_dnis__c, CreatedDate, WhoId 
                               FROM Task 
                               WHERE Task.OwnerId =: UserInfo.getUserId() 
                               AND inin_remoteani__c != null
                               AND Station__c != ''
                               AND Station__c != null
                               AND CallDurationInSeconds = null
                               AND CreatedDate >=: DateTime.now().addMinutes(-2)
                               ORDER BY createdDate DESC limit 1];
            i++;
            startTime = DateTime.now().getTime();
		    finishTime = DateTime.now().getTime();
            while ((finishTime - startTime) < tiempoEsperaCorto) {
    			finishTime = DateTime.now().getTime();
			}
           
        }
            
        // Hemos encontrado la tarea, por lo que podemos redireccionar a donde corresponde
        if (taskList.size()>0)  {           
            incomingPhoneNumber = taskList[0].inin_remoteani__c;
            destinationPhoneNumber = taskList[0].inin_dnis__c;

            //Comprobar si la llamada es de transferencia
            String keyTelefono ; //Para hacer referencia a la entrada en el Map de teléfonos transferencia
            if(String.isNotBlank(destinationPhoneNumber)){
                for(String key : phoneCMTMap.keySet()){
                    if(destinationPhoneNumber.contains(phoneCMTMap.get(key).phone__c)){
                        keyTelefono = key;
                    }
                }
            }
            if( keyTelefono != null ){
                // Como la tarea es de transferencia, marcamos el campo de transferencia de la tarea y la actualizamos.
                taskList[0].Transference__c = true;
                update (taskList);
                //Redirigimos al flujo de búsqueda de clientes pasamos parametros taskList[0].Id => var_inTaskId, phoneCMTMap.get(key).source_manualrecord__c => var_inSourceManualRecord
                redirectURL = '/lightning/n/Buscador_Contactos_y_Leads?c__var_inTaskId='+taskList[0].Id+'&c__var_inSourceManualRecord='+phoneCMTMap.get(keyTelefono).source_manualrecord__c+'&c__var_inCampaignInbound='+phoneCMTMap.get(keyTelefono).CampanaInboundIVR__c;

            }else{

                // Buscamos si existe un LEAD con el teléfono o el móvil igual al incomingPhoneNumber, la búsqueda por SOQL encuentra registros no indexados que no aparecen por SOSL
                String leadId = [SELECT Id FROM Lead WHERE Phone = :incomingPhoneNumber OR MobilePhone = :incomingPhoneNumber order by CreatedDate desc limit 1]?.Id;

                // Buscamos si existe un Contacto con el teléfono o el móvil igual al incomingPhoneNumber, la búsqueda por SOQL encuentra registros no indexados que no aparecen por SOSL
                String contactId = [SELECT Id FROM Contact WHERE Phone = :incomingPhoneNumber OR MobilePhone = :incomingPhoneNumber order by CreatedDate desc limit 1]?.Id;

                
                // Si hay Lead o Contacto redirigimos a su ficha, en caso contrario a la página de "newLead"
                if (contactId <> null){
                    redirectURL = '/' + contactId;
                    taskList[0].WhoId = contactId;
                } else if (leadId <> null) {
                    redirectURL = '/' + leadId;
                    taskList[0].WhoId = leadId;
                } else {
                    redirectURL = (incomingPhoneNumber.length()) > 7 && (incomingPhoneNumber.isNumeric()) ? redirectURL+',MobilePhone=' + incomingPhoneNumber : redirectURL;
                }

                // Si hay Lead o Contacto, actualizamos el WhoId de la tarea (puesto que esto no lo hace el CTI)
                if (leadId <> null || contactId <> null){
                    update (taskList);
                }

            }

        }

       
        PageReference pageRef = new PageReference(redirectURL);
        return pageRef;
    }
    
}