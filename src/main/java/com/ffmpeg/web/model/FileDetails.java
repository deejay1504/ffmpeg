package com.ffmpeg.web.model;

public class FileDetails extends FfmpegDetails {
	private String filePath;

	private String ffmpegPath;

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

	public String getFilePath() {
		return filePath;
	}

	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}

	public String getFfmpegPath() {
		return ffmpegPath;
	}

	public void setFfmpegPath(String ffmpegPath) {
		this.ffmpegPath = ffmpegPath;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		sb.append("FileDetails [inputFile = ")
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
