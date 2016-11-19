package com.ffmpeg.web.controller;

import java.io.File;
import java.io.IOException;

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
import com.ffmpeg.web.model.FileDetails;
import com.ffmpeg.web.utils.Constants;

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
	public AjaxResponseBody convertFileViaAjax(@RequestBody FileDetails fileNames) {

		AjaxResponseBody result = new AjaxResponseBody();
		try {
			convertFile(fileNames);
			result.setCode("200");
			result.setMsg(" Successfully converted " + fileNames.getOutputFile());
		} catch (IOException e) {
			result.setCode("400");
			result.setMsg("Error processing " + fileNames.getInputFile() + " " + e.toString());
		} catch (InterruptedException e) {
			result.setCode("400");
			result.setMsg("Conversion error " + e.toString());
		}

		return result;
	}
	
	@RequestMapping(value = "/ffmpeg/api/cancelConversion")
	public AjaxResponseBody cancelConversionViaAjax() {
		AjaxResponseBody result = new AjaxResponseBody();
		result.setCode("200");
		if (executor == null) {
			result.setMsg("Conversion process is not running");
		} else {
			executor.getWatchdog().destroyProcess();
			result.setMsg(" Successfully cancelled process");
		}
		return result;
	}
	
	private void convertFile(FileDetails fileDetails) throws IOException, InterruptedException {
		String filePath = env.getProperty(Constants.Property.FILE_PATH);
		String ffmpegPath = env.getProperty(Constants.Property.PATH);
		String ffmpegFormat = env.getProperty(Constants.Property.FORMAT);
		String ffmpegPreset = fileDetails.getFfmpegPreset();
		int ffmpegCrf = fileDetails.getFfmpegCrf();
		
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
				 .append(ffmpegFormat)
				 .append(Constants.Ffmpeg.CONVERSION_RATE)
				 .append(ffmpegCrf)
				 .append(Constants.Ffmpeg.PRESET)
				 .append(ffmpegPreset)
				 .append(Constants.Ffmpeg.OUTPUT)
				 .append(filePath)
				 .append(fileDetails.getOutputFile())
				 .append(Constants.Ffmpeg.LOGGING_OFF);
	
		System.out.println(ffmpegCmd.toString());
		DefaultExecuteResultHandler resultHandler = new DefaultExecuteResultHandler();
		CommandLine commandLine = CommandLine.parse(ffmpegCmd.toString());
		executor = new DefaultExecutor();
		ExecuteWatchdog watchdog = new ExecuteWatchdog(ExecuteWatchdog.INFINITE_TIMEOUT);
		executor.setWatchdog(watchdog);
		executor.execute(commandLine, resultHandler);
		resultHandler.waitFor();
	}
	
}
