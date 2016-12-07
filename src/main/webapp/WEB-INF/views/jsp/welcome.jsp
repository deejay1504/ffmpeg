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

<script type="text/javascript">
	jQuery(document).ready(function($) {
		$("#date-today").text((new Date()).toString().split(' ').splice(0,4).join(' '));
		
		$("#file-path").val(localStorage.filePath);
		$("#ffmpeg-path").val(localStorage.ffmpegPath);
		
		if ($("#file-path").val() != '') {
			getVideoFiles();
		}
		
		$("#accordian-button").click(function(e) {
		  that = $(this)
		  accordian = that.siblings('#accordian-body')
		  $("#accordian-body").not(accordian).collapse('hide')
		  accordian.collapse('toggle')
		});
		
		$("a.tool-tip-link").tooltip({placement : 'right'});
		
		$("#btn-save").click(function(event) {
			// Prevent the form from submitting via the browser.
			event.preventDefault();

			if ($("#ffmpeg-path").val() == '') {
				showAlert('Please select a valid ffmpeg directory', 'W', '');
			} else if ($("#file-path").val() == '') {
				showAlert('Please select a valid output directory for the videos', 'W', '');
			} else {
				convertButtonDisabled(true);
				localStorage.filePath   = $("#file-path").val();
				localStorage.ffmpegPath = $("#ffmpeg-path").val();
				showAlert('Saved admin details successfully', 'S', 'Saved!');
				getVideoFiles();
				convertButtonDisabled(false);
			}
		});
		
		$("#btn-convert").click(function(event) {
			// Prevent the form from submitting via the browser.
			event.preventDefault();

			if ($("#input-file").val() == '') {
				showAlert('Please select a valid file to start the conversion process', 'W', '');
			} else {
				var inputFile  = $("#input-file").val();
				var outputFile = $("#output-file").val();
				if (inputFile == outputFile) {
					showAlert(' Please enter a different name to the input file', 'W', '');
				} else {
					$("#timer").timer("remove");
					$("#timer").timer("start");
		
					convertButtonDisabled(true);
					saveButtonDisabled(true);
					convertViaAjax();
				}
			}
		});
		
		$("#btn-cancel").click(function(event) {
			// Prevent the form from submitting via the browser.
			event.preventDefault();

			if ($("#input-file").val() == '') {
				event.preventDefault();
				showAlert('Cannot cancel process, file conversion is not running', 'W', '');
			} else {
				$("#timer").timer("pause");
	
				cancelViaAjax();
			}
		});
		
		$("#input-file").change(function() {
			var inputFile = $("#input-file").val();
			if (inputFile.indexOf(' ') !== -1) {
				showAlert(inputFile + ' was selected. Please select a file without spaces in the name', 'W', '');
				$("#input-file").val('');
			} else {
				var fileParts = inputFile.split(".");
				$("#output-file").val(fileParts[0] + ".new.mp4")
			}
		});

		$('.alert .close').on('click', function(e) {
		    $(this).parent().hide();
		});

	});
	
	function getVideoFiles() {
		var ffmpegDetails = {}
		ffmpegDetails["ffmpegPath"] = $("#ffmpeg-path").val();
		ffmpegDetails["filePath"]   = $("#file-path").val();
		ajaxPostFileDetails('${home}ffmpeg/api/getVideoFiles', ffmpegDetails);
	}
	
	function convertViaAjax() {
		var fileDetails = {}
		fileDetails["ffmpegPath"]    = $("#ffmpeg-path").val();
		fileDetails["filePath"]      = $("#file-path").val();
		fileDetails["inputFile"]     = $("#input-file").val();
		fileDetails["outputFile"]    = $("#output-file").val();
		fileDetails["ffmpegEncoder"] = $("#ffmpeg-encoder").val();
		fileDetails["ffmpegPreset"]  = $("#ffmpeg-preset").val();
		fileDetails["ffmpegCrf"]     = $("#ffmpeg-crf").val();

		ajaxPost('${home}ffmpeg/api/convertFile', fileDetails);
	}
	
	function cancelViaAjax() {
		var fileDetails = {}
		fileDetails["filePath"]      = $("#file-path").val();
		fileDetails["outputFile"] = $("#output-file").val();
		
		ajaxPost('${home}ffmpeg/api/cancelConversion', fileDetails);
	}
	
	function ajaxPostFileDetails(restUrl, ffmpegDetails) {
		$.ajax({
			type : "POST",
			contentType : "application/json",
			url : restUrl,
			data : JSON.stringify(ffmpegDetails),
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
				convertButtonDisabled(false);
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
				convertButtonDisabled(false);
				saveButtonDisabled(false);
			},
			error : function(e) {
				console.log("ERROR: ", e);
				displayAlert(e);
			},
			done : function(e) {
				console.log("DONE");
				convertButtonDisabled(false);
			}
		});
	}
	
	function convertButtonDisabled(flag) {
		$("#btn-convert").prop("disabled", flag);
	}

	function saveButtonDisabled(flag) {
		$("#btn-save").prop("disabled", flag);
	}
	
	function setFileCount(data) {
		if (data.code == '400') {
			showAlert('The \'ffmpeg\' program is not located in the ' + $("#ffmpeg-path").val() + ' directory. Please select another.', 'E', '');
		} else {
			$("#file-count").text(data.fileName.length);
			$('#input-file').html('');
	 		$('#input-file').append('<option id=blank></option>');
	 		
	      	$.each(data.fileName, function(key, val){ 
	        	$('#input-file').append('<option id="' + val + '">' + val + '</option>');
	      	})
		}
	}

	function showAlert(alertMsg, msgType, headerMsg) {
		$(".modal-header").removeClass('red-background');
		$(".modal-header").removeClass('yellow-background');
		$(".modal-header").removeClass('light-blue-background');
		if (msgType == 'E') {
			$(".modal-header").addClass('red-background');
			$(".modal-title").text('Error!');
		} else if (msgType == 'W') {
			$(".modal-header").addClass('yellow-background');
			$(".modal-title").text('Warning!');
		} else {
			$(".modal-header").addClass('light-blue-background');
			$(".modal-title").text(headerMsg);
		}
		$("#alert-modal-msg").text(alertMsg);
		$('#alert-modal').modal('show');
	}

	function displayAlert(data) {
		$("#timer").timer("pause");
		var msgType;
		var msgHeader = '';
		if (data.code == '200') {
			msgType = 'S';
			msgHeader = 'Finished!'
		} else {
			msgType = 'E';
		}
		showAlert(data.msg, msgType, msgHeader);
	}
</script>
</head>

<nav class="navbar navbar-inverse">
	<div class="container">
		<div class="navbar-header">
			<label class="col-md-offset-20 navbar-brand" style="margin-right:550px;">Video File Converter</label>
			<label id="date-today" class="navbar-brand"></label>
		</div>
	</div>
</nav>

<div class="container" style="min-height: 500px">

	<div class="starter-template">
		<br><br><br>

	    <div id="alert-modal" class="modal fade">
		    <div class="modal-dialog">
		        <div class="modal-content">
		            <div class="modal-header">
		                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		                <h4 class="modal-title">Warning!</h4>
		            </div>
		            <div class="modal-body">
		                <label id="alert-modal-msg" ></label>
		            </div>
		            <div class="modal-footer">
		                <button id="modal-close-button" type="button" class="btn btn-default" data-dismiss="modal">Close</button>
		            </div>
		        </div>
		    </div>
		</div>
		
		<form class="form-horizontal" id="file-convert-form">
		
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label"><span id="file-count" class="badge badge-colour"></span> Video Files 
					<span class="glyphicon glyphicon-folder-open"></span>
				</label>
				<div class="col-sm-6">
					<select id="input-file" class="form-control"></select>
				</div>
				<div>
					<a data-toggle="tooltip" class="tool-tip-link" data-original-title="Select a video file for conversion">
					  <span class="glyphicon glyphicon-info-sign"></span>
					</a>
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Output File <span class="glyphicon glyphicon-folder-open"></span></label>
				<div class="col-sm-6">
					<input id="output-file" type="text" class="form-control">
				</div>
				<div>
					<a data-toggle="tooltip" class="tool-tip-link" data-original-title="This will be the name of the converted file">
					  <span class="glyphicon glyphicon-info-sign"></span>
					</a>
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Encoder <span class="glyphicon glyphicon-facetime-video"></span></label>
				<div class="col-sm-3">
					<select id="ffmpeg-encoder" class="form-control">
					    <option value="libx264" selected="selected">AVC</option>
					    <option value="libx265">HEVC</option>
					</select>
				</div>
				<div>
					<a data-toggle="tooltip" class="tool-tip-link" data-html="true"
					   data-original-title="HEVC - High Efficiency Video Coding (newer version)<br>HEVC - slower but creates smaller files<br>AVC - Advanced Video Coding (older version)<br>AVC - quicker but creates bigger files">
					  <span class="glyphicon glyphicon-info-sign"></span>
					</a>
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Process Speed <span class="glyphicon glyphicon-flash"></span></label>
				<div class="col-sm-3">
					<select id="ffmpeg-preset" class="form-control">
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
					<a data-toggle="tooltip" class="tool-tip-link" data-original-title="A faster speed will create a bigger file">
					  <span class="glyphicon glyphicon-info-sign"></span>
					</a>
				</div>
			</div>
			
			<div class="form-group form-group-lg">
				<label class="col-sm-3 control-label">Conversion Rate <span class="glyphicon glyphicon-dashboard"></span></label>
				<div class="col-sm-3">
					<select id="ffmpeg-crf" class="form-control">
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
					<a data-toggle="tooltip" class="tool-tip-link" data-html="true"
					   data-original-title="A lower conversion rate factor will take longer<br>but will create a file with a better resolution">
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
		
			<div class="adminPanel">
	    		<div class="panel-group" id="accordion">
	        		<div class="panel panel-default">
			            <div id="accordian-button" class="panel-heading">
			                <h4 class="panel-title">
			                    <a data-toggle="collapse" data-parent="#accordion" href="#accordian-body">Admin</a>
			                </h4>
			            </div>
			            <div id="accordian-body" class="panel-collapse collapse">
			                <div class="form-group form-group-lg">
			                	<br>
								<label class="col-sm-3 control-label">Ffmpeg path
									<span class="glyphicon glyphicon-folder-open"></span>
								</label>
								<div class="col-sm-6">
									<input id="ffmpeg-path" type="text" class="form-control">
								</div>
								<div>
									<a data-toggle="tooltip" class="tool-tip-link" data-original-title="Directory where ffmpeg is installed">
									  <span class="glyphicon glyphicon-info-sign"></span>
									</a>
								</div>
							</div>
			                <div class="form-group form-group-lg">
								<label class="col-sm-3 control-label">Output file path
									<span class="glyphicon glyphicon-folder-open"></span>
								</label>
								<div class="col-sm-6">
									<input id="file-path" type="text" class="form-control">
								</div>
								<div>
									<a data-toggle="tooltip" class="tool-tip-link" data-html="true"
									   data-original-title="Directory where converted<br>video files will be output">
									  <span class="glyphicon glyphicon-info-sign"></span>
									</a>
								</div>
							</div>
				            <div class="form-group">
								<div class="col-sm-offset-3 col-sm-10">
									<button id="btn-save" class="btn btn-primary btn-lg">Save</button>
								</div>
							</div>
			            </div>
		            </div>
	            </div>
	        </div>
		</form>
		
	</div>

</div>
</body>
</html>