package com.javarush.task.task31.task3101;

import java.io.*;
import java.nio.file.FileVisitResult;
import java.nio.file.FileVisitor;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.List;

/*
Проход по дереву файлов
*/
public class Solution {
    public static void main(String[] args) {
        //List files;
        if(args.length == 2) {
            File folder = new File(args[0]); // путь к директории пар 1.
            File resultFileAbsolutePath = new File(args[1]);  // имя  файла с полным путем который будет содержать результат
            File newFile = new File(resultFileAbsolutePath.getParent() + "/allFilesContent.txt");
            try { resultFileAbsolutePath.createNewFile();
                if(FileUtils.isExist(newFile)) {
                    FileUtils.deleteFile(newFile);
                }
            } catch (IOException e) { e.printStackTrace();}
            FileUtils.renameFile(resultFileAbsolutePath, newFile);

            try (BufferedWriter buffw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(newFile), "windows-1251"))) {
                List<File> files = new ArrayList<>();
              
		Files.walkFileTree(folder.toPath(), new FileVisitor<Path>() {
                    @Override
                    public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) throws IOException {
                        return FileVisitResult.CONTINUE;
                    }

                    @Override
                    public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                        if (attrs.isRegularFile() && attrs.size() <= 50) {
                            files.add(new File(file.toUri()));
                        }
                        return FileVisitResult.CONTINUE;
                    }

                    @Override
                    public FileVisitResult visitFileFailed(Path file, IOException exc) throws IOException {
                        return FileVisitResult.SKIP_SUBTREE;
                    }

                    @Override
                    public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
                        return FileVisitResult.CONTINUE;
                    }
                });


                files.sort((o1, o2) -> o1.getName().compareToIgnoreCase(o2.getName()));
                printF(files); //Вывод сортированного списка
                //запишем содержимое файлов разером не более 50байт в один файл
                for(File x: files) {
                    BufferedReader buffR = new BufferedReader(new InputStreamReader(new FileInputStream(x), "windows-1251"));
                    String line;
                    while ((line = buffR.readLine()) != null) {
                        buffw.write(line + System.lineSeparator());
                    }
                    buffw.write(System.lineSeparator());
                    buffR.close();
                }
            }
            catch (IOException e) {
                e.printStackTrace();
            }

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

}

