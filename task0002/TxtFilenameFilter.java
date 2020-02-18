package com.javarush.task.task02;
import java.io.File;
import java.io.FilenameFilter;
 
public class TxtFilenameFilter implements FilenameFilter {
 
    // Принимает пути (path) с окончаниями '.txt'
    @Override
    public boolean accept(File dir, String name) {
 
        if (name.endsWith(".txt")) {
            return true;
        }
 
        return false;
    }
 
}
