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

// var HomeWorkKeyArray = function () {
//     LocalContractStorage.defineMapProperty(this, "repo", {
//         stringify: function (obj) {
//             return obj.toString();
//         },
//         parse: function (text) {
//             return new HomeWorkItem(text);
//         }
//     });
// };

var SuperHomeWork = function () {
    LocalContractStorage.defineMapProperty(this, "repo", {
        stringify: function (obj) {
            return obj.toString();
        },
        parse: function (text) {
            return new HomeWorkItem(text);
        }
    });

    LocalContractStorage.defineMapProperty(this, "repoArray", {
        stringify: function (obj) {
            // 存储时直接转为字符串
            return obj.toString();
        },
        parse: function (text) {
            // 读取时获得HomeWorkItem对象
            return new HomeWorkItem(text);
        }
    });

};

SuperHomeWork.prototype = {
    init: function () {
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

        // this.HomeWorkKeyArray.push(homeworkItem);
        // this.repo.HomeWorkKeyArray.push(homeworkItem);
        this.repoArray.push(key, homeworkItem);
    },

    get: function () {
        console.log("here get");

        // this.repo.HomeWorkKeyArray.sort(
        this.repoArray.sort(
            function(v1, v2){
                return v1.time-v2.time;
            });
        // return this.HomeWorkKeyArray.splice(0,4);
        return this.repoArray.splice(0,4);
    }
};

module.exports = SuperHomeWork;