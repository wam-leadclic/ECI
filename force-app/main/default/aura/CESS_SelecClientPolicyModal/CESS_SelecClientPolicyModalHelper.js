({
    refreshData : function(component, event, helper) {

        console.log ("Entra en refreshData");

        component.find("recordHandler").reloadRecord(true);
        if (component.get("v.objectFields.Account.identifier_cess__pc") || component.get("v.objectFields.Account.identifier_aneto__pc")){
            component.set("v.showPolicy",true);
            component.set("v.showSpinner", false);
        }else{
            component.set("v.showPolicy",false);
            component.set("v.showSpinner", false);
        }

    }
})