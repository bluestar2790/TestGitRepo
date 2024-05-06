({
    //获取输入框的值
    myAction : function(component, event, helper) {
        var vTest =  component.get('v.test');
        var searchData = component.get('c.searchData');
        searchData.setParams({
            "key":vTest
        });
        // alert("You clicked: " + event.getSource().get("v.label"));
        searchData.setCallback(this, function(rep) {
            if (rep.getState() == "SUCCESS") {
                var ret = rep.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": ret
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(searchData);
    },

    //查询产品编号是否可用
    codeAction : function(component, event, helper) {
        var vTest =  component.get('v.test');
        var searchCode = component.get('c.searchCodeMap');
        searchCode.setParams({
            "code":vTest
        });
        // alert("You clicked: " + event.getSource().get("v.label"));
        searchCode.setCallback(this, function(rep) {
            if (rep.getState() == "SUCCESS") {
                var ret = rep.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if (ret.status) {
                    toastEvent.setParams({
                        "title": "失败！产品编号不可用",
                        "message": ret.productName
                    });
                } else {
                    toastEvent.setParams({
                        "title": "成功！",
                        "message": ret.productName
                    });
                }
                toastEvent.fire();
            }
        });
        $A.enqueueAction(searchCode);
    },

    //accordion例子
    handleShowActiveSectionName: function (cmp, event, helper) {
        alert(cmp.find("accordion").get('v.activeSectionName'));
    },
    //accordion例子
    handleSetActiveSectionC: function (cmp) {
        cmp.find("accordion").set('v.activeSectionName', 'C');
    },

    //datatable例子
    init: function (cmp, event, helper) {
        cmp.set('v.columns', [
            {label: 'Opportunity name', fieldName: 'opportunityName', type: 'text'},
            {label: 'Account name', fieldName: 'accountName', type: 'text'},
            {label: 'Close date', fieldName: 'closeDate', type: 'date'},
            {label: 'Confidence', fieldName: 'confidence', type: 'percentage'},
            {label: 'Amount', fieldName: 'amount', type: 'currency', typeAttributes: { currencyCode: 'EUR', maximumSignificantDigits: 5}},
            {label: 'Contact Email', fieldName: 'contact', type: 'email'},
            {label: 'Contact Phone', fieldName: 'phone', type: 'phone'},
            {label: 'Website', fieldName: 'website', type: 'url', typeAttributes: { target: '_self'}},
            {label: 'Address', fieldName: 'address', type: 'location'}
        ]);

        var fetchData = {
            opportunityName: "company.companyName",
            accountName : "name.findName",
            closeDate : "date.future",
            amount : "finance.amount",
            contact: "internet.email",
            phone : "phone.phoneNumber",
            website : "internet.url",
            status : {type : "helpers.randomize", values : [ 'Pending', 'Approved', 'Complete', 'Closed' ] },
            actionLabel : {type : "helpers.randomize", values : [ 'Approve', 'Complete', 'Close', 'Closed' ]},
            confidenceDeltaIcon : {type : "helpers.randomize", values : [ 'utility:up', 'utility:down' ]}
        };

        helper.fetchData(cmp, fetchData, 10);
    },

    //buttonIconStateful例子
    handleLikeButtonClick : function (cmp) {
        cmp.set('v.liked', !cmp.get('v.liked'));
    },
    handleAnswerButtonClick: function (cmp) {
        cmp.set('v.answered', !cmp.get('v.answered'));
    },

    handleCreateLoad: function (cmp, event, helper) {
        var nameFieldValue = cmp.find("nameField").get("v.value");
        console.log(nameFieldValue);
    },

    handleUploadFinished: function (cmp, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        alert("Files uploaded : " + uploadedFiles.length);

        // Get the file name
        uploadedFiles.forEach(file => console.log(file.name));
    },

    handleKeyUp: function (cmp, evt) {
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            var queryTerm = cmp.find('enter-search').get('v.value');
            alert('Searched for "' + queryTerm + '"!');
        }
    },

    handleActive : function (cmp, event) {
        var menuItem = event.getSource();
        // Toggle check mark on the menu item
        menuItem.set("v.checked", !menuItem.get("v.checked"));
    },

    handleSelect : function (component, event, helper) {
     var stepName = event.getParam("detail").value;
     var toastEvent = $A.get("e.force:showToast");
     toastEvent.setParams({
       "title": "Success!",
        "message": "Toast from " + stepName
        });
        toastEvent.fire();
    }

});