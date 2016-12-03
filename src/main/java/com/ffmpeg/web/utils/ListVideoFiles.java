package com.ffmpeg.web.utils;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.List;

public class ListVideoFiles {
    public static File[] listFiles(String videoInputDirectory) {
    	File dir = new File(videoInputDirectory);
        return dir.listFiles(new FileFilter(Constants.VideoFiles.VIDEO_FILE_FILTERS));
    }
    
    public static List<String> listVideoFiles(String videoInputDirectory) {
    	File[] listFiles = ListVideoFiles.listFiles(videoInputDirectory);
    	List<String> files = new ArrayList<String>();
    	for (File file : listFiles) {
			files.add(file.getName());
		}
    	return files;
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
