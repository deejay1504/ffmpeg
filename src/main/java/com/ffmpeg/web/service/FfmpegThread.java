package com.ffmpeg.web.service;

import java.io.IOException;

public class FfmpegThread extends Thread {

	private String ffmpegCmd;
	
	public FfmpegThread(String ffmpegCmd) {
		this.ffmpegCmd = ffmpegCmd;
	}

    public void run() {
    	try {
			Process p = Runtime.getRuntime().exec(ffmpegCmd.toString());
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

}
