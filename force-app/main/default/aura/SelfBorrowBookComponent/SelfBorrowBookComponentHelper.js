({
    helperMethod : function() {
    
    },

    addBookHelper : function(cmp, readerIdValue, bookDetailsIdValue) {
        var action = cmp.get('c.setBookSelfFlag');
        action.setParams({
            'readerId' : readerIdValue,
            'bookDetailsId': bookDetailsIdValue
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

    selfBorrowBookHelper : function(cmp, readerIdValue) {
        var action = cmp.get('c.selfBorrowBooks');
        action.setParams({
            'readerId' : readerIdValue,
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

    clearFlagHelper : function(cmp) {
        var action = cmp.get('c.clearselfFlag');
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
    }
})