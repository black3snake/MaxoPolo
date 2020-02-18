package com.javarush.task.task02;
import java.io.File;
import java.io.FilenameFilter;
 
public class DelFilenameFilter implements FilenameFilter {
 
    // Принимает путь (path) сначалом "0+_" используется регекс
    @Override
    public boolean accept(File dir, String name) {
 
        if (name.matches("\\d+\\_.+")) {
            return true;
        }
 
        return false;
    }
 
}