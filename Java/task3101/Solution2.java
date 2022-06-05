package com.javarush.task.task31.task3101;

import java.io.*;
import java.util.*;

/*
Проход по дереву файлов
*/
public class Solution {
    public static void main(String[] args) {
        List files;
        if(args.length == 2) {
            File folder = new File(args[0]); // путь к директории пар 1.
            File resultFileAbsolutePath = new File(args[1]);  // имя  файла с полным путем который будет содержать результат

            File newFile = new File(resultFileAbsolutePath.getParent() + "/allFilesContent.txt");
            FileUtils.renameFile(resultFileAbsolutePath, newFile);


            try (BufferedWriter buffw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(newFile), "windows-1251"))) {
            

            }
            catch (IOException e) {
                e.printStackTrace();
            }

            /*try {
                path2.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
            }*/
            //path2 = renameF(path2); // переименование имени выходного файла
            files = getfile(folder); // заполнить Список всеми файлами в дире.. вложенными тоже

            printF(files);  //вывод всех файлов
            System.out.println("--------------------------------------");

            files = lenFile50(files); // убираем из списка файлы размер который больше 50байт
            printF(files);
            System.out.println("--------------------------------------");

            /*Collections.sort(files, new Comparator<File>() {
                @Override
                public int compare(File o1, File o2) {
                    return  o1.getName().compareTo(o2.getName());
                }
            });*/
            files.sort((Comparator<File>) (o1, o2) -> o1.getName().compareTo(o2.getName()));



            printF(files); //Вывод сортированного списка

            zapisF(newFile,files); //запишем содержимое файлов разером не более 50байт в один файл


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

/*public static File renameF(File file) {
        String resultFileAbsolutePath = "allFilesContent.txt";
        String resulInput = file.getParent();
        String resulProverka = resulInput + "\\"  + resultFileAbsolutePath;
        File rP = new File(resulProverka);
        if(FileUtils.isExist(rP)) {
            FileUtils.deleteFile(rP);
        }
        if(FileUtils.isExist(file)) {
            FileUtils.renameFile(file, rP);
        } else {
            try {
                rP.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    return rP;
}*/
public static List lenFile50(List<File> list) {
    //while (iterator.hasNext()) {
    //    if (iterator.next().length() >= 50) iterator.remove();
        list.removeIf(file -> file.length() >= 50);
    return list;
    }

public static void printF(List<File> list) {
    for(File x : list) {
        System.out.println(x);
    }
}
public static void zapisF(File file, List<File> list) {
    try {
        BufferedWriter buffw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "windows-1251"));
        for(File x: list) {
            BufferedReader buffR = new BufferedReader(new InputStreamReader(new FileInputStream(x), "windows-1251"));
            String line;
            while ((line = buffR.readLine()) != null) {
                    buffw.write(line + System.lineSeparator());
            }
            buffw.write(System.lineSeparator());
            buffR.close();
        }
        buffw.close();
    } catch (IOException e) {
        e.printStackTrace();
    }
}
}

