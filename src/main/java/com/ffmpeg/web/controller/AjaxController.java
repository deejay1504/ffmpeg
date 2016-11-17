package com.ffmpeg.web.controller;

import java.io.File;
import java.io.IOException;

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

@Configuration
@PropertySources({
	@PropertySource("classpath:ffmpeg.properties")
})


@RestController
public class AjaxController {
	@Autowired
	Environment env;

	// @ResponseBody, not necessary, since class is annotated with @RestController
	// @RequestBody - Convert the json data into object (SearchCriteria) mapped by field name.
	// @JsonView(Views.Public.class) - Optional, limited the json data display to client.
	@JsonView(Views.Public.class)
	@RequestMapping(value = "/ffmpeg/api/convertFile")
	public AjaxResponseBody getSearchResultViaAjax(@RequestBody FileDetails fileNames) {

		AjaxResponseBody result = new AjaxResponseBody();
		try {
			int processCode = convertFile(fileNames);
			result.setCode("200");
			result.setMsg(" Process code: " + processCode + ", successfully converted " + fileNames.getOutputFile());
		} catch (IOException e) {
			result.setCode("400");
			result.setMsg("Error processing " + fileNames.getInputFile() + " " + e.toString());
		} catch (InterruptedException e) {
			result.setCode("400");
			result.setMsg("Conversion error " + e.toString());
		}
		
		return result;

	}
	
	private int convertFile(FileDetails fileNames) throws IOException, InterruptedException {
		String filePath = env.getProperty("file.path");
		String ffmpegPath = env.getProperty("ffmpeg.path");
		String ffmpegFormat = env.getProperty("ffmpeg.format");
		String ffmpegPreset = env.getProperty("ffmpeg.preset");
		int ffmpegCrf = Integer.valueOf(env.getProperty("ffmpeg.crf"));
		
		File outputFile = new File(filePath + fileNames.getOutputFile());
		if (outputFile.exists()) {
			outputFile.delete();
		}
		
		StringBuilder ffmpegCmd = new StringBuilder();
		ffmpegCmd.append(ffmpegPath)
				 .append(" -i ")
				 .append(filePath)
				 .append(fileNames.getInputFile())
				 .append(" -c:v ")
				 .append(ffmpegFormat)
				 .append(" -crf ")
				 .append(ffmpegCrf)
				 .append(" -preset ")
				 .append(ffmpegPreset)
				 .append(" -c:a copy ")
				 .append(filePath)
				 .append(fileNames.getOutputFile());

		Process p = Runtime.getRuntime().exec(ffmpegCmd.toString());
		p.waitFor();
		return p.exitValue();

	}
	
}
