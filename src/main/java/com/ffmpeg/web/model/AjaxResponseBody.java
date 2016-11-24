package com.ffmpeg.web.model;

import com.fasterxml.jackson.annotation.JsonView;
import com.ffmpeg.web.jsonview.Views;

public class AjaxResponseBody {

	@JsonView(Views.Public.class)
	String msg;
	@JsonView(Views.Public.class)
	String code;

	public String getMsg() {
		return msg;
	}

	public void setMsg(String msg) {
		this.msg = msg;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder("[msg = ");
		sb.append(msg).append(", code = ").append(code).append("]");
		return sb.toString();
	}

}
