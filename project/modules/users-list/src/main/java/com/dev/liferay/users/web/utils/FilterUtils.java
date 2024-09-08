package com.dev.liferay.users.web.utils;

import com.dev.liferay.users.web.beans.FilterBean;
import com.dev.liferay.users.web.beans.UsuarioBean;

public class FilterUtils {
    private FilterUtils() {

    }

    public static boolean isUser(UsuarioBean usuarioBean, FilterBean filterBean) {
        final var surnamesList = usuarioBean.getSurname1().concat(usuarioBean.getSurname2()).replaceAll("\\s", "");
        final var surnamesBean = filterBean.getSurnames().replaceAll("\\s", "");
        return usuarioBean.getName().toLowerCase().contains(filterBean.getName().toLowerCase())
                && surnamesList.contains(surnamesBean)
                && usuarioBean.getEmail().toLowerCase().contains(filterBean.getEmail().toLowerCase());
    }
}
