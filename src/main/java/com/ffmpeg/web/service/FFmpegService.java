package com.ffmpeg.web.service;

import java.io.File;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.List;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecuteResultHandler;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.ExecuteWatchdog;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import com.ffmpeg.web.controller.AjaxController;
import com.ffmpeg.web.model.AjaxResponseBody;
import com.ffmpeg.web.model.FfmpegDetails;
import com.ffmpeg.web.model.FileAjaxResponse;
import com.ffmpeg.web.model.FileDetails;
import com.ffmpeg.web.utils.Constants;
import com.ffmpeg.web.utils.VideoFileHelper;

@Component
public class FFmpegService {

	private Logger logger = LoggerFactory.getLogger(AjaxController.class);
	
	private DefaultExecutor executor;

	/**
	 * Generate and call an ffmpeg command in the form:
	 * ffmpeg -i c:\temp\t.mp4 -c:v libx264 -y -crf 20 -preset slow -c:a copy c:\temp\t.new.mp4 -nostats -loglevel 0
	 * 
	 * @param fileDetails
	 * @param result
	 * @throws IOException
	 * @throws InterruptedException
	 */
	public void convertFile(FileDetails fileDetails, AjaxResponseBody result) throws IOException, InterruptedException {
		String filePath      = VideoFileHelper.putSeparatorOnFilePath(fileDetails.getFilePath());
		String ffmpegPath    = VideoFileHelper.putSeparatorOnFilePath(fileDetails.getFfmpegPath());
		String ffmpegEncoder = fileDetails.getFfmpegEncoder();
		String ffmpegPreset  = fileDetails.getFfmpegPreset();
		int ffmpegCrf        = fileDetails.getFfmpegCrf();
		
		String ffmpegProgram = VideoFileHelper.isOsUnix() ? Constants.ProgramName.UNIX : Constants.ProgramName.WINDOWS;
		
		StringBuilder ffmpegCmd = new StringBuilder();
		ffmpegCmd.append(ffmpegPath)
 				 .append(ffmpegProgram)
				 .append(Constants.Ffmpeg.INPUT)
				 .append(filePath)
				 .append(fileDetails.getInputFile())
				 .append(Constants.Ffmpeg.FORMAT)
				 .append(ffmpegEncoder)
				 .append(Constants.Ffmpeg.OVERWRITE)
				 .append(Constants.Ffmpeg.CONVERSION_RATE)
				 .append(ffmpegCrf)
				 .append(Constants.Ffmpeg.PRESET)
				 .append(ffmpegPreset)
				 .append(Constants.Ffmpeg.OUTPUT)
				 .append(filePath)
				 .append(fileDetails.getOutputFile())
				 .append(Constants.Ffmpeg.LOGGING_OFF);
	
		DefaultExecuteResultHandler resultHandler = new DefaultExecuteResultHandler();
		logger.debug("ffmpeg command: " + ffmpegCmd.toString());
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
	
	public FileAjaxResponse getVideoFiles(FfmpegDetails ffmpegDetails) {
		FileAjaxResponse result = new FileAjaxResponse();
		String filePath = VideoFileHelper.putSeparatorOnFilePath(ffmpegDetails.getFilePath());
		File dirOutputFile = new File(filePath);
		if (dirOutputFile.exists() && dirOutputFile.isDirectory()) {
			if (VideoFileHelper.validFfmpegProgram(ffmpegDetails)) {
				List<String> videoFiles = VideoFileHelper.listVideoFiles(ffmpegDetails.getFilePath());
				result.setCode(Constants.Codes.SUCCESS);
				result.setFileName(videoFiles);
			} else {
				result.setCode(Constants.Codes.FFMPEG_ERROR);
				result.setMsg(MessageFormat.format(Constants.Messages.FFMPEG_DIR_ERROR, ffmpegDetails.getFfmpegPath()));
			}
		} else {
			result.setCode(Constants.Codes.ERROR);
			result.setMsg(MessageFormat.format(Constants.Messages.DIR_ERROR, ffmpegDetails.getFilePath()));
		}
		return result;
	}
	
	public AjaxResponseBody cancelConversion(FileDetails fileDetails) {
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
}
