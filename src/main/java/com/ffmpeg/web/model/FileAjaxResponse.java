package com.ffmpeg.web.model;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonView;
import com.ffmpeg.web.jsonview.Views;

public class FileAjaxResponse {

	@JsonView(Views.Public.class)
	private List<String> fileName;
	
	@JsonView(Views.Public.class)
	private String code;

	@JsonView(Views.Public.class)
	private String msg;
	
	public List<String> getFileName() {
		return fileName;
	}
	
	public void setFileName(List<String> fileName) {
		this.fileName = fileName;
	}
	
	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getMsg() {
		return msg;
	}
	
	public void setMsg(String msg) {
		this.msg = msg;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("[fileName = ");
		sb.append(fileName).append(", code = ").append(code).append(", msg = ").append(msg).append("]");
		return sb.toString();
	}

}
