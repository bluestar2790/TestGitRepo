({
    helperMethod : function() {
    
    },

    getData : function(cmp) {
        var action = cmp.get('c.getBorrow');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },

    getreaderData : function(cmp, event) {
        var action = cmp.get('c.getByName');
        action.setParams({
            "name":event
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },

    setReturnBook : function(cmp) {
        var borrowList = cmp.get('v.borrowIdList');
        var action = cmp.get('c.setReturnDate');
        action.setParams({
            'borrowIdList': borrowList
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },

    setAutoReturnBook : function(cmp, event) {
        var action = cmp.get('c.setAutoReturnDate');
        action.setParams({
            'borrowchildBookId': event
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
})