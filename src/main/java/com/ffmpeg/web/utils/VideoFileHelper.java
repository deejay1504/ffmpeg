package com.ffmpeg.web.utils;

import java.io.File;
import java.io.FilenameFilter;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import com.ffmpeg.web.model.FfmpegDetails;

public class VideoFileHelper {
    public static File[] listFiles(String videoInputDirectory) {
    	File dir = new File(videoInputDirectory);
        return dir.listFiles(new FileFilter(Constants.VideoFiles.VIDEO_FILE_FILTERS));
    }
    
    public static List<String> listVideoFiles(String videoInputDirectory) {
    	File[] fileArray = VideoFileHelper.listFiles(videoInputDirectory);
    	if (fileArray == null) {
    		return Collections.emptyList();
    	}
    	List<File> fileList = Arrays.stream(fileArray).collect(Collectors.toList());
    	return fileList.stream().map(f -> f.getName()).sorted().collect(Collectors.toList());
    }
    
    public static String putSeparatorOnFilePath(String filePath) {
    	if (filePath.substring(filePath.length() - 1).equals(File.separator)) {
    		return filePath;
    	}
    	StringBuilder sb = new StringBuilder(filePath);
    	sb.append(File.separator);
    	return sb.toString();
    }

	public static boolean validFfmpegProgram(FfmpegDetails ffmpegDetails) {
		StringBuilder sb = new StringBuilder(VideoFileHelper.putSeparatorOnFilePath(ffmpegDetails.getFfmpegPath()));
		sb.append(Constants.ProgramName.WINDOWS);
		File ffmpegLocation = new File(sb.toString());
		if (ffmpegLocation.exists()) {
			return true;
		} else {
			sb = new StringBuilder(VideoFileHelper.putSeparatorOnFilePath(ffmpegDetails.getFfmpegPath()));
			sb.append(Constants.ProgramName.UNIX);
			ffmpegLocation = new File(sb.toString());
			if (ffmpegLocation.exists()) {
				return true;
			}
		}
		return false;
	}
	
	public static boolean isOsUnix() {
		String os = System.getProperty(Constants.OS.OS_NAME).toLowerCase();
		return (os.indexOf(Constants.OS.NIX) >= 0 || os.indexOf(Constants.OS.NUX) >= 0 || os.indexOf(Constants.OS.AIX) > 0 );
	}

}

class FileFilter implements FilenameFilter {

    private String[] allowedExtensions = null;

    public FileFilter(String[] allowedExtensions) {
        this.allowedExtensions = allowedExtensions.clone();
    }

    @Override
    public boolean accept(File dir, String name) {

        String fileExt = name.substring(name.lastIndexOf(".") + 1);
        for (String imgExt : allowedExtensions) {
            if (imgExt.compareToIgnoreCase(fileExt) == 0)
                return true;
        }
        return false;
    }
}
