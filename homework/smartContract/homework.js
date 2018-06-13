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
        stringify: function (obj) {
            return obj.toString();
        },
        parse: function (text) {
            return new HomeWorkItem(text);
        }
    });

    LocalContractStorage.defineMapProperty(this, "arrayMap");
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
        this.size += 1;
    },

    get: function (key) {
        return this.dataMap.get(key);
    },

    len: function () {
        return this.size;
    },

    fiveData: function (offset) {
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