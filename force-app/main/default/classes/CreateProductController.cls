public with sharing class CreateProductController {
    //当前要新增或编辑的产品
    public Product__c product1{get;set;}
    //页数
    public Integer currPage {get; set;}
    //产品编号检查时返回的信息（空为正常）
    public String codeUniqueMessage {get; set;}
    //数据保存类型（新增、编辑）
    public String saveType {get;set;}

    public CreateProductController(ApexPages.StandardController con) {
        product1 = new Product__c();
        this.currPage = 1;
    }

    // 下一页
    public PageReference next() {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'这是下一页'));
        this.currPage ++;
        return null;
    }
    //上一页
    public PageReference prev() {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'这是上一页'));
        if (this.currPage > 0) {
            this.currPage --;
        }
        return null;
    }

    // 模拟查询数据并检测产品描述是否存在
    public PageReference checkProductCodeUnique() {
        codeUniqueMessage = '产品描述存在重复';
        return null;
    }

    public PageReference saveAction() {
        try {     
            INSERT product1;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'插入成功'));
      
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
        return null;
    }

    //取消操作
    public PageReference cancleAction() {
        return new PageReference('/');
    }

    //查询产品名字是否唯一
    @RemoteAction
    public static Boolean checkProductNameUnique(String proName){
        Product__c strName = [SELECT Name
                                FROM Product__c
                                WHERE Name = :proName];
        if (strName != null) {
            return false;
        } else {
            return true;
        }
    }

    // public List<Product__c> productList{get;set;}
    // public String productName {get;set;}
    // public String productCategoriesFirst {get;set;}
    // public String productCategoriesSecond {get;set;}
    // public Integer productInventoryMax {get;set;}
    // public Integer productInventoryMin {get;set;}
    // public Integer productInventory {get;set;} 
    // public Decimal productPrice {get;set;}
    // public String productUnit {get;set;}
    // public String productStatus {get;set;}
    // public String productDescription {get;set;}


    // public CreateProductController() {
    //     productList = new List<Product__c>();
    //     refreshData();
    // }

    // public void refreshData(){
    //     String productSelect = 'SELECT Name,' +
    //                                    'ProductCategoriesFirst__c,' +
    //                                    'ProductCategoriesSecond__c,' +
    //                                    'ProductInventoryMax__c,' +
    //                                    'ProductInventoryMin__c,' +
    //                                    'ProductInventory__c,' +
    //                                    'ProductPrice__c,' +
    //                                    'ProductUnit__c,' +
    //                                    'ProductStatus__c,' +
    //                                    'ProductDescription__c ' +
    //                             'FROM Product__c';
    //     productList = Database.query(productSelect);

    //     this.productName = productList[0].Name;
    // }

    // public void query(String proName){
    //     String strName = 'SELECT Name,' +
    //                             'ProductCategoriesFirst__c,' +
    //                             'ProductCategoriesSecond__c,' +
    //                             'ProductInventoryMax__c,' +
    //                             'ProductInventoryMin__c,' +
    //                             'ProductInventory__c,' +
    //                             'ProductPrice__c,' +
    //                             'ProductUnit__c,' +
    //                             'ProductStatus__c,' +
    //                             'ProductDescription__c ' +
    //                       'FROM Product__c ' + 
    //                      'WHERE Name= :proName';
    // }

    // public PageReference next(){
    //     return null;
    // }

    // public PageReference last(){
    //     return null;
    // }

    // public void saveAction(){

    // }

    // public void checkProductCodeUnique(){

    // }

    // Integer count = 0;
                        
    // public PageReference incrementCounter() {
    //         count++;
    //         return null;
    // }
                    
    // public Integer getCount() {
    //     return count;
    // }



    // WebService static Product__c queryProduct(String proName){
        // Product__c strName = [SELECT Name,
        //                              ProductCategoriesFirst__c,
        //                              ProductCategoriesSecond__c,
        //                              ProductInventoryMax__c,
        //                              ProductInventoryMin__c,
        //                              ProductInventory__c,
        //                              ProductPrice__c,
        //                              ProductUnit__c,
        //                              ProductStatus__c,
        //                              ProductDescription__c 
        //                         FROM Product__c
        //                         WHERE Name = :proName];
    //     return strName;
    // }

}