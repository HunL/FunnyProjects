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

var HomeWorkKeyArray = new Array();


var SuperHomeWork = function () {
    LocalContractStorage.defineMapProperty(this, "repo", {
        parse: function (text) {
            return new HomeWorkItem(text);
        },
        stringify: function (o) {
            return o.toString();
        }
    });
};

SuperHomeWork.prototype = {
    init: function () {
        // todo
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

        this.repo.put(key, homeworkItem);


        this.HomeWorkKeyArray.push(homeworkItem);
    },

    get: function () {
        this.HomeWorkKeyArray.sort(
            function(v1, v2){
                return v1.time-v2.time;
            });
        return this.HomeWorkKeyArray.splice(0,4);
    }
};
module.exports = SuperHomeWork;