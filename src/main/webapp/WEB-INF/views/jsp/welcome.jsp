<%@page session="false"%>
<%@taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Video File Converter</title>

<c:url var="home" value="/" scope="request" />

<spring:url value="/resources/core/css/hello.css" var="coreCss" />
<spring:url value="/resources/core/css/bootstrap.min.css" var="bootstrapCss" />
<link href="${bootstrapCss}" rel="stylesheet" />
<link href="${coreCss}" rel="stylesheet" />

<spring:url value="/resources/core/js/jquery.1.10.2.min.js" var="jqueryJs" />
<spring:url value="/resources/core/js/timer.jquery.min.js" var="jqueryTimerJs" />
<script src="${jqueryJs}"></script>
<script src="${jqueryTimerJs}"></script>

<script>
	jQuery(document).ready(function($) {

		$("#btn-convert").click(function(event) {
			if ($("#inputFile").val() == '') {
				alert("Please select a valid file");
			} else {
				$("#feedback").hide();
				$("#timer").timer("remove");
				$("#timer").timer("start");
	
				// Disable the search button
				enableSearchButton(false);
	
				// Prevent the form from submitting via the browser.
				event.preventDefault();
	
				convertViaAjax();
			}
		});
		
		$("#btn-cancel").click(function(event) {
			$("#feedback").hide();
			$("#timer").timer("pause");

			// Prevent the form from submitting via the browser.
			event.preventDefault();

			cancelViaAjax();

		});
		
		$("#inputFile").change(function() {
			if ($("#inputFile").val().indexOf(' ') >= 0) {
				alert("Please don't use files with spaces");
			} else {
				var inputFile = $("#inputFile").val();
				var fileParts = inputFile.split(".");
				$("#outputFile").val(fileParts[0] + ".new.mp4")
			}
		});

	});

	function convertViaAjax() {

		var fileDetails = {}
		fileDetails["inputFile"]    = $("#inputFile").val();
		fileDetails["outputFile"]   = $("#outputFile").val();
		fileDetails["ffmpegPreset"] = $("#ffmpegPreset").val();
		fileDetails["ffmpegCrf"]    = $("#ffmpegCrf").val();

		$.ajax({
			type : "POST",
			contentType : "application/json",
			url : "${home}ffmpeg/api/convertFile",
			data : JSON.stringify(fileDetails),
			dataType : 'json',
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
	
	function cancelViaAjax() {
		$.ajax({
			type : "POST",
			contentType : "application/json",
			url : "${home}ffmpeg/api/cancelConversion",
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
		$("#btn-convert").prop("disabled", flag);
	}

	function display(data) {
		//var json = "<h4>Conversion details</h4><pre>"
		//		+ JSON.stringify(data, null, 4) + "</pre>";
		var json = "<h4>Conversion details</h4>"
			+ "<pre>Code: " + data.code 
			+ "<br/>Message: " + data.msg
			+ "</pre>";
		$('#feedback').html(json);
		$("#feedback").show();
		$("#timer").timer("pause");
	}
</script>
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
		<h2>File Conversion</h2>
		<br>

		<form class="form-horizontal" id="file-convert-form">
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Input File</label>
				<div class="col-sm-6">
					<input type="file" style="padding:0px;" class="form-control" id="inputFile" >
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Output File</label>
				<div class="col-sm-6">
					<input type="text" class="form-control" id="outputFile">
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Process Speed</label>
				<div class="col-sm-3">
					<select id="ffmpegPreset" class="form-control">
					    <option value="ultrafast">Ultra Fast</option>
					    <option value="superfast">Super Fast</option>
					    <option value="veryfast">Very Fast</option>
					    <option value="faster">Faster</option>
					    <option value="fast">Fast</option>
					    <option value="medium">Medium</option>
					    <option value="slow" selected="selected">Slow</option>
					    <option value="slower">Slower</option>
					    <option value="veryslow">Very Slow</option>
					</select>
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Conversion Rate</label>
				<div class="col-sm-3">
					<select id="ffmpegCrf" class="form-control">
					    <option value="18">18</option>
					    <option value="19">19</option>
					    <option value="20" selected="selected">20</option>
					    <option value="21">21</option>
					    <option value="22">22</option>
					    <option value="23">23</option>
					    <option value="24">24</option>
					    <option value="25">25</option>
					</select>
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Process Time </label>
				<div class="col-sm-3">
					<input type="text" class="form-control" id="timer" name="timer" placeholder="0 sec">
				</div>
			</div>

			<div class="form-group">
				<div class="col-sm-offset-2 col-sm-10">
					<button id="btn-convert" class="btn btn-primary btn-lg">Convert</button>
					<button id="btn-cancel" class="btn btn-primary btn-lg">Cancel</button>
				</div>
			</div>
		</form>
		
		<br>
		<div id="feedback"></div>

	</div>

</div>

</body>
</html>