(function (root,factory){
  if (typeof define === 'function' && define.amd) {
    /*AMD. Register as an anonymous module.
    *define([], factory); */
    define([], factory());
  } else if (typeof module === 'object' && module.exports) {
    /*Node. Does not work with strict CommonJS, but
    // only CommonJS-like environments that support module.exports,
    // like Node.*/
    module.exports = factory();

  } else {
    /*Browser globals (root is window)*/
    root['sf1_utility'] = factory();
  }
}(this,function(){
	//声明函数
	let sf1_utility = {};
	/**
     * 截取字符串
     * @param str 目标字符串
     * @return 截取后的字符串
     * @authr cy
     */
    function padLeftZero(str) {
        return ('00' + str).substr(str.length);
    }

    /*
     * 格式化时间
     * @param date 日期
     * @param fmt 格式
     * @author cy
     */
    sf1_utility.formatDate = function(tempDate, fmt) {
        if (!tempDate) return '';
        let date;
        try {
            date = new Date(tempDate);
        } catch (ex) {
            return '';
        }
        if (/(y+)/.test(fmt)) {
            fmt = fmt.replace(RegExp.$1, (date.getFullYear() + '').substr(4 - RegExp.$1.length));
        }
        let o = {
            'M+': date.getMonth() + 1,
            'd+': date.getDate(),
            'h+': date.getHours(),
            'm+': date.getMinutes(),
            's+': date.getSeconds()
        };
        for (let k in o) {
            if (new RegExp(`(${k})`).test(fmt)) {
                let str = o[k] + '';
                fmt = fmt.replace(RegExp.$1, (RegExp.$1.length === 1) ? str : padLeftZero(str));
            }
        }
        return fmt;
    }

    /**
     *执行远程方法 最多5个参数
     *@param methodName 方法名称
     *@parma ...params 参数列表
     *author cy
     */
    sf1_utility.remoteAction = function(methodName, ...params) {
        if (params != null && params != undefined && params.length > 0) {
            if (params.length == 1) {
                return new Promise((resove, reject) => {
                    Visualforce.remoting.Manager.invokeAction(methodName, params[0], (data, event) => {
                        if (event.status) {
                            resove(data);
                        } else if (event.type === 'exception') {
                            reject(event.message);
                        } else {
                            reject(event.message);
                        }
                    }, { escape: false });
                });
            } else if (params.length == 2) {
                return new Promise((resove, reject) => {
                    Visualforce.remoting.Manager.invokeAction(methodName, params[0], params[1], (data, event) => {
                        if (event.status) {
                            resove(data);
                        } else if (event.type === 'exception') {
                            reject(event.message);
                        } else {
                            reject(event.message);
                        }
                    }, { escape: false });
                });
            } else if (params.length == 3) {
                return new Promise((resove, reject) => {
                    Visualforce.remoting.Manager.invokeAction(methodName, params[0], params[1], params[2], (data, event) => {
                        if (event.status) {
                            resove(data);
                        } else if (event.type === 'exception') {
                            reject(event.message);
                        } else {
                            reject(event.message);
                        }
                    }, { escape: false });
                });
            } else if (params.length == 4) {
                return new Promise((resove, reject) => {
                    Visualforce.remoting.Manager.invokeAction(methodName, params[0], params[1], params[2], params[3], (data, event) => {
                        if (event.status) {
                            resove(data);
                        } else if (event.type === 'exception') {
                            reject(event.message);
                        } else {
                            reject(event.message);
                        }
                    }, { escape: false });
                });
            } else if (params.length == 5) {
                return new Promise((resove, reject) => {
                    Visualforce.remoting.Manager.invokeAction(methodName, params[0], params[1], params[2], params[3], params[4], (data, event) => {
                        if (event.status) {
                            resove(data);
                        } else if (event.type === 'exception') {
                            reject(event.message);
                        } else {
                            reject(event.message);
                        }
                    }, { escape: false });
                });
            } else {
                return new Promise((resove, reject) => {
                    reject('参数过多不支持此方法!');
                });
            }
        } else {
            return new Promise((resove, reject) => {
                Visualforce.remoting.Manager.invokeAction(methodName, ...params, (data, event) => {
                    if (event.status) {
                        resove(data);
                    } else if (event.type === 'exception') {
                        reject(event.message);
                    } else {
                        reject(event.message);
                    }
                }, { escape: false });
            });
        }
    }
    
	return sf1_utility;
}));