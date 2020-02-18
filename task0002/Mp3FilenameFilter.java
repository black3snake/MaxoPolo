package com.javarush.task.task02;
import java.io.File;
import java.io.FilenameFilter;
 
public class Mp3FilenameFilter implements FilenameFilter {
 
    // Принимает пути (path) с окончаниями '.mp3'
    @Override
    public boolean accept(File dir, String name) {
 
        if (name.endsWith(".mp3")) {
            return true;
        }
 
        return false;
    }
 
}
