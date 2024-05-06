({
    myAction : function(component, event, helper) {
    
    },

    //显示全部按钮
    init : function (cmp, event, helper) {
        cmp.set('v.mycolumns', [
            { label: '借阅编号', fieldName: 'Name', type: 'text'},
            { label: '图书名称', fieldName: 'bookName__c', type: 'text'},
            { label: '读者姓名', fieldName: 'readerName__c', type: 'text'},
            { label: '读者编号', fieldName: 'readerId__c', type: 'text'},
            { label: '借阅日期', fieldName: 'borrowingDate__c', type: 'date'},
            { label: '应还日期', fieldName: 'borrowDueDate__c', type: 'date'},
            { label: '缴费金额', fieldName: 'borrowPaymentAmount__c', type: 'currency'}
        ]);
        helper.getData(cmp);
    },

    //根据读者姓名查询按钮
    getreaderName : function(cmp, event, helper) {
        var readerName = cmp.get('v.readerName');
        cmp.set('v.mycolumns', [
            { label: '借阅编号', fieldName: 'Name', type: 'text'},
            { label: '图书名称', fieldName: 'bookName__c', type: 'text'},
            { label: '读者姓名', fieldName: 'readerName__c', type: 'text'},
            { label: '读者编号', fieldName: 'readerId__c', type: 'text'},
            { label: '借阅日期', fieldName: 'borrowingDate__c', type: 'date'},
            { label: '应还日期', fieldName: 'borrowDueDate__c', type: 'date'},
            { label: '缴费金额', fieldName: 'borrowPaymentAmount__c', type: 'currency'}
        ]);
        helper.getreaderData(cmp, readerName);
        cmp.set('v.readerName', '');
    },

    //获取选中行的Id
    getSelected : function(cmp, event, helper) {
        var selectedRow = event.getParam('selectedRows');
        var borrowList = new Array();
        for (var i = 0; i < selectedRow.length; i++){
            console.log(selectedRow[i].Id);
            borrowList.push(selectedRow[i].Id);
        }
        cmp.set('v.borrowIdList', borrowList);
    },

    //还书按钮事件
    returnBook : function(cmp, event, helper) {
        cmp.set('v.mycolumns', [
            { label: '借阅编号', fieldName: 'Name', type: 'text'},
            { label: '图书名称', fieldName: 'bookName__c', type: 'text'},
            { label: '读者姓名', fieldName: 'readerName__c', type: 'text'},
            { label: '读者编号', fieldName: 'readerId__c', type: 'text'},
            { label: '借阅日期', fieldName: 'borrowingDate__c', type: 'date'},
            { label: '应还日期', fieldName: 'borrowDueDate__c', type: 'date'},
            { label: '缴费金额', fieldName: 'borrowPaymentAmount__c', type: 'currency'}
        ]);
        helper.setReturnBook(cmp);
    },

    //自动还书事件
    autoReturnBook : function(cmp, event, helper) {
        var borrowchildBookIdValue = cmp.find("borrowchildBookId").get("v.value");
        helper.setAutoReturnBook(cmp, borrowchildBookIdValue);
    }
})