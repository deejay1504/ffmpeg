package com.ffmpeg.web.model;

public class FileDetails extends FfmpegDetails {
	private String inputFile;

	private String outputFile;
	
	private String ffmpegEncoder;

	private String ffmpegPreset;
	
	private int ffmpegCrf;

	public String getInputFile() {
		return inputFile;
	}

	public void setInputFile(String inputFile) {
		this.inputFile = inputFile;
	}

	public String getOutputFile() {
		return outputFile;
	}

	public void setOutputFile(String outputFile) {
		this.outputFile = outputFile;
	}

	public String getFfmpegPreset() {
		return ffmpegPreset;
	}
	
	public void setFfmpegPreset(String ffmpegPreset) {
		this.ffmpegPreset = ffmpegPreset;
	}

	public int getFfmpegCrf() {
		return ffmpegCrf;
	}
	
	public void setFfmpegCrf(int ffmpegCrf) {
		this.ffmpegCrf = ffmpegCrf;
	}

	public String getFfmpegEncoder() {
		return ffmpegEncoder;
	}
	
	public void setFfmpegEncoder(String ffmpegEncoder) {
		this.ffmpegEncoder = ffmpegEncoder;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("FileDetails [filePath = ")
		  .append(filePath)
		  .append(", ffmpegPath = ")
		  .append(ffmpegPath)
		  .append(", inputFile = ")
		  .append(inputFile)
		  .append(", outputFile = ")
		  .append(outputFile)
		  .append(", ffmpegEncoder = ")
		  .append(ffmpegEncoder)
		  .append(", ffmpegPreset = ")
		  .append(ffmpegPreset)
		  .append(", ffmpegCrf = ")
		  .append(ffmpegCrf);
		return sb.toString();
	}
}
