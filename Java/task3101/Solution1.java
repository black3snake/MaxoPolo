package com.javarush.task.task31.task3101;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/*
Проход по дереву файлов
*/
public class Solution {
    public static void main(String[] args) {
        List<File> files;
        if(args.length == 2) {
            File folder = new File(args[0]);
            File path2 = new File(args[1]);
            String path2A = path2.getAbsolutePath();
            String path3A = path2.getParent();

            path2 = renameF(path2); // переименование имени выходного файла
            files = getfile(folder); // заполнить Список всеми файлами в дире.. вложенными тоже

            printF(files);



        } else {
            System.out.println("Введите два аргумента в командной строке");
        }
    }
    public static List<File> getfile(File dir) {
        List<File> fileList = new ArrayList<>();
        File listFile[] = dir.listFiles();
        if (listFile != null && listFile.length > 0) {
            for (int i = 0; i < listFile.length; i++) {

                if (listFile[i].isDirectory()) {
                    fileList.addAll(getfile(listFile[i]));
                } else
                    fileList.add(listFile[i]);
            }
        }
        return fileList;
    }

public static File renameF(File file) {
        String resultFileAbsolutePath = "allFilesContent.txt";
        String resulInput = file.getParent();
        String resulProverka = resulInput + "\\"  + resultFileAbsolutePath;
        File rP = new File(resulProverka);
        if(FileUtils.isExist(rP)) {
            FileUtils.deleteFile(rP);
        } else FileUtils.renameFile(file,rP);
        try {
            rP.createNewFile();
        } catch (IOException e) {
            e.printStackTrace();
        }
    return rP;
}
public static List sortF(List<File> list) {


    return list;
    }

public static void printF(List<File> list) {
    for(File x : list) {
        System.out.println(x);
    }
}

}

