package com.ffmpeg.web.controller;

import java.io.File;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.List;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecuteResultHandler;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.ExecuteWatchdog;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.annotation.PropertySources;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.annotation.JsonView;
import com.ffmpeg.web.jsonview.Views;
import com.ffmpeg.web.model.AjaxResponseBody;
import com.ffmpeg.web.model.FileAjaxResponse;
import com.ffmpeg.web.model.FileDetails;
import com.ffmpeg.web.utils.Constants;
import com.ffmpeg.web.utils.ListVideoFiles;

@Configuration
@PropertySources({
	@PropertySource("classpath:ffmpeg.properties")
})

/**
 * Generate and call an ffmpeg command in the form:
 * 
 * ffmpeg -i c:\temp\t.mp4 -c:v libx264 -crf 20 -preset slow -c:a copy c:\temp\t.new.mp4 -nostats -loglevel 0
 *
 */
@RestController
public class AjaxController {
	@Autowired
	Environment env;
	
	private DefaultExecutor executor;

	// @ResponseBody, not necessary, since class is annotated with @RestController
	// @RequestBody - Convert the json data into object (FileDetails) mapped by field name.
	// @JsonView(Views.Public.class) - Optional, limited the json data display to client.
	@JsonView(Views.Public.class)
	@RequestMapping(value = "/ffmpeg/api/convertFile")
	public AjaxResponseBody convertFileViaAjax(@RequestBody FileDetails fileDetails) {

		AjaxResponseBody result = new AjaxResponseBody();
		try {
			convertFile(fileDetails, result);
		} catch (IOException e) {
			result.setCode(Constants.Codes.SUCCESS);
			result.setMsg(MessageFormat.format(Constants.Messages.ERROR, fileDetails.getInputFile(), e.toString()));
		} catch (InterruptedException e) {
			result.setCode(Constants.Codes.ERROR);
			result.setMsg(MessageFormat.format(Constants.Messages.CONVERSION_ERROR, e.toString()));
		}

		return result;
	}
	
	@RequestMapping(value = "/ffmpeg/api/getVideoFiles")
	public FileAjaxResponse getVideoFiles() {
		String filePath   = env.getProperty(Constants.Property.FILE_PATH);
		List<String> videoFiles = ListVideoFiles.listVideoFiles(filePath);
		FileAjaxResponse result = new FileAjaxResponse();
		result.setCode(Constants.Codes.SUCCESS);
		result.setFileName(videoFiles);
		return result;
	}

	@RequestMapping(value = "/ffmpeg/api/cancelConversion")
	public AjaxResponseBody cancelConversionViaAjax() {
		AjaxResponseBody result = new AjaxResponseBody();
		result.setCode(Constants.Codes.SUCCESS);
		if (executor == null) {
			result.setMsg(Constants.Messages.CANCEL_CONV);
		} else {
			executor.getWatchdog().destroyProcess();
			result.setMsg(Constants.Messages.CANCEL_SUCCESS);
		}
		return result;
	}
	
	private void convertFile(FileDetails fileDetails, AjaxResponseBody result) throws IOException, InterruptedException {
		String filePath      = env.getProperty(Constants.Property.FILE_PATH);
		String ffmpegPath    = env.getProperty(Constants.Property.PATH);
		String ffmpegEncoder = fileDetails.getFfmpegEncoder();
		String ffmpegPreset  = fileDetails.getFfmpegPreset();
		int ffmpegCrf        = fileDetails.getFfmpegCrf();
		
		File outputFile = new File(filePath + fileDetails.getOutputFile());
		if (outputFile.exists()) {
			outputFile.delete();
		}
		
		StringBuilder ffmpegCmd = new StringBuilder();
		ffmpegCmd.append(ffmpegPath)
				 .append(Constants.Ffmpeg.INPUT)
				 .append(filePath)
				 .append(fileDetails.getInputFile())
				 .append(Constants.Ffmpeg.FORMAT)
				 .append(ffmpegEncoder)
				 .append(Constants.Ffmpeg.CONVERSION_RATE)
				 .append(ffmpegCrf)
				 .append(Constants.Ffmpeg.PRESET)
				 .append(ffmpegPreset)
				 .append(Constants.Ffmpeg.OUTPUT)
				 .append(filePath)
				 .append(fileDetails.getOutputFile())
				 .append(Constants.Ffmpeg.LOGGING_OFF);
	
		DefaultExecuteResultHandler resultHandler = new DefaultExecuteResultHandler();
		System.out.println((ffmpegCmd.toString()));
		CommandLine commandLine = CommandLine.parse(ffmpegCmd.toString());
		executor = new DefaultExecutor();
		ExecuteWatchdog watchdog = new ExecuteWatchdog(ExecuteWatchdog.INFINITE_TIMEOUT);
		executor.setWatchdog(watchdog);
		executor.execute(commandLine, resultHandler);
		resultHandler.waitFor();
		int exitValue = resultHandler.getExitValue();
		if (exitValue == 0) {
			result.setCode(Constants.Codes.SUCCESS);
			result.setMsg(MessageFormat.format(Constants.Messages.SUCCESS, fileDetails.getInputFile()));
		} else if (exitValue == 1) {
			result.setCode(Constants.Codes.SUCCESS);
			result.setMsg(Constants.Messages.CANCEL_SUCCESS);
		} else {
			result.setCode(Constants.Codes.ERROR);
			result.setMsg(MessageFormat.format(Constants.Messages.ERROR, fileDetails.getInputFile(), resultHandler.getException().toString()));
		}
	}
	
}
