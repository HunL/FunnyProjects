"use strict";

var HomeWorkItem = function(text) {
	if (text) {
		var obj = JSON.parse(text);
		this.key = obj.key;
		this.value = obj.value;
		this.author = obj.author;
        this.time = obj.time;
	} else {
	    this.key = "";
	    this.author = "";
	    this.value = "";
        this.time = "";
	}
};

HomeWorkItem.prototype = {
	toString: function () {
		return JSON.stringify(this);
	}
};

var SuperHomeWork = function () {
    LocalContractStorage.defineMapProperty(this, "dataMap", {
    // LocalContractStorage.defineMapProperty(this, "repo", {
        stringify: function (obj) {
            return obj.toString();
        },
        parse: function (text) {
            return new HomeWorkItem(text);
        }
    });

    // LocalContractStorage.defineMapProperty(this, "repoArray", {
    //     stringify: function (obj) {
    //         // 存储时直接转为字符串
    //         return obj.toString();
    //     },
    //     parse: function (text) {
    //         // 读取时获得HomeWorkItem对象
    //         return new HomeWorkItem(text);
    //     }
    // });
    LocalContractStorage.defineMapProperty(this, "arrayMap");
    // LocalContractStorage.defineMapProperty(this, "dataMap");
    LocalContractStorage.defineProperty(this, "size");

};

SuperHomeWork.prototype = {
    init: function () {
        this.size = 0;
    },

    save: function (key, value) {
        key = key.trim();
        value = value.trim();
        if (key === "" || value === ""){
            throw new Error("empty key / value");
        }
        if (value.length > 64 || key.length > 64){
            throw new Error("key / value exceed limit length");
        }

        var from = Blockchain.transaction.from;
        
        homeworkItem = new HomeWorkItem();
        homeworkItem.author = from;
        homeworkItem.key = key;
        homeworkItem.value = value;
        homeworkItem.time = Date.Now();

        var index = this.size;
        this.arrayMap.set(index, key);
        this.dataMap.set(key, homeworkItem);
        // this.repo.put(key, homeworkItem);

        // this.HomeWorkKeyArray.push(homeworkItem);
        // this.repo.HomeWorkKeyArray.push(homeworkItem);
        // this.repoArray.push(key, homeworkItem);
        this.size += 1;
    },

    // get: function () {
    //     console.log("here get");
    //     this.repoArray.sort(
    //         function(v1, v2){
    //             return v1.time-v2.time;
    //         });
    //     return this.repoArray.splice(0,4);
    // }
    get: function (key) {
        // return this.dataMap.get(key);
        return "111";
    },

    len: function () {
        // return this.size;
        return "222";
    },

    fiveData: function (offset) {
    // fiveData: function (limit, offset) {
        // limit = parseInt(limit);
        limit = parseInt(5);
        offset = parseInt(offset);

        if (offset > this.size) {
            throw new Error("offset is not valid");
        }

        var num = offset + limit;
        if (num > this.size) {
            num = this.size;
        }

        var result = "";
        for (var i = offset; i < num; i++) {
            var key = this.arrayMap.get(i);
            var obj = this.dataMap.get(key);
            result += "index: " + i + " key: " + key + " value: " + obj + "_";
        }
        return result;
    }
};

module.exports = SuperHomeWork;