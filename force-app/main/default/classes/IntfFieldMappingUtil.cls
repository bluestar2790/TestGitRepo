/**
接口字段映射工具类，用于接口定义后，将接口的字段与对象进行映射，方便接口处理
**/
public without sharing class IntfFieldMappingUtil {
    public InterfaceFeildModel fieldMap; // 设置接口字段数据结构
    public SobjectWarpper allResult;

    //初始化将接口定义对应的字段映射数据查询出 interfaceName：接口名称
    public IntfFieldMappingUtil (String interfaceName) {
        // 设置接口字段数据结构
        InterfaceFeildModel fieldMap = new InterfaceFeildModel();
        for (InterfaceFieldMapping__c item : [
            SELECT Id, Name, SfdcObj__c, SfdcField__c, SfdcFieldType__c, 
                   InterfaceObj__c, InterfaceField__c, ParentObjectField__c, 
                   InterfaceFieldType__c, ForUpsert__c, ParentObject__c, 
                   IsRequired__c, RegularCheck__c, IsErrorFlag__c, SfdcDetailObj__c
            FROM InterfaceFieldMapping__c 
            WHERE IntfDefineName__c =: interfaceName 
            ORDER BY Name
        ]) {
            // 构造接口对象字段映射
            fieldMap.setIntfObjMap(item);
            // 如果必填
            if (item.IsRequired__c) {
                // 设置所有必填字段映射
                fieldMap.setRequiredMap(item);
            }
            // 是否是错误标志
            if (item.isErrorFlag__c) {
                // Sobject对象名 => 错误标识字段名
                fieldMap.errorFlagMap.put(item.SfdcObj__c, item);
            }
            // 用于Upsert
            if (item.ForUpsert__c) {
                // Sobject对象名 => Sobject字段名
                fieldMap.sobjectKeyMap.put(item.SfdcObj__c, item);
            }
            // 对象名-字段名
            String key = item.InterfaceObj__c + '-' + item.InterfaceField__c;
            // intfObject-intfFieldName => 接口字段映射配置数据
            fieldMap.intfFiledsMap.put(key, item);
            // fieldMap.intfFiledsMap.put(item.InterfaceField__c, item);
        }

        this.fieldMap = fieldMap;
        this.allResult = new SobjectWarpper();
    }

    // 根据对象名获取具体对象
    public Sobject instanceSobjectByName (String sobjectName) {
        System.debug(LoggingLevel.INFO, '*** sobjectName: ' + sobjectName);
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get(sobjectName);
        return convertType.newSObject();
        // Type typSObject = Type.forName(sobjectName);
        // return (Sobject)typSObject.newInstance(); 
    }

    /* 
        根据传入的数据，对象及接口名，将数据放入内部内中，这个过程中会对数据进行校验
        objData: 接口传递过来的数据
        sobjectName: 映射配置主对象名(SF)
        intfObjName: 映射配置主对象名
    */
    public void generateSobject (Map<String, Object> objData, String sobjectName, String intfObjName) {
        System.debug(LoggingLevel.INFO, '*** sobjectName: ' + sobjectName + ', intfObjName: ' + intfObjName);
        // 根据对象名获取具体对象
        Sobject sobj = instanceSobjectByName(sobjectName);
        String sobjErrorMsg = '';

        // 必填校验，json中不能缺少必填字段
        if (fieldMap.requiredMap.containsKey(intfObjName)) {
            for (InterfaceFieldMapping__c requiredFieldItem : fieldMap.requiredMap.get(intfObjName)) {
                String intfFieldName = requiredFieldItem.InterfaceField__c;
                // 接口传递过来的数据没有包含必填字段，报错
                if (!objData.keySet().contains(intfFieldName)) {
                    sobjErrorMsg += '[' + intfFieldName + ']: 必填！ ' + ';';
                } else { // 接口传递过来的数据包含必填字段，但必填字段值为空，报错
                    String objValue = String.valueOf(objData.get(intfFieldName));
                    if (String.isBlank(objValue)) {
                        sobjErrorMsg += '[' + intfFieldName + ']: 必填！ '+ ';';
                    }
                }
            }
        }

        // 必填校验成功，才做字段映射
        if (String.isBlank(sobjErrorMsg)) {
            System.debug(LoggingLevel.INFO, '*** this.fieldMap.intfFiledsMap: ' + JSON.serialize(this.fieldMap.intfFiledsMap));
            // 循环接口传递过来的数据
            for (String intfFieldName : objData.keySet()) {
                // 接口对象名 + '-' + 接口字段名作为唯一标识，获取对应的映射配置
                String key = intfObjName + '-' + intfFieldName;
                System.debug(LoggingLevel.INFO, '*** key: ' + key);
                // 没有Json中的字段没有配置映射跳过
                if (!this.fieldMap.intfFiledsMap.containsKey(key)) {
                    System.debug(LoggingLevel.INFO, '*** 【' + key + '】 not have field mapping');
                    continue;
                }

                InterfaceFieldMapping__c fieldMapping = this.fieldMap.intfFiledsMap.get(key);
                // 字段值
                Object objFieldValue = objData.get(intfFieldName);
                
                System.debug(LoggingLevel.INFO, '*** '+key +': ' + objFieldValue);
                // 如果字段值是空，跳过
                if (objFieldValue == null) { 
                    continue;
                }
                // 字段正则校验
                String theErrorMsg = checkDataValidity(objFieldValue, fieldMapping.RegularCheck__c);
                if (String.isNotBlank(theErrorMsg)) {
                    System.debug(LoggingLevel.INFO, '*** theErrorMsg: ' + theErrorMsg);
                    sobjErrorMsg = '[' + intfFieldName + ']: ' + theErrorMsg + '  ' + sobjErrorMsg;
                }
                // 如果字段值是空，跳过该字段赋值
                if (objFieldValue == null) {  // || objFieldValue == ''
                    // 对象字段赋值
                    sobj.put(fieldMapping.SfdcField__c, null);
                    System.debug(LoggingLevel.INFO, '*** [' + intfFieldName + '] filed value is null. ');
                    continue;
                }

                // 如果字段是查找，就建立关联关系并赋值外键
                if (fieldMapping.SfdcFieldType__c == 'Reference') {
                    System.debug(LoggingLevel.INFO, '*** Reference: ' + intfFieldName);
                    // 如果查找字段值不为空，关联父级
                    if(objFieldValue != '') {
                        System.debug(LoggingLevel.INFO, '*** objFieldValue: ' + objFieldValue);
                        System.debug(LoggingLevel.INFO, '*** fieldMapping.ParentObject__c: ' + fieldMapping.ParentObject__c);
                        System.debug(LoggingLevel.INFO, '*** fieldMapping.ParentObjectField__c: ' + fieldMapping.ParentObjectField__c);
                        System.debug(LoggingLevel.INFO, '*** fieldMapping.SfdcField__c: ' + fieldMapping.SfdcField__c);
                        // 根据查找字段父级对象名获取父级具体对象
                        Sobject parentSobj = instanceSobjectByName(fieldMapping.ParentObject__c);
                        // 父级对象字段赋值
                        parentSobj.put(fieldMapping.ParentObjectField__c, String.valueOf(objFieldValue));
                        // 通过putSObject方法关联上父级
                        sobj.putSObject(fieldMapping.SfdcField__c, parentSobj);
                    } else { // 如果查找字段值为空，需要把字段__r替换成__c
                        String tempField = '';
                        String tempString = '';
                        String sfdcField = fieldMapping.SfdcField__c;
                        //把__r转化成为__c
                        if(String.isNotBlank(sfdcField) 
                            && sfdcField.endsWith('__r')) {
                            tempString = sfdcField.left(sfdcField.length()-1);
                            tempField = tempString +'c';
                        }
                        if(String.isNotBlank(tempField)) {
                          sobj.put(tempField, null);
                        }
                    }
                    continue;
                }

                // 根据不同字段类型，进行转换并赋值
                try {
                     
                    switch on fieldMapping.InterfaceFieldType__c {
                        when 'Date' {
                            String intfStr = Json.serialize(objFieldValue);

                            if(intfStr != null && intfStr != '' && intfStr != '""'){
                                Date adate = (Date)JSON.deserialize(intfStr, Date.Class);
                                System.debug(LoggingLevel.INFO, '*** adate: ' + adate);
                                sobj.put(fieldMapping.SfdcField__c, adate);
                            }
                        }
                        when 'Datetime' {
                            // sobj.put(fieldMapping.SfdcField__c, Datetime.valueOf(objFieldValue));
                            String intfStr = (string)objFieldValue;
                            if(intfStr != null && intfStr != '' && intfStr != '""'){
                                Datetime atime = Datetime.valueOf(intfStr);
                                System.debug(LoggingLevel.INFO, '*** atime: ' + atime);

                                // if (atime != null) {
                                //     atime = atime.addHours(-8);
                                // }
                                sobj.put(fieldMapping.SfdcField__c, atime);
                            }
                            
                        }
                        when 'Decimal' {
                            String intfStr = String.valueOf(objFieldValue);
                            sobj.put(fieldMapping.SfdcField__c, Decimal.valueOf(intfStr));
                        }
                        when 'String' {
                            sobj.put(fieldMapping.SfdcField__c, String.valueOf(objFieldValue));
                        }
                        when 'Boolean' {
                            // sobj.put(fieldMapping.SfdcField__c, Boolean.valueOf(objFieldValue));
                            String intfStr = String.valueOf(objFieldValue);
                            Boolean bvalue = (Boolean)JSON.deserialize(intfStr, Boolean.Class);
                            sobj.put(fieldMapping.SfdcField__c, bvalue);
                        }
                        when 'Integer' {
                            String intfStr = String.valueOf(objFieldValue);
                            sobj.put(fieldMapping.SfdcField__c, Integer.valueOf(intfStr));
                        }
                        when 'List' {
                            System.debug(LoggingLevel.INFO, '*** list: ' + objFieldValue);
                            // if (objFieldValue != null) {
                            for (Object internalValue : (List<Object>)objFieldValue) {
                                // 接口字段名作为下一层的接口对象名
                                generateSobject((Map<String, Object>)internalValue, fieldMapping.SfdcObj__c, fieldMapping.InterfaceField__c);
                            }
                            // }
                        }
                        when else { //object
                            System.debug(LoggingLevel.INFO, '*** else: ' + objFieldValue);
                            generateSobject((Map<String, Object>)objFieldValue, fieldMapping.SfdcObj__c, fieldMapping.InterfaceField__c);
                        }
                    }
                } catch (Exception e) {
                    String exceptionError = e.getLineNumber() + ':' + e.getMessage();
                    System.debug(LoggingLevel.INFO, '*** exceptionError: ' + exceptionError);
                    sobjErrorMsg = '[' + intfFieldName + ']: ' + exceptionError + '  ' + sobjErrorMsg;
                } 
            }

            // 保存所有映射结果
            // String sobjectType = sobj.getSObjectType().getDescribe().getName();
            allResult.setAllData(sobjectName, sobj);

            // 保存有效结果
            if (String.isBlank(sobjErrorMsg)) {
                allResult.setInvalidData(sobjectName, sobj);
                return;
            }
        }

        // 保存错误消息
        InterfaceFieldMapping__c errorFlag = fieldMap.errorFlagMap.get(sobjectName);
        System.debug(LoggingLevel.INFO, '*** errorFlag: ' + errorFlag);
        String keyFieldValue = '';
        if (errorFlag != null) {
            System.debug(LoggingLevel.INFO, '*** errorFlagKey: ' + objData.get(errorFlag.InterfaceField__c));
            keyFieldValue = String.valueOf(objData.get(errorFlag.InterfaceField__c));
        }
        allResult.setErrorMap(keyFieldValue, sobjErrorMsg);
    }
    /*
        把接口传递过来的数据转成SF对象数据
        objData: 接口传递过来的数据
        mainSobjectName: 映射配置主对象名(SF)
        mainIntfObjName: 映射配置主对象名
    */
    public void toSobject (Object objData, String mainSobjectName, String mainIntfObjName) {
        // get object's type， 获取对象类型
        String typeStr = getType(objData);
        System.debug(LoggingLevel.INFO, '*** typeStr: ' + typeStr);

        // 判断对象的类型，如果是List就循环调用，如果是简单类型直接返回
        switch on typeStr {
            when 'List' {
                for (Object obj : (List<Object>) objData) {
                    Map<String, Object> objMap = (Map<String, Object>) obj;
                    generateSobject(objMap, mainSobjectName, mainIntfObjName);
                }
            }
            when 'Object' {
                Map<String, Object> objMap = (Map<String, Object>) objData;
                generateSobject(objMap, mainSobjectName, mainIntfObjName);
            }
            when else {
                System.debug(LoggingLevel.INFO, '*** other JSON Type. ');
                return;
            }
        }
    }

/*
    // 根据配置将SF数据转成对应Json, 暂未用到
    public Object generateObject (Sobject theSobject, String sobjectName, String intfObjName) {
        // JSONGenerator gen = JSON.createGenerator(true);
        // gen.writeStartObject();
        Map<String, Object> objectMap = new Map<String, Object>();

        String sobjErrorMsg = '';

        if (!fieldMap.intfObjMap.containsKey(intfObjName)) {
            System.debug(LoggingLevel.INFO, '*** 【' + intfObjName + '】 接口对象未找到!');
            return objectMap;
        }

        for (InterfaceFieldMapping__c ifm : fieldMap.intfObjMap.get(intfObjName)) {
            try {
                // 根据不同字段类型，进行转换并赋值
                if (ifm.InterfaceFieldType__c == 'List') {
                    // 循环子对象 
                    List<Sobject> sfdcDetails = (List<Sobject>)theSobject.getSObjects(ifm.SfdcDetailObj__c);
                    System.debug(LoggingLevel.INFO, '*** [' + ifm.SfdcDetailObj__c+ '] list: ' + sfdcDetails.size());

                    List<Object> alist = new List<Object>();
                    for (Sobject aItem : sfdcDetails) {
                        // 接口字段名作为下一层的接口对象名
                        Object result = generateObject(aItem, ifm.SfdcDetailObj__c, ifm.InterfaceField__c);
                        alist.add(result);
                    }

                    objectMap.put(ifm.InterfaceField__c, alist);
                    continue;
                }

                Object sfdcValue;
                if (ifm.SfdcFieldType__c == 'Reference' ){
                    sfdcValue = theSobject.getSobject(ifm.SfdcField__c).get(ifm.ParentObjectField__c);
                    // objectMap.put(ifm.InterfaceField__c, Integer.valueOf(rSfdcValue));
                } else {
                    if (String.isNotBlank(ifm.SfdcField__c)){
                        sfdcValue = theSobject.get(ifm.SfdcField__c);
                    } else {
                        System.debug(LoggingLevel.INFO, '*** ifm: ' + ifm);
                    }
                }

                if (sfdcValue == null) {
                    objectMap.put(ifm.InterfaceField__c, null);
                    continue;
                }

                switch on ifm.InterfaceFieldType__c {
                    when 'Date' {
                        objectMap.put(ifm.InterfaceField__c, Date.valueOf(sfdcValue));
                    }
                    when 'Datetime' {
                        objectMap.put(ifm.InterfaceField__c, Datetime.valueOf(sfdcValue));
                    }
                    when 'Decimal' {
                        objectMap.put(ifm.InterfaceField__c, (Decimal)sfdcValue);
                    }
                    when 'String' {
                        objectMap.put(ifm.InterfaceField__c, String.valueOf(sfdcValue));
                    }
                    when 'Boolean' {
                        objectMap.put(ifm.InterfaceField__c, Boolean.valueOf(sfdcValue));
                    }
                    when 'Integer' {
                        objectMap.put(ifm.InterfaceField__c, Integer.valueOf(sfdcValue));
                    }
                    when else { //object
                        System.debug(LoggingLevel.INFO, '*** else SfdcField : ' + ifm.SfdcField__c);
                        // generateSobject((Map<String, Object>)objFieldValue, ifm.SfdcObj__c, ifm.InterfaceField__c);
                    }
                }
            } catch (Exception e) {
                String exceptionError = e.getLineNumber() + ':' + e.getMessage();
                System.debug(LoggingLevel.INFO, '*** exceptionError: ' + exceptionError);
                sobjErrorMsg = '[' + ifm.SfdcField__c + ']: ' + exceptionError + '  ' + sobjErrorMsg;
            }
        }

        // 保存所有映射结果
        // gen.writeEndObject();

        // 保存错误消息
        if (String.isNotBlank(sobjErrorMsg)) {
            InterfaceFieldMapping__c errorFlag = fieldMap.errorFlagMap.get(sobjectName);
            System.debug(LoggingLevel.INFO, '*** errorFlag: ' + errorFlag);

            String keyFieldValue = '';
            if (errorFlag != null) {
                System.debug(LoggingLevel.INFO, '*** errorFlagKey: ' + theSobject.get(errorFlag.SfdcField__c));
                keyFieldValue = String.valueOf(theSobject.get(errorFlag.SfdcField__c));
            }
            allResult.setErrorMap(keyFieldValue, sobjErrorMsg);
        }

        // return gen.getAsString();
        return objectMap;
    }

    // 将sfobject 根据字段映射成 object List
    public void toObjectList (List<Id> sobjectIds, String mainSobjectName, String mainIntfObjName) {
        String soqlStr = generateQueryStr(mainSobjectName, mainIntfObjName)  + ' WHERE Id IN: sobjectIds';
        System.debug(LoggingLevel.INFO, '*** soqlStr: ' + soqlStr);

        List<Sobject> sobjectList = Database.query(soqlStr);
        System.debug(LoggingLevel.INFO, '*** sobjectList.size(): ' + sobjectList.size());

        List<Object> alist = new List<Object>();
        for (Sobject aItem : sobjectList) {
            // 接口字段名作为下一层的接口对象名
            Object result = generateObject(aItem, mainSobjectName, mainIntfObjName);
            alist.add(result);
        }
        System.debug(LoggingLevel.INFO, '*** alist.size(): ' + alist.size());

        allResult.objData = alist;
    }

    public String generateQueryStr (String mainSobjectName, String mainIntfObjName) {
        Map<String, String> soqlMap = new Map<String, String>();
        Map<String, String> sobjectNameMap = new Map<String, String>();
        String soqlStr = '';
        for (String key : fieldMap.intfObjMap.keySet()) {
            String aStr = 'SELECT ';
            String sobjectName = '';
            for (InterfaceFieldMapping__c ifm : fieldMap.intfObjMap.get(key)) {
                if (String.isNotBlank(ifm.SfdcField__c)) {
                    if (ifm.SfdcFieldType__c == 'Reference') {
                        aStr += ifm.SfdcField__c + '.' + ifm.ParentObjectField__c;
                    } else {
                        aStr += ifm.SfdcField__c;
                    }

                    aStr += ', ';
                } 

                if (ifm.InterfaceFieldType__c == 'List') {
                    sobjectNameMap.put(ifm.SfdcObj__c, ifm.SfdcDetailObj__c);
                } else {
                    sobjectName = ifm.SfdcObj__c;
                }
            }

            System.debug(LoggingLevel.INFO, '*** sobjectName: ' + sobjectName);
            if (sobjectName != mainSobjectName) {
                soqlMap.put(sobjectName, aStr);
            } else if (sobjectName == mainSobjectName){
                soqlStr = aStr.removeEnd(', ');
            }

            // System.debug(LoggingLevel.INFO, '*** aStr: ' + aStr);
        }

        // System.debug(LoggingLevel.INFO, '*** soqlStr: ' + soqlStr);
        for (String key : soqlMap.keySet()) {
            String aStr =  soqlMap.get(key);
            String sobjectName = sobjectNameMap.get(key);
            aStr = '(' + aStr.removeEnd(', ') + ' FROM ' + sobjectName + ')';
            soqlStr += ', ' + aStr;
        }

        soqlStr += ' FROM ' + mainSobjectName;
        // System.debug(LoggingLevel.INFO, '*** soqlStr: ' + soqlStr);
        return soqlStr;
    }
*/
    /*
        字段正则校验
        fieldValue: 字段值
        regularCheck: 正则表达式
    */
    public static String checkDataValidity (Object fieldValue, String regularCheck) {
        // 正则校验
        if (fieldValue != null && String.isNotBlank(regularCheck)) {
            String fieldValueStr = String.valueOf(fieldValue);

            if (String.isBlank(fieldValueStr)) {
                return '';
            }

            System.debug(LoggingLevel.INFO, '*** fieldValue: ' + fieldValue);
            System.debug(LoggingLevel.INFO, '*** regularCheck: ' + regularCheck);

            Pattern p = Pattern.compile(regularCheck);
            Matcher m = p.matcher(fieldValueStr);

            if (m.matches()) {
                System.debug(LoggingLevel.INFO, '*** 匹配成功. ');
            // m.matches(); //returns true, the string matches the pattern
            // m.group(0); //returns group 0 = 'foobar'
            // m.groupCount(); //returns 1, self-explanatory
                return '';
            }

            return '格式不对！';
        }

        return '';
    }
    // 获取对象类型
    public static string getType(Object o) {
        if (o == null)                    return ''; // we can't say much about null with our current techniques
        if (o instanceof SObject)         return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if (o instanceof Boolean)         return 'Boolean';
        if (o instanceof Id)              return 'Id';
        if (o instanceof String)          return 'String';
        if (o instanceof Blob)            return 'Blob';
        if (o instanceof Date)            return 'Date';
        if (o instanceof Datetime)        return 'Datetime';
        if (o instanceof Time)            return 'Time';
        if (o instanceof String)          return 'String';
        if (o instanceof Integer)         return 'Integer';
        if (o instanceof Long)            return 'Long';
        if (o instanceof Decimal)         return 'Decimal'; // we can't distinguish between decimal and double
        if (o instanceof Double)          return 'Double'; // we can't distinguish between decimal and double
        if (o instanceof List<object>)    return 'List';
        return 'Object';                    // actually we can't detect maps and sets and maps
    }

    public class InterfaceFeildModel {
        // public Map<String, List<InterfaceFieldMapping__c>> intfFieldMapping;

        // upsert key Field Map: Sobject对象名 => Sobject字段名
        public Map<String, InterfaceFieldMapping__c> sobjectKeyMap;
        // 所有字段映射: key  intfObject-intfFieldName => 接口字段映射配置数据
        public Map<String, InterfaceFieldMapping__c> intfFiledsMap;
        // 错误提醒字段Map: Sobject对象名 => 错误标识字段名
        public Map<String, InterfaceFieldMapping__c> errorFlagMap;
        // 所有必填字段映射: objName => 接口字段list
        public Map<String, List<InterfaceFieldMapping__c>> requiredMap;
        // 接口对象字段映射： objName => 接口字段list
        public Map<String, List<InterfaceFieldMapping__c>> intfObjMap;


        public InterfaceFeildModel () {
            // this.intfFieldMapping = new Map<String, List<InterfaceFieldMapping__c>>();
            this.sobjectKeyMap = new Map<String, InterfaceFieldMapping__c>();
            this.intfFiledsMap = new Map<String, InterfaceFieldMapping__c>();
            this.errorFlagMap = new Map<String, InterfaceFieldMapping__c>();
            this.requiredMap = new Map<String, List<InterfaceFieldMapping__c>>();
            this.intfObjMap = new Map<String, List<InterfaceFieldMapping__c>>();
        }
        // 设置所有必填字段映射: InterfaceFieldMapping__c: 接口字段映射配置
        public void setRequiredMap (InterfaceFieldMapping__c item) {
            List<InterfaceFieldMapping__c> alist;
            if (requiredMap.containsKey(item.InterfaceObj__c)) {
                alist = requiredMap.get(item.InterfaceObj__c);
            } else {
                alist = new List<InterfaceFieldMapping__c>();
            }

            alist.add(item);
            // 必填字段映射: objName => 接口字段list
            requiredMap.put(item.InterfaceObj__c, alist);
        }
        // 构造接口对象字段映射 InterfaceFieldMapping__c: 接口字段映射配置
        public void setIntfObjMap (InterfaceFieldMapping__c item) {
            List<InterfaceFieldMapping__c> alist;
            if (intfObjMap.containsKey(item.InterfaceObj__c)) {
                alist = intfObjMap.get(item.InterfaceObj__c);
            } else {
                alist = new List<InterfaceFieldMapping__c>();
            }

            alist.add(item);
            // 接口对象字段映射： objName => 接口字段list
            intfObjMap.put(item.InterfaceObj__c, alist);
        }
    }

    public class SobjectWarpper {
        public Map<String, List<Sobject>> allData; // 所有数据
        public Map<String, List<Sobject>> invalidData; // 有效数据
        public Map<String, String> errorMap; // 错误信息
        public Object objData; // 对象数据

        public SobjectWarpper () {
            this.errorMap = new Map<String, String>();
            this.allData = new Map<String, List<Sobject>> ();
            this.invalidData = new Map<String, List<Sobject>> ();
        }
        /*
            设置有效数据值
            sobjectType: 对象名
            sobj: 对象数据
        */
        public void setInvalidData (String sobjectType, Sobject sobj) {
            List<Sobject> alist =  new List<Sobject>();

            if (invalidData.containsKey(sobjectType)) {
                alist = invalidData.get(sobjectType);
            }

            alist.add(sobj);
            invalidData.put(sobjectType, alist);
        }
        /*
            设置所有数据值
            sobjectType: 对象名
            sobj: 对象数据
        */
        public void setAllData (String sobjectType, Sobject sobj) {
            List<Sobject> alist =  new List<Sobject>();

            if (allData.containsKey(sobjectType)) {
                alist = allData.get(sobjectType);
            }

            alist.add(sobj);
            allData.put(sobjectType, alist);
        }
        /*
            设置错误数据
            keyValue: 接口字段
            errorMsg: 错误信息
        */
        public void setErrorMap (String keyValue, String errorMsg) {
            System.debug(LoggingLevel.INFO, '*** keyValue:' + keyValue + ' errorMsg: ' + errorMsg);
            String previousMsg = '';

            if (String.isBlank(keyValue)) {
                keyValue = '';
            }

            if (errorMap.containsKey(keyValue)) {
                previousMsg = errorMap.get(keyValue) + '  ';
            }

            previousMsg += errorMsg;
            errorMap.put(keyValue, previousMsg);
        }
    }
}