var options = {
	"debug":"true",//true、false
}
var _result = function(data){
	alert(JSON.stringify(data));
}
//开始下载...
window.plugins.download.start(downloadUrl,targetPath,options,_result);
//暂停下载...
window.plugins.download.pause(downloadUrl,options,_result);
//终止下载...
window.plugins.download.abort(downloadUrl,options,_result);
//下载进度...
window.plugins.download.progress(downloadUrl,options,_result);
