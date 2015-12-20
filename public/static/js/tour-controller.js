var dlangTourApp = angular.module('DlangTourApp', ['ui.codemirror']);

dlangTourApp.controller('DlangTourAppCtrl', [ '$scope', '$http', function($scope, $http) {
	$scope.editorOptions = {
		lineWrapping : true,
		lineNumbers: true,
		indentUnit: 4,
		mode: 'd',
		theme: "elegant"
	};

	$scope.programOutput = "";

	$scope.run = function() {
		$scope.programOutput = "... Waiting for remote service ...";
		$http.post('/api/v1/run', {
			source: $scope.sourceCode
		}).success(function(data) {
			$scope.programOutput = data.output;
		});
	}

	$scope.reset = function() {
		$scope.sourceCode = $scope.resetCode;
	}
}]);
