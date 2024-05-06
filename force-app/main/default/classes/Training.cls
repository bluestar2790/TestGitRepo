public without sharing class Training {
    private String strings;
	private Decimal dnumbers;
	private Integer iCount = 100;
	private Date dateAfterDay7 = System.today() + 7;
	private Time timeAfterMinute5 = System.now().addMinutes(5).Time();
	private Datetime dateTimeNow = System.now();

	private List<String> strList = new List<String>{'day1', 'day2', 'day3', 'day4', 'day5'};
	private Set<String> strSet = new Set<String>{'setday1', 'setday2', 'setday3', 'setday4', 'setday5'};
	private Map<String, Integer> tempMap = new Map<String, Integer>{'map1' => 1, 'map2' => 2, 'map3' => 3, 'map4' => 4, 'map5' => 5};

    //循环输出从0到自身的数值
    /*
        目的：
        参数：
        返回值：
    */
	public void printint(){
		for (Integer i = 0; i <= iCount; i++ ) {
			System.debug(LoggingLevel.INFO, '*** i: ' + i);

		}
	} 


    //按下标循环输出list、set、map
	public void printListSetMap(){
		for(Integer j = 0; j < strList.size(); j++){
			System.debug(LoggingLevel.INFO, '*** strList[' + j + '] = ' + strList[j]);
			// System.debug(LoggingLevel.INFO, '*** strSet: ' + strSet.get(j));
			// System.debug(LoggingLevel.INFO, '*** tempMap: ' + this.tempMap);
		}

        Integer k = 0;
		for(String str: strSet){
			System.debug(LoggingLevel.INFO, '*** strSet[' + k +'] = ' + str);
            k++;
		}

        k = 0;
		for (String key: tempMap.keySet() ) {
        	System.debug(LoggingLevel.INFO, '*** key: ' + key +'*** value:' +tempMap.values().get(k));
            k++;
   		}
	}

    //set、map添加数据
	public void addset(){
		strSet.add('setday1');
		strSet.add('setday6');
		System.debug(LoggingLevel.INFO, '*** : ' + strSet);
	}

	public Training(){
		printint();
		printListSetMap();
		addset();
	}


}