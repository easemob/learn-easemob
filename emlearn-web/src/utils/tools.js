export const getDatByPath = function(obj, path){
	var found = false;
	var propPath = path.split(".");
	r(propPath.shift());

	function r(prop){
		if(typeof prop != "string"){
			return;
		}
		if((typeof obj != "object") || (obj == null)){
			found = false;
			return;
		}
		found = prop in obj;
		if(found){
			obj = obj[prop];
			r(propPath.shift());
		}
	}
	return found ? obj : false;
};

export function getParams (name, hrefStr){
	if(!hrefStr){
		return;
	}
    let paramsArr;
    if(hrefStr){
        paramsArr = hrefStr.split('?')[1].split('&');
    }
    else{
        paramsArr = window.location.href.split('?')[1].split('&');
    }
	for (var i = 0; i < paramsArr.length; i++) {
		if (paramsArr[i].indexOf(name) != -1) {
			return paramsArr[i].split('=')[1]
		}
	}
}

export function getUserId(){
	var chars = 'abcdefghijklmnopqrstuvwxyz'.split('');
	var uuid = [];
	for (var i = 0; i < 5; i++) {
		uuid[i] = chars[parseInt(Math.random()*chars.length)]
	}

	return 'wb_'+uuid.join('') + new Date().getTime();
}