var Action = function() {
	
};

Action.prototype = {
run: function (args) {
	args.completionFunction({
		"URL": document.URL,
		"title": document.title
	});
},
finalize: function (args) {
	var customJs = args["customJavaScript"];
	eval(customJs)
}
};

var ExtensionPreprocessingJS = new Action();
