({
    
    getTask : function(cmp, evt, helper) {
        
        function hashCode(s) {
          var h = 0, l = s.length, i = 0;
          if ( l > 0 )
            while (i < l)
              h = (h << 5) - h + s.charCodeAt(i++) | 0;
          return h;
        };
        
        var action = cmp.get("c.getTasks");
        if ( action != null ) {
            action.setParams({ parentId : cmp.get("v.recordId") });
    
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var response = JSON.stringify(response.getReturnValue());
                    var hashresponse = hashCode(response);
                    var store = cmp.get('v.store');
                    if ( store !== hashresponse ){
                        cmp.set('v.store', hashresponse);
                        $A.get('e.force:refreshView').fire();
                    }
                }            
            });
    
            $A.enqueueAction(action);
        }
    }
})