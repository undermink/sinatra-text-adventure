console.log("init");
$(function() {
	console.log("ready");
	$("a.post").click(function(e) {
		var el = e.currentTarget;
		$.post($(el).attr("href"), function() {
			location.reload();
		});
		return false;
	});
	$("a.back").click(function(){
		console.log("CLICK");
		history.go(-1);
		return false;
	});
	$("a.back").attr("href","#");
}); 

