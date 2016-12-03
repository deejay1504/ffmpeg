<%@page session="false"%>
<%@taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Video File Converter</title>

<c:url var="home" value="/" scope="request" />

<spring:url value="/resources/core/css/bootstrap.min.css" var="bootstrapCss" />
<spring:url value="/resources/core/css/ffmpeg.css" var="ffmpegCss" />

<link href="${bootstrapCss}" rel="stylesheet" />
<link href="${ffmpegCss}" rel="stylesheet" />

<spring:url value="/resources/core/js/jquery.1.10.2.min.js" var="jqueryJs" />
<spring:url value="/resources/core/js/bootstrap.min.js" var="bootstrapJs" />
<spring:url value="/resources/core/js/timer.jquery.min.js" var="jqueryTimerJs" />

<script src="${jqueryJs}"></script>
<script src="${bootstrapJs}"></script>
<script src="${jqueryTimerJs}"></script>

<script>
	jQuery(document).ready(function($) {
		$("#dateToday").text((new Date()).toString().split(' ').splice(0,4).join(' '));
		
		ajaxGet('${home}ffmpeg/api/getVideoFiles');
		
		$("a.tooltipLink").tooltip({placement : 'right'});
		
		$("#btn-convert").click(function(event) {
			// Prevent the form from submitting via the browser.
			event.preventDefault();

			if ($("#inputFile").val() == '') {
				showAlert('Please select a valid file to start the conversion process', 'W');
			} else {
				var inputFile  = $("#inputFile").val();
				var outputFile = $("#outputFile").val();
				if (inputFile == outputFile) {
					showAlert(' Please enter a different name to the input file', 'W');
				} else {
					$("#timer").timer("remove");
					$("#timer").timer("start");
		
					// Disable the search button
					enableSearchButton(false);
		
					convertViaAjax();
				}
			}
		});
		
		$("#btn-cancel").click(function(event) {
			// Prevent the form from submitting via the browser.
			event.preventDefault();

			if ($("#inputFile").val() == '') {
				event.preventDefault();
				showAlert('Cannot cancel process, file conversion is not running', 'W');
			} else {
				$("#timer").timer("pause");
	
				cancelViaAjax();
			}
		});
		
		$("#inputFile").change(function() {
			var inputFile = $("#inputFile").val();
			if (inputFile.indexOf(' ') !== -1) {
				showAlert(inputFile + ' was selected. Please select a file without spaces in the name', 'W');
				$("#inputFile").val('');
			} else {
				var fileParts = inputFile.split(".");
				$("#outputFile").val(fileParts[0] + ".new.mp4")
			}
		});

		$('.alert .close').on('click', function(e) {
		    $(this).parent().hide();
		});

	});
	
	function convertViaAjax() {
		var fileDetails = {}
		fileDetails["inputFile"]     = $("#inputFile").val();
		fileDetails["outputFile"]    = $("#outputFile").val();
		fileDetails["ffmpegEncoder"] = $("#ffmpegEncoder").val();
		fileDetails["ffmpegPreset"]  = $("#ffmpegPreset").val();
		fileDetails["ffmpegCrf"]     = $("#ffmpegCrf").val();

		ajaxPost('${home}ffmpeg/api/convertFile', fileDetails);
	}
	
	function cancelViaAjax() {
		var fileDetails = {}
		fileDetails["inputFile"]  = $("#inputFile").val();
		fileDetails["outputFile"] = $("#outputFile").val();
		
		ajaxPost('${home}ffmpeg/api/cancelConversion', fileDetails);
	}
	
	function ajaxGet(restUrl) {
		$.ajax({
			type : "POST",
			contentType : "application/json",
			url : restUrl,
			dataType : 'json',
			success : function(data) {
				console.log("SUCCESS: ", data);
				setFileCount(data);
			},
			error : function(e) {
				console.log("ERROR: ", e);
				displayAlert(e);
			},
			done : function(e) {
				console.log("DONE");
				enableSearchButton(true);
			}
		});
	}
	
	function ajaxPost(restUrl, fileDetails) {
		$.ajax({
			type : "POST",
			contentType : "application/json",
			url : restUrl,
			data : JSON.stringify(fileDetails),
			dataType : 'json',
			success : function(data) {
				console.log("SUCCESS: ", data);
				displayAlert(data);
			},
			error : function(e) {
				console.log("ERROR: ", e);
				displayAlert(e);
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
	
	function setFileCount(data) {
		$("#fileCount").text(data.fileName.length);
		$('#inputFile').html('');
 		$('#inputFile').append('<option id=blank></option>');
 		
      	$.each(data.fileName, function(key, val){ 
        	$('#inputFile').append('<option id="' + val + '">' + val + '</option>');
      	})
	}

	function showAlert(alertMsg, msgType) {
		$(".modal-header").removeClass('red-background');
		$(".modal-header").removeClass('yellow-background');
		$(".modal-header").removeClass('light-blue-background');
		if (msgType == 'E') {
			$(".modal-header").addClass('red-background');
			$(".modal-title").text('Error!')
		} else if (msgType == 'W') {
			$(".modal-header").addClass('yellow-background');
			$(".modal-title").text('Warning!')
		} else {
			$(".modal-header").addClass('light-blue-background');
			$(".modal-title").text('Finished!')
		}
		$("#alertModalMsg").text(alertMsg);
		$('#alertModal').modal('show');
	}

	function displayAlert(data) {
		$("#timer").timer("pause");
		var msgType;
		if (data.code == '200') {
			msgType = 'S';
		} else {
			msgType = 'E';
		}
		showAlert(data.msg, msgType);
	}
</script>
</head>

<nav class="navbar navbar-inverse">
	<div class="container">
		<div class="navbar-header">
			<label class="col-md-offset-20 navbar-brand" style="margin-right:550px;">Video File Converter</label>
			<label id="dateToday" class="navbar-brand"></label>
		</div>
	</div>
</nav>

<div class="container" style="min-height: 500px">

	<div class="starter-template">
		<br><br><br>

	    <div id="alertModal" class="modal fade">
		    <div class="modal-dialog">
		        <div class="modal-content">
		            <div class="modal-header">
		                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		                <h4 class="modal-title">Warning!</h4>
		            </div>
		            <div class="modal-body">
		                <label id="alertModalMsg" ></label>
		            </div>
		            <div class="modal-footer">
		                <button id="modalCloseButton" type="button" class="btn btn-default" data-dismiss="modal">Close</button>
		            </div>
		        </div>
		    </div>
		</div>
		
		<form class="form-horizontal" id="file-convert-form">
			<!-- <div class="form-group form-group-lg">
				<label class="col-sm-3 control-label"><span id="fileCount" class="badge"></span> Video Files 
					<span class="glyphicon glyphicon-folder-open"></span>
				</label>
				<div class="col-sm-6">
					<input type="file" style="padding:0px;" class="form-control" id="inputFile">
				</div>
				<div>
					<a data-toggle="tooltip" class="tooltipLink" data-original-title="Select a video file for conversion">
					  <span class="glyphicon glyphicon-info-sign"></span>
					</a>
				</div>
			</div>
			-->
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label"><span id="fileCount" class="badge"></span> Video Files 
					<span class="glyphicon glyphicon-folder-open"></span>
				</label>
				<div class="col-sm-6">
					<select id="inputFile" class="form-control"></select>
				</div>
				<div>
					<a data-toggle="tooltip" class="tooltipLink" data-original-title="Select a video file for conversion">
					  <span class="glyphicon glyphicon-info-sign"></span>
					</a>
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Output File <span class="glyphicon glyphicon-folder-open"></span></label>
				<div class="col-sm-6">
					<input type="text" class="form-control" id="outputFile">
				</div>
				<div>
					<a data-toggle="tooltip" class="tooltipLink" data-original-title="This will be the name of the converted file">
					  <span class="glyphicon glyphicon-info-sign"></span>
					</a>
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Encoder <span class="glyphicon glyphicon-facetime-video"></span></label>
				<div class="col-sm-3">
					<select id="ffmpegEncoder" class="form-control">
					    <option value="libx265" selected="selected">HEVC</option>
					    <option value="libx264">AVC</option>
					</select>
				</div>
				<div>
					<a data-toggle="tooltip" class="tooltipLink" data-html="true" 
					   data-original-title="HEVC - High Efficiency Video Coding (newer version)<br>HEVC - slower but creates smaller files<br>AVC - Advanced Video Coding (older version)<br>AVC - quicker but creates bigger files">
					  <span class="glyphicon glyphicon-info-sign"></span>
					</a>
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Process Speed <span class="glyphicon glyphicon-flash"></span></label>
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
				<div>
					<a data-toggle="tooltip" class="tooltipLink" data-original-title="A faster speed will create a bigger file">
					  <span class="glyphicon glyphicon-info-sign"></span>
					</a>
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Conversion Rate <span class="glyphicon glyphicon-dashboard"></span></label>
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
				<div>
					<a data-toggle="tooltip" class="tooltipLink" data-original-title="A lower conversion rate factor will take longer but create a better file resolution">
					  <span class="glyphicon glyphicon-info-sign"></span>
					</a>
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Process Time <span class="glyphicon glyphicon-time"></span></label>
				<div class="col-sm-3">
					<input type="text" class="form-control" id="timer" name="timer" placeholder="0 sec">
				</div>
			</div>

			<div class="form-group">
				<div class="col-sm-offset-3 col-sm-10">
					<button id="btn-convert" class="btn btn-primary btn-lg">Convert</button>
					<button id="btn-cancel" class="btn btn-primary btn-lg">Cancel</button>
				</div>
			</div>
		</form>
		
	</div>

</div>

</body>
</html>