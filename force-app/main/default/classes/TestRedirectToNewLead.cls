/**
@description
<pre>
Clase de test para cubrir la clase RedirectToNewLeadCtrl</br>

FECHA       AUTOR       DESCRIPCION<br/>
22/11/2022  MHG - LCS   Agregar campo Medio (source_type__c) en la creación de leads (Validation Rules)
11/10/2022  MHG - LCS   Se cambia el assert de TestRedirectToNewLead
11/10/2022  MHG - LCS   Se añaden los dos casos para los que se encuentre un Lead o se encuentre un Contacto
05/10/2022  LCS - MMV   Correción con nuevo parámetro y valores de la tarea
23/05/2022  LCS - DME   Creación

</pre>
@author Leadclic Solutions
@date 23/05/2022
*/
        // Caso 1: Compare to pageRef == inin_remoteani__c, se crea inin__c > 7 y entra en todas las condiciones
        // Caso 2: Compare to pageRef != inin_remoteani__c, se crea inin__c vacío y no entra en condiciones de validación
        // Caso 3: No se registra tarea, por lo tanto debe redireccionar sin valor 
        // Caso 4: Existe un Lead con el teléfono igual al inin_remoteani__c
        // Caso 5: Existe un Contacto con el teléfono igual al inin_remoteani__c

@isTest
private class TestRedirectToNewLead {
     
    @isTest static void testValidTask() {
        
        List<Task> taskList = new List<Task>();
        for (integer i=0; i<1; i++) {
            taskList.add (new Task (
                Subject='Test Subject ' + i,  
                inin_remoteani__c='123456789' + i,
                Priority='Normal',
                Status='open',
                Station__c = '0'
            ));   
        }
        insert taskList;
                
        Test.startTest();
        RedirectToNewLeadCtrl redirectToNewLeadCtrl = new RedirectToNewLeadCtrl();
        PageReference pageReference = redirectToNewLeadCtrl.redirect();
        Test.stopTest();
        
        pageReference.getUrl();
        
        String valorParametro = pageReference.getParameters().get('defaultFieldValues');           
        System.assert(valorParametro <> '');
    }   
   
    @isTest static void testInvalidTask() {
        
        List<Task> taskList = new List<Task>();
        for (integer i=0; i<1; i++) {
            taskList.add (new Task (
                Subject='Test Invalid ' + i,  
                inin_remoteani__c='',
                Priority='Normal',
                Status='open'
            ));   
        }
        insert taskList;
        
        Test.startTest();
        RedirectToNewLeadCtrl redirectToNewLeadCtrl = new RedirectToNewLeadCtrl();
        PageReference pageReference = redirectToNewLeadCtrl.redirect();
        Test.stopTest();
         
        pageReference.getUrl();

        String valorParametro = pageReference.getParameters().get('defaultFieldValues');           
        System.assertNotEquals(valorParametro, 'MobilePhone=' + ''); 
    }   
 
    @isTest static void testEmptyTask() {
        
        List<Task> taskList = new List<Task>();

        Test.startTest();
        RedirectToNewLeadCtrl redirectToNewLeadCtrl = new RedirectToNewLeadCtrl();
        PageReference pageReference = redirectToNewLeadCtrl.redirect();
        Test.stopTest();
        
        pageReference.getUrl();
        
        if (taskList.isEmpty()) {
            String valorParametro = pageReference.getParameters().get('defaultFieldValues');         
            System.assertNotEquals(valorParametro, 'MobilePhone=' + 'null');                
        }
    }   

    @isTest static void testLead() {
        
        // Creamos la tarea
        Task taskTest = new Task (
            Subject='TestTask',
            inin_remoteani__c='Test12345678',
            Priority='Normal',
            Status='open'
        );
        insert taskTest;

        // Creamos el Lead
        Lead leadTest = new Lead (
            lastName = 'LeadTest',
            MobilePhone = 'Test12345678',
            source_type__c = 'Telefono'
        );
        insert leadTest;
        
        // Ejecutamos el test de la clase
        Test.startTest();
            RedirectToNewLeadCtrl redirectToNewLeadCtrl = new RedirectToNewLeadCtrl();
            PageReference pageReference = redirectToNewLeadCtrl.redirect();
        Test.stopTest();

    }
    
    @isTest static void testContact() {
        
        // Creamos la tarea
        Task taskTest = new Task (
            Subject='TestTask',
            inin_remoteani__c='Test12345678',
            Priority='Normal',
            Status='open'
        );
        insert taskTest;

        // Creamos el Contacto
        Contact contactTest = new Contact (
            firstName = 'TestName',
            lastName = 'TestLastname',
            Phone = 'Test12345678',
            MobilePhone = 'Test12345678',
            personal_document__c = '11111111H'
        );
        insert contactTest;
        
        // Ejecutamos el test de la clase
        Test.startTest();
            RedirectToNewLeadCtrl redirectToNewLeadCtrl = new RedirectToNewLeadCtrl();
            PageReference pageReference = redirectToNewLeadCtrl.redirect();
        Test.stopTest();

    }   

}