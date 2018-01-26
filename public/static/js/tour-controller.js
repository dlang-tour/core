var dlangTourApp = angular.module('DlangTourApp', ['ui.codemirror', 'cfp.hotkeys']);

function b64DecodeUnicode(str) {
    // Going backwards: from bytestream, to percent-encoding, to original string.
    return decodeURIComponent(atob(str).split('').map(function(c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));
}

// Only enable HTML5 for the editor (for now)
if (location.origin.indexOf("run.dlang.io") >= 0 || location.pathname.startsWith("/editor")) {
	dlangTourApp.config(['$locationProvider', function($locationProvider) {
		$locationProvider.html5Mode({
			enabled: true,
			requireBase: false
		});
	}]);
}

dlangTourApp.controller('DlangTourAppCtrl',
	['$scope', '$http', 'hotkeys', '$window', '$location', '$sce',
	function($scope, $http, hotkeys, $window, $location, $sce) {
	$scope.programOutput = "";
	$scope.warnings = [];
	$scope.errors = [];
	$scope.showContent = true;
	$scope.showProgramOutput = false;
	$scope.editor = null;
	$scope.githubRepo = null;
	$scope.language = "en";
	$scope.chapterId = null;
	$scope.section = null;
	$scope.prevPage = null;
	$scope.nextPage = null;
	$scope.shortLinkURL = "";
	$scope.compiler = $location.search().compiler || "dmd";
	$scope.args = $location.search().args || "";
	$scope.inProgress = false;

	$scope.updateErrorsAndWarnings = function(doc, options, editor) {
		var hasErrors = $scope.errors.length > 0 || $scope.warnings > 0;
		if (hasErrors) {
			$scope.editor.setOption("gutters", ["CodeMirror-lint-markers"]);
		} else {
			$scope.editor.setOption("gutters", []);
		}
		$scope.editor.setOption("lint", {});
		var lintings = [];
		var process = function(arr, severity) {
			for (var i = 0; i < arr.length; ++i) {
				err = arr[i];
				lintings.push({
					message: err.message,
					from: CodeMirror.Pos(err.line - 1, 0),
					to: CodeMirror.Pos(err.line - 1, $scope.editor.getLine(err.line - 1).length),
					severity: severity
				});
			}
		}

		process($scope.errors, 'error');
		process($scope.warnings, 'warning');
		return lintings;
	}

	function storeState() {
		localStorage.setItem($scope.sourceCodeKey,
				$scope.editor.getDoc().getValue());
		localStorage.setItem($scope.sourceCodeKey + "_compiler", $scope.compiler);
		localStorage.setItem($scope.sourceCodeKey + "_args", $scope.args);
	}

	$scope.codemirrorLoaded = function(editor) {
		$scope.editor = editor;
		$scope.editor.on("change", storeState);
	}

	$scope.editorOptions = {
		lineWrapping : true,
		lineNumbers: true,
		indentUnit: 4,
		mode: 'text/x-d',
		theme: "elegant",
		viewportMargin: Infinity,
		extraKeys: {
			// hotkeys within code editor
			'Ctrl-Enter': function(cm) {
				$scope.$apply('run()');
			},
			'Ctrl-R': function(cm) {
				$scope.$apply('reset()');
			},
			'Alt-F': function(cm) {
				$scope.$apply('format()');
			}
		}
	};

	$scope.initTour = function(language, githubRepo, chapterId, section, hasSourceCode, prevPage, nextPage) {
		$scope.language = language;
		$scope.githubRepo = githubRepo;
		$scope.chapterId = chapterId;
		$scope.section = section;
		$scope.prevPage = prevPage;
		$scope.nextPage = nextPage;
		$http.get('/api/v1/source/' + language + "/" + chapterId + "/" + section)
			.success(function(data) {
				$scope.resetCode = data.sourceCode;
				$scope.sourceCodeKey = "sourcecode_" + language + "_" + chapterId + "_" + section;

				var sessionSC = localStorage.getItem($scope.sourceCodeKey)
				if (sessionSC) {
					$scope.sourceCode = sessionSC;
				} else {
					$scope.sourceCode = data.sourceCode;
				}
		});

		$scope.showSourceCode = hasSourceCode;
	}

	// https://stackoverflow.com/questions/7616461/generate-a-hash-from-string-in-javascript-jquery
	function hashCode(str) {
		var hash = 0, i, chr;
		if (str.length === 0) return hash;
		for (i = 0; i < str.length; i++) {
			chr   = str.charCodeAt(i);
			hash  = ((hash << 5) - hash) + chr;
			hash |= 0; // Convert to 32bit integer
	  }
	  return hash;
	}

	$scope.initEditor = function(sourceCode) {
		var loc = $location.search()
		var source = loc.source;
		if (!source) {
			source = b64DecodeUnicode(sourceCode);
			$scope.sourceCodeKey = window.location.hostname;
		} else {
			$scope.sourceCodeKey = "run_import_" + hashCode(source);
		}
		$scope.resetCode = source;
		var sessionSC = localStorage.getItem($scope.sourceCodeKey)
		if (sessionSC) {
			$scope.sourceCode = sessionSC;
		} else {
			$scope.sourceCode = $scope.resetCode;
		}
		if (typeof(loc.compiler) === "undefined") {
			$scope.compiler = localStorage.getItem($scope.sourceCodeKey + "_compiler") || $scope.compiler;
		}
		if (typeof(loc.args) === "undefined") {
			$scope.args = localStorage.getItem($scope.sourceCodeKey + "_args") || $scope.args;
		}
	}

	// we have at most two nanobars on the screen
	var nanobar = new Nanobar({target: document.getElementById('nanobar')});
	// currently nanobar2 is solely used as a workaround on the editor page
	var nanobar2 = document.getElementById('nanobar2');
	if (!!nanobar2) {
		nanobar2 = new Nanobar({target: nanobar2});
	}

	var ansi_up = new AnsiUp;
	ansi_up.use_classes = true;

	$scope.run = function(args) {
		args = args || $scope.args;
		$scope.programOutput = $sce.trustAsHtml("... Waiting for remote service ...");
		$scope.inProgress = true;
		var currentNanobarValue = 0;
		var progressInterval = setInterval(function(){
			currentNanobarValue = (currentNanobarValue + 1) % 100;
			nanobar.go(currentNanobarValue);
			if (nanobar2) {
				nanobar2.go(currentNanobarValue);
			}
		}, 100);

		$scope.showProgramOutput = true;
		$scope.useOutputIFrame = false;
		$scope.showContent = true;
		$scope.warnings = [];
		$scope.errors = [];
		// Don't lint now
		$scope.editor.setOption("lint", {});

		storeState();

		$http.post('/api/v1/run', {
			source: $scope.sourceCode,
			compiler: $scope.compiler,
			args: args,
			color: true
		}).then(function(body) {
			var data = body.data;
			var html = data.output;
			if (args.indexOf("-output-s") >=0 || args.indexOf("-output-ll") >= 0 ||
				args.indexOf("-asm") >= 0 || args.indexOf("-vcg-ast") >= 0) {
				html = hljs.highlightAuto(html).value;
			} else if (args.indexOf("-D") >= 0) {
				// removes padding on the left side
				html = html.replace("max-width: 980px;", "max-width: default;");
				$scope.useOutputIFrame = true;
			} else {
				html = ansi_up.ansi_to_html(html);
			}
			$scope.programOutput = $sce.trustAsHtml(html);
			$scope.warnings = data.warnings;
			$scope.errors = data.errors;
			// Enable linting
			$scope.editor.setOption("lint", {
				getAnnotations: $scope.updateErrorsAndWarnings
			});
		}, function(error) {
			var msg = (error || {}).statusMessage || "";
			$scope.programOutput = $sce.trustAsHtml("Server error: " + msg);
		}).finally(function(){
			clearInterval(progressInterval);
			$scope.inProgress = false;
		});
	}

	$scope.asm = function() {
		var args = $scope.args || "";
		if ($scope.compiler.indexOf("dmd") >=0 && args.indexOf("-asm") < 0) {
			args += " -asm";
		} else if ($scope.compiler.indexOf("ldc") >=0 && args.indexOf("-output-s") < 0) {
			args += " -output-s";
		} else {
			$scope.programOutput = $scope.compiler + " doesn't support ASM output";
		}
		$scope.run(args);
	}

	$scope.ir = function() {
		var args = $scope.args || "";
		if ($scope.compiler.indexOf("ldc") >=0 && args.indexOf("-output-ll") < 0) {
			args += " -output-ll";
		} else {
			$scope.programOutput = $scope.compiler + " doesn't support ASM output";
		}
		$scope.run(args);
	}

	$scope.ast = function() {
		var args = ($scope.args || "") + " -vcg-ast";
		$scope.run(args);
	}

	$scope.reset = function() {
		$scope.sourceCode = $scope.resetCode;
		$scope.compiler = "dmd";
		$scope.args = "";
		storeState();
	}

	function editorHost() {
		var url;
		// A local user might be offline, so we don't want to redirect him to the online editor
		if (location.hostname === "localhost" || location.hostname === "127.0.0.1" || location.hostname === "0.0.0.0")
			url = window.location.origin + "/editor";
		else
			url = "https://run.dlang.io";
		return url;
	}

	function editorParams() {
		var url = "?compiler=" + $scope.compiler;
		if ($scope.args && $scope.args.length > 0) {
			url += "&args=" + encodeURIComponent($scope.args);
		}
		return url;
	}

	$scope.export = function() {
		var encodedSource = encodeURIComponent($scope.sourceCode);
		window.location = editorHost() + editorParams() + "&source=" + encodedSource;
	}

	// boostrap copy-to-clipboard buttons (only necessary once)
	if (typeof(window.Clipboard) !== "undefined") {
		try {
			new window.Clipboard('.copy-btn', {
			text: function(trigger) {
				return $scope.shortLinkURL;
			}
		});
		} catch(e) {
			console.log("Creating the copy button failed due to: ", e);
		}
	}
	$scope.shorten = function() {
		$http.post('/api/v1/shorten', {
			source: $scope.sourceCode,
			compiler: $scope.compiler,
			args: $scope.args,
		}).then(function(body) {
			var data = body.data;
			$scope.shortLinkURL = data.url;
		}, function(error) {
			$scope.showContent = true;
			var msg = (error || {}).statusMessage || "";
			$scope.programOutput = "Server error: " + msg;
		});
	}

	function gistURLToId(url) {
		return url.replace("https://gist.github.com/", "").replace("anonymous/", "");
	}

	$scope.gist = function() {
		$http.post('https://api.github.com/gists', {
			public: true,
			files: {
				"main.d": {
					content: $scope.sourceCode
				}
			}
		}).then(function(body) {
			var data = body.data;
			window.open(data.html_url, "_blank");
			$scope.shortLinkURL = window.location.origin + "/gist/" + gistURLToId(data.html_url) + editorParams();
		}, function(error) {
			var msg = (error || {}).statusMessage || "";
			$scope.programOutput = "Server error: " + msg;
		});
	}

	$scope.importFromGist = function() {
		var url = prompt("Please enter Gist URL or id", "");
		if (!url) return;
		window.location.href = window.location.origin + "/gist/" + gistURLToId(url) + editorParams();
	}

	$scope.format = function() {
		$http.post('/api/v1/format', {
			source: $scope.sourceCode
		}).success(function(data) {
			$scope.sourceCode = data.source;
		});
	}

	function addLibrary(name, version) {
		// check for the header
		if (!($scope.sourceCode.indexOf("dub.sdl:") >= 0 || $scope.sourceCode.indexOf("dub.json:") >= 0)) {
			$scope.sourceCode = '/+dub.sdl:\n+/\n' + $scope.sourceCode;
		}
		var parts = $scope.sourceCode.split("+/");
		var after = parts.slice(1);
		after.unshift(parts[0] + 'dependency "' + name + '" version="~>' + version + '"\n');
		$scope.sourceCode = after.join("+/");
	}

	$scope.availableLibraries = [
		{name: "mir", version:"1.1.1"},
		{name: "mir-algorithm", version:"0.6.14"},
		{name: "vibe-d", version:"0.8.0"},
		{name: "libdparse", version:"0.7.0"}
	];
	$scope.showAvailableLibraries = false;
	$scope.availableLibrary = "none";
	var addLibrarySelect = document.getElementById("add-library-select");

	$scope.addLibrary = function() {
		$scope.showAvailableLibraries = true;
		addLibrarySelect.focus();
		addLibrarySelect.style.opacity = 1;
	}
	$scope.onAddLibrary = function() {
		if ($scope.availableLibrary !== "none") {
			var parts = $scope.availableLibrary.split(" ");
			addLibrary(parts[0], parts[1]);
		}
		addLibrarySelect.style.opacity = 0;
		$scope.availableLibrary = "none";
	}
	$scope.onBlurLibrary = function() {
		addLibrarySelect.style.opacity = 0;
	}

	// Add hotkeys
	hotkeys.add({
		combo: 'left',
		description: 'Go to previous section',
		callback: prevPage
	});
	hotkeys.add({
		combo: 'right',
		description: 'Go to next section',
		callback: nextPage
	});
	hotkeys.add({
		combo: 'ctrl+enter',
		description: 'Run source code',
		callback: function() {
			$scope.run();
		}
	});
	hotkeys.add({
		combo: 'ctrl+r',
		description: 'Reset source code',
		callback: function(e) {
			$scope.reset();
			e.preventDefault();
		}
	});
	hotkeys.add({
		combo: 'alt+f',
		description: 'Format source code',
		callback: function(e) {
			$scope.format();
			e.preventDefault();
		}
	});

	function prevPage()
	{
		if (!$scope.prevPage) {
			return;
		}
		window.location.href = $scope.prevPage;
	};

	function nextPage()
	{
		if (!$scope.nextPage) {
			return;
		}
		window.location.href = $scope.nextPage;
	}

	$scope.editOnGithub = function() {
		var url = 'https://github.com/' + $scope.githubRepo + '/edit/master/';
		url += $scope.chapterId + '/' + $scope.section + '.md';
		$window.open(url, '_blank');
	}
}]);

dlangTourApp.directive("preview", function () {
  function link(scope, element) {
    var iframe = document.createElement('iframe');
    var element0 = element[0];
    element0.appendChild(iframe);
    var doc = iframe.contentWindow.document;

    scope.$watch('content', function () {
      doc.body.innerHTML = "";
      doc.write(scope.content);
    });
  }

  return {
    link: link,
    restrict: 'E',
    scope: {
      content: '='
    }
  };
});

// use CodeMirror to highlight pre
function start() {
	[].forEach.call(document.querySelectorAll('code'), function(block) {
	    var val = block.textContent || "";
		CodeMirror.runMode(val, "text/x-d", block);
		block.className += "cm-s-elegant";
	});
}

document.addEventListener('DOMContentLoaded', start);
