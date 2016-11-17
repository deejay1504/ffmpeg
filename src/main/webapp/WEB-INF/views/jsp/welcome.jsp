<%@page session="false"%>
<%@taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Video File Converter</title>

<c:url var="home" value="/" scope="request" />

<spring:url value="/resources/core/css/hello.css" var="coreCss" />
<spring:url value="/resources/core/css/bootstrap.min.css"
	var="bootstrapCss" />
<link href="${bootstrapCss}" rel="stylesheet" />
<link href="${coreCss}" rel="stylesheet" />

<spring:url value="/resources/core/js/jquery.1.10.2.min.js"
	var="jqueryJs" />
<spring:url value="/resources/core/js/timer.jquery.min.js"
	var="jqueryTimerJs" />
<script src="${jqueryJs}"></script>
<script src="${jqueryTimerJs}"></script>
</head>

<nav class="navbar navbar-inverse">
	<div class="container">
		<div class="navbar-header">
			<a class="navbar-brand" href="#">Video File Converter</a>
		</div>
	</div>
</nav>

<div class="container" style="min-height: 500px">

	<div class="starter-template">
		<h1>Search Form</h1>
		<br>

		<div id="feedback"></div>

		<form class="form-horizontal" id="file-convert-form">
			<div class="form-group form-group-lg">
				<label class="col-sm-2 control-label">Input File</label>
				<div class="col-sm-10">
					<p onclick="jQuery('#file').trigger('click');"></p>
					<input type="file" id="inputFile" name="inputFile"/>
					<!-- <input type=text class="form-control" id="inputFile">  -->
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-2 control-label">Output File</label>
				<div class="col-sm-10">
					<input type="text" class="form-control" id="outputFile">
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-2 control-label">Processing Time</label>
				<div id="divTimer" class="col-sm-2">
					<input type="text" class="form-control" id="timer" name="timer" placeholder="0 sec">
				</div>
			</div>

			<div class="form-group">
				<div class="col-sm-offset-2 col-sm-10">
					<button type="submit" id="bth-search"
						class="btn btn-primary btn-lg">Convert</button>
				</div>
			</div>
		</form>

	</div>

</div>

<script>
	jQuery(document).ready(function($) {

		$("#file-convert-form").submit(function(event) {
			//<div id="divTimer" class="col-sm-2">
			//		<input type="text" class="form-control" id="timer" name="timer" placeholder="0 sec">
			//	</div>
			//$('#divTimer').get(0).type = 'text';
			//$("#divTimer").addClass("col-sm-2");
			//$("#divTimer").addClass("form-control");
			$("#divTimer").timer("remove");
			$("#divTimer").timer("start");

			// Disble the search button
			enableSearchButton(false);

			// Prevent the form from submitting via the browser.
			event.preventDefault();

			convertViaAjax();

		});
		
		$("#inputFile").change(function() {
			var inputFile = $("#inputFile").val();
			var fileParts = inputFile.split(".");
			$("#outputFile").val(fileParts[0] + ".new.mp4")
		});

	});

	function convertViaAjax() {

		var fileNames = {}
		fileNames["inputFile"] = $("#inputFile").val();
		fileNames["outputFile"] = $("#outputFile").val();

		$.ajax({
			type : "POST",
			contentType : "application/json",
			url : "${home}ffmpeg/api/convertFile",
			data : JSON.stringify(fileNames),
			dataType : 'json',
			timeout : 100000,
			success : function(data) {
				console.log("SUCCESS: ", data);
				display(data);
			},
			error : function(e) {
				console.log("ERROR: ", e);
				display(e);
			},
			done : function(e) {
				console.log("DONE");
				enableSearchButton(true);
			}
		});

	}
	
	function enableSearchButton(flag) {
		$("#btn-search").prop("disabled", flag);
	}

	function display(data) {
		var json = "<h4>Ajax Response</h4><pre>"
				+ JSON.stringify(data, null, 4) + "</pre>";
		$('#feedback').html(json);
		$("#divTimer").timer("pause");
	}
</script>

</body>
</html>