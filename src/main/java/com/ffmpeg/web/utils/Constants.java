package com.ffmpeg.web.utils;

public final class Constants {

	private Constants() {}

	public final class Property {
		private Property() {}
		
		public static final String FILE_PATH = "file.path";
		public static final String PATH      = "ffmpeg.path";
		public static final String FORMAT    = "ffmpeg.format";
	}

	public final class Ffmpeg {
    	private Ffmpeg() {}
    
    	public static final String INPUT           = " -i ";
    	public static final String FORMAT          = " -c:v ";
    	public static final String CONVERSION_RATE = " -crf ";
    	public static final String PRESET          = " -preset ";
    	public static final String OUTPUT          = " -c:a copy ";
    	public static final String LOGGING_OFF     = " -nostats -loglevel 0 ";
    }
}
