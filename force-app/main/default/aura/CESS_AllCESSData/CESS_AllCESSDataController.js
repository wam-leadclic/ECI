({
    //Initialises the Lightning Component
    doInit : function(component, event, helper) {
        helper.initialise(component, event);
    },
    
    refreshView : function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
   },   

   //Refresh the Lightning Data Service
    doRefresh : function(component, event, helper) {
        helper.doRefresh(component, event);
    },

    handleSectionToggle: function (cmp, event, helper) {

        //Esta variable también nos vale para controlar las secciones, o el de abajo. Funciona de igual forma.
        var openSections = event.getParam('openSections');
        //Semaforo de control de click en la sección que nos interesa. Siempre que hacemos click y "reaparece" se ejecuta un código
        var activeSec = cmp.find("accordion").get('v.activeSectionName');
        if ( (activeSec.indexOf('G') >= 0) && (cmp.get("v.lanzaDG") === false) ){
            cmp.set("v.lanzaDG", true);
            cmp.set("v.requestNotFound", false);
            //Data load.
            helper.getDGData(cmp, event);
        }else if (activeSec.indexOf('G') < 0){
            cmp.set("v.lanzaDG", false);
        }
        if ( (activeSec.indexOf('P') >= 0) && (cmp.get("v.lanzaP") === false) ){
            //Create the component.
            cmp.set("v.lanzaP", true);
            helper.getPData(cmp,event);
        }else if (activeSec.indexOf('P') < 0){
            cmp.set("v.lanzaP", false);
        }

        if ( (activeSec.indexOf('C') >= 0) && (cmp.get("v.lanzaCL") === false) ){
            cmp.set("v.lanzaCL", true);
            //Data load.
            helper.getCLData(cmp, event);
        }else if (activeSec.indexOf('C') < 0){
            cmp.set("v.lanzaCL", false);
        }
    }

})