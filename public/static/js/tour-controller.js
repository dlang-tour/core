var dlangTourApp = angular.module('DlangTourApp', ['ui.codemirror']);

dlangTourApp.controller('DlangTourAppCtrl', [ '$scope', '$http', function($scope, $http) {
	$scope.programOutput = "";
	$scope.warnings = [];
	$scope.errors = [];
	$scope.showContent = true;
	$scope.showProgramOutput = false;
	$scope.editor = null;

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
	}

	$scope.editorOptions = {
		lineWrapping : true,
		lineNumbers: true,
		indentUnit: 4,
		mode: 'd',
		theme: "elegant",
		viewportMargin: Infinity,
		gutters: ["CodeMirror-lint-markers"]
	};

	$scope.init = function(chapterId, section, hasSourceCode) {
		$http.get('/api/v1/source/' + chapterId + "/" + section)
			.success(function(data) {
				$scope.sourceCode = $scope.resetCode = data.sourceCode;
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
}]);
