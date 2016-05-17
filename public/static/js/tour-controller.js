var dlangTourApp = angular.module('DlangTourApp', ['ui.codemirror', 'cfp.hotkeys']);

dlangTourApp.controller('DlangTourAppCtrl', [ '$scope', '$http', 'hotkeys', function($scope, $http, hotkeys) {
	$scope.programOutput = "";
	$scope.warnings = [];
	$scope.errors = [];
	$scope.showContent = true;
	$scope.showProgramOutput = false;
	$scope.editor = null;
	$scope.chapterId = null;
	$scope.section = null;

	$scope.updateErrorsAndWarnings = function(doc, options, editor) {
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
		$scope.editor.setOption("lint", {});
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
		gutters: ["CodeMirror-lint-markers"],
		extraKeys: {
			// hotkeys within code editor
			'Ctrl-Enter': function(cm) {
				$scope.$apply('run()');
			},
			'Ctrl-R': function(cm) {
				$scope.$apply('reset()');
			}
		}
	};

	$scope.init = function(chapterId, section, hasSourceCode) {
		$scope.chapterId = chapterId;
		$scope.section = section;
		$http.get('/api/v1/source/' + chapterId + "/" + section)
			.success(function(data) {
				$scope.resetCode = data.sourceCode;
				$scope.sourceCodeKey = "sourcecode_" + chapterId + "_" + section;

				var sessionSC = sessionStorage.getItem($scope.sourceCodeKey)
				if (sessionSC) {
					$scope.sourceCode = sessionSC;
				} else {
					$scope.sourceCode = data.sourceCode;
				}
		});

		$scope.showSourceCode = hasSourceCode;
	}

	$scope.run = function() {
		$scope.programOutput = "... Waiting for remote service ...";
		$scope.showProgramOutput = true;
		$scope.showContent = true;
		$scope.warnings = [];
		$scope.errors = [];
		// Don't lint now
		$scope.editor.setOption("lint", {});

		$http.post('/api/v1/run', {
			source: $scope.sourceCode
		}).success(function(data) {
			$scope.programOutput = data.output;
			$scope.warnings = data.warnings;
			$scope.errors = data.errors;
			// Enable linting
			$scope.editor.setOption("lint", {
				getAnnotations: $scope.updateErrorsAndWarnings
			});
		});
	}

	$scope.reset = function() {
		$scope.sourceCode = $scope.resetCode;
	}

	// Add hotkeys
	hotkeys.add({
		combo: 'left',
		description: 'Go to previous section',
		callback: function() {
			$http.get('/previous-section/' + $scope.chapterId + '/' + $scope.section)
				.success(function(data) {
					window.location.href = data.location;
				});
		}
	});
	hotkeys.add({
		combo: 'right',
		description: 'Go to next section',
		callback: function() {
			$http.get('/next-section/' + $scope.chapterId + '/' + $scope.section)
				.success(function(data) {
					window.location.href = data.location;
				});
		}
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
}]);
