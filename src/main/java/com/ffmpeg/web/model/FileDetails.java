package com.ffmpeg.web.model;

public class FileDetails {

	private String inputFile;

	private String outputFile;


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

	@Override
	public String toString() {
		return "FileDetails [inputFile=" + inputFile + ", outputFile=" + outputFile + "]";
	}
}
