package com.ffmpeg.web.utils;

public final class Constants {

	private Constants() {}

	public final static class ProgramName {
		private ProgramName() {}
		
		public static final String WINDOWS = "ffmpeg.exe";
		public static final String UNIX    = "ffmpeg";
	}

	public final static class OS {
		private OS() {}
		
		public static final String OS_NAME = "os.name";
		public static final String NIX     = "nix";
		public static final String NUX     = "nux";
		public static final String AIX     = "aix";
	}
	
	public final static class Url {
		private Url() {}
		
		public static final String CONVERT    = "/ffmpeg/api/convertFile";
		public static final String GET_VIDEO  = "/ffmpeg/api/getVideoFiles";
		public static final String CANCEL     = "/ffmpeg/api/cancelConversion";
		public static final String SAVE_ADMIN = "/ffmpeg/api/saveAdmin";
	}
	
	public final static class VideoFiles {
		private VideoFiles() {}
		
		public static final String[] VIDEO_FILE_FILTERS = {"avi", "mp4", "mkv", "mov"};
	}

	public final class Ffmpeg {
    	private Ffmpeg() {}
    
    	public static final String INPUT           = " -i ";
    	public static final String OVERWRITE       = " -y";
    	public static final String FORMAT          = " -c:v ";
    	public static final String CONVERSION_RATE = " -crf ";
    	public static final String PRESET          = " -preset ";
    	public static final String OUTPUT          = " -c:a copy ";
    	public static final String LOGGING_OFF     = " -nostats -loglevel 0";
    }
	
	public final class Codes {
		private Codes() {}
		
		public static final String SUCCESS      = "200";
		public static final String ERROR        = "400";
		public static final String FFMPEG_ERROR = "422";
	}

	public final class Messages {
		private Messages() {}
		
		public static final String SUCCESS          = "Successfully converted {0}";
		public static final String CANCEL_SUCCESS   = "Successfully cancelled process";
		public static final String DIR_ERROR        = "{0} is an invalid directory. Please select a valid one.";
		public static final String FFMPEG_DIR_ERROR = "The \'ffmpeg\' program is not located in the {0} directory. Please select another.";
		public static final String ERROR            = "Error processing {0} {1}";
		public static final String CONVERSION_ERROR = "Conversion error {0}";
		public static final String CANCEL_CONV      = "Conversion process is not running";
		public static final String JSON_SUCCESS     = "Successfully stored Admin details";
		public static final String JSON_ERROR       = "Error in JSON mapper";
	}
}
