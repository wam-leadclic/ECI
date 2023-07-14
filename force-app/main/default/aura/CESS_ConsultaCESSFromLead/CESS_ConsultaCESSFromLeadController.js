/********************************************************************************** 
 * @author       Francisco José Pérez - franciscojose.perez@salesforce.com
 * @date         23/04/2019
 * @group        Console
 * @description  Controller of the Lightning Component 'CESS_ConsultaCESSFromLead'
 * @Revision
**********************************************************************************/

({
    //Initialises the Lightning Component
    doInit : function(component, event, helper) {
        helper.initialise(component, event);
    },
    
    //Refresh the Lightning Data Service
    doRefresh : function(component, event, helper) {
        helper.doRefresh(component, event);
    },

    //Push cancel button
    onCancel : function(component, event, helper) {
        helper.handleOnCancel(component, event);
    },
    
    //Triggers an action when a row is selected
    handleRowSelection: function (component, event, helper) {
        helper.handleSelection(component, event);
    },

    onSelect : function (component, event, helper){
        helper.handleOnSelect(component, event);
    }
    
})