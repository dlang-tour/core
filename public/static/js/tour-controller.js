var dlangTourApp = angular.module('DlangTourApp', ['ui.codemirror', 'cfp.hotkeys']);

function b64DecodeUnicode(str) {
    // Going backwards: from bytestream, to percent-encoding, to original string.
    return decodeURIComponent(atob(str).split('').map(function(c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));
}

dlangTourApp.config(['$locationProvider', function($locationProvider) {
	$locationProvider.html5Mode({
		enabled: true,
		requireBase: false
	});
}]);

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

	$scope.codemirrorLoaded = function(editor) {
		$scope.editor = editor;
		$scope.editor.on("change", function() {
			sessionStorage.setItem($scope.sourceCodeKey,
				 $scope.editor.getDoc().getValue());
		});
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

				var sessionSC = sessionStorage.getItem($scope.sourceCodeKey)
				if (sessionSC) {
					$scope.sourceCode = sessionSC;
				} else {
					$scope.sourceCode = data.sourceCode;
				}
		});

		$scope.showSourceCode = hasSourceCode;
	}

	$scope.initEditor = function(sourceCode) {

		var source = $location.search().source;
		if (!source) {
			source = b64DecodeUnicode(sourceCode);
		}
		$scope.resetCode = source;
		$scope.sourceCode = $scope.resetCode;
	}

	$scope.run = function() {
		$scope.programOutput = $sce.trustAsHtml("... Waiting for remote service ...");
		$scope.showProgramOutput = true;
		$scope.showContent = true;
		$scope.warnings = [];
		$scope.errors = [];
		// Don't lint now
		$scope.editor.setOption("lint", {});

		$http.post('/api/v1/run', {
			source: $scope.sourceCode,
			compiler: $scope.compiler,
			args: "-color"
		}).then(function(body) {
			var data = body.data;
			if (typeof AnsiUp !== "undefined") {
				var ansi_up = new AnsiUp;
				ansi_up.use_classes = true;
				$scope.programOutput = $sce.trustAsHtml(ansi_up.ansi_to_html(data.output));
			} else {
				$scope.programOutput = data.output;
			}
			$scope.warnings = data.warnings;
			$scope.errors = data.errors;
			// Enable linting
			$scope.editor.setOption("lint", {
				getAnnotations: $scope.updateErrorsAndWarnings
			});
		}, function(error) {
			var msg = (error || {}).statusMessage || "";
			$scope.programOutput = "Server error: " + msg;
		});
	}

	$scope.reset = function() {
		$scope.sourceCode = $scope.resetCode;
	}

	$scope.export = function() {
		var encodedSource = encodeURIComponent($scope.sourceCode);
		// A local user might be offline, so we don't want to redirect him to the online editor
		if (location.hostname === "localhost" || location.hostname === "127.0.0.1" || location.hostname === "0.0.0.0")
			window.location = window.location.origin + "/editor?source=" + encodedSource;
		else
			window.location = "https://run.dlang.io?compiler=" + $scope.compiler + "&source=" + encodedSource;
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
			compiler: $scope.compiler
		}).then(function(body) {
			var data = body.data;
			$scope.shortLinkURL = data.url;
		}, function(error) {
			$scope.showContent = true;
			var msg = (error || {}).statusMessage || "";
			$scope.programOutput = "Server error: " + msg;
		});
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
		}, function(error) {
			var msg = (error || {}).statusMessage || "";
			$scope.programOutput = "Server error: " + msg;
		});
	}

	$scope.format = function() {
		$http.post('/api/v1/format', {
			source: $scope.sourceCode
		}).success(function(data) {
			$scope.sourceCode = data.source;
		});
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

// use CodeMirror to highlight pre
function start() {
	[].forEach.call(document.querySelectorAll('code'), function(block) {
	    var val = block.textContent || "";
		CodeMirror.runMode(val, "text/x-d", block);
		block.className += "cm-s-elegant";
	});
}

document.addEventListener('DOMContentLoaded', start);
