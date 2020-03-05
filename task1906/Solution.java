package com.javarush.task.task19.task1906;

/* 
Четные символы
*/

import java.io.*;

public class Solution {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        String file1 = reader.readLine();
        String file2 = reader.readLine();
        reader.close();
        FileReader fr = new FileReader(file1);
        FileWriter fw = new FileWriter(file2);
        int count = 1;
        int data;
        while ((data = fr.read()) != -1) {
            if(count%2 == 0) {
                fw.write(data);
            }
            count++;
        }
        fr.close();
        fw.close();
    }
}
