package com.ffmpeg.web.controller;

import java.io.IOException;
import java.text.MessageFormat;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.annotation.JsonView;
import com.ffmpeg.web.jsonview.Views;
import com.ffmpeg.web.model.AjaxResponseBody;
import com.ffmpeg.web.model.FfmpegDetails;
import com.ffmpeg.web.model.FileAjaxResponse;
import com.ffmpeg.web.model.FileDetails;
import com.ffmpeg.web.service.FFmpegService;
import com.ffmpeg.web.utils.Constants;

@RestController
public class AjaxController {
	@Autowired
	FFmpegService fFmpegService;
	
	@JsonView(Views.Public.class)
	@RequestMapping(value = Constants.Url.CONVERT)
	public AjaxResponseBody convertFileViaAjax(@RequestBody FileDetails fileDetails) {

		AjaxResponseBody result = new AjaxResponseBody();
		try {
			fFmpegService.convertFile(fileDetails, result);
		} catch (IOException e) {
			result.setCode(Constants.Codes.ERROR);
			result.setMsg(MessageFormat.format(Constants.Messages.ERROR, fileDetails.getInputFile(), e.toString()));
		} catch (InterruptedException e) {
			result.setCode(Constants.Codes.ERROR);
			result.setMsg(MessageFormat.format(Constants.Messages.CONVERSION_ERROR, e.toString()));
		}

		return result;
	}
	
	@RequestMapping(value = Constants.Url.CANCEL)
	public AjaxResponseBody cancelConversionViaAjax(@RequestBody FileDetails fileDetails) {
		return fFmpegService.cancelConversion(fileDetails);
	}

	@RequestMapping(value = Constants.Url.GET_VIDEO)
	public FileAjaxResponse getVideoFiles(@RequestBody FfmpegDetails ffmpegDetails) {
		return fFmpegService.getVideoFiles(ffmpegDetails);
	}

}
