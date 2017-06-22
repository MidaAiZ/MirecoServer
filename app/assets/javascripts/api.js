window.onload = function() {
    var apiHeader = getEleByClassName(document.getElementsByTagName("div"), "api-header");
    for (var i in apiHeader) {
        var ele = apiHeader[i]
        ele.onclick = function(e) {
            var apiBody = getEleByClassName(e.target.parentNode.children, "api-body")[0];
            apiBody.style.display = apiBody.style.display === "block" ? "none" : "block";
        }
    }
}

//传入节点和类名，遍历查找具有给类名的元素
function getEleByClassName(ele, className) {
    ele = ele || document;
    className = className || '*';
    var findarr = [];
    var pattern = new RegExp("(^|\\s)" + className + "(\\s|$)");
    for (var i = 0; i < ele.length; i++) {
        if (pattern.test(ele[i].className)) {
            findarr.push(ele[i]);
        }
    }
	return findarr;
}
