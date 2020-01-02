package com.javarush.task.task18.task1810;

/* 
DownloadException
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws DownloadException, IOException {
        final int MAGIC_SIZE = 1000;
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        FileInputStream inputStream;

            while (true) {

                inputStream = new FileInputStream(reader.readLine());
                long count = inputStream.available();

                if (count < MAGIC_SIZE) {
                    inputStream.close();
                    reader.close();
                    throw new DownloadException();
                }
                inputStream.close();
            }
    }

    public static class DownloadException extends Exception {
        /*public DownloadException(String str) {
            super(str);
        }*/
    }
}
