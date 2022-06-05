package com.javarush.task.task18.task1819;

/* 
Объединение файлов
моя вариация решения Валя её не приняла! Хотя результат соответствует заданию.
*/

import java.io.*;

public class Solution {

    public static void main(String[] args) {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        BufferedInputStream file2 = null;
        //BufferedOutputStream file1 = null;
        RandomAccessFile file = null;

        try {
            int count;
            String fileN1 = reader.readLine();
            String fileN2 = reader.readLine();
            file2 = new BufferedInputStream(new FileInputStream(fileN2));
            //file1 = new BufferedOutputStream(new FileOutputStream(fileN1));
            file = new RandomAccessFile(fileN1,"rw");
            byte[] buffer0 = new byte[file.read()];
            byte [] buffer = new byte[file2.available()];

            while ((count = file2.read(buffer)) > 0) {
                file.seek(0);
                file.write(buffer,0 , count);
                file.seek(count);
                file.write(buffer0);
            }
        } catch (FileNotFoundException e) {
            System.out.println("Ошибочка нет такого файла");
        } catch (IOException e) {
            e.printStackTrace();
        }
        finally {
            try {
                reader.close();
                assert file != null;
                file.close();
                file2.close();
            } catch (IOException e) {
                System.out.println("Ошибка в закрытии потоков");
            }
        }
    }
}
