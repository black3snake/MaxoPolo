package com.javarush.task.task20.task2003;

import java.io.*;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

/* 
Знакомство с properties
Надо использовать java.util.Properties
использую и плюс кодировку windows-1251
*/
public class Solution {

    public static Map<String, String> runtimeStorage = new HashMap<>();

    public static void save(OutputStream outputStream) throws Exception {
        //напишите тут ваш код
        BufferedWriter bufrw = new BufferedWriter(new OutputStreamWriter(outputStream, "windows-1251"));
        Properties p = new Properties();
        p.putAll(runtimeStorage);
        p.store(bufrw, "Number 1");
        outputStream.flush();
    }

    public static void load(InputStream inputStream) throws IOException {
        //напишите тут ваш код
        BufferedReader buffR = new BufferedReader(new InputStreamReader(inputStream, "windows-1251"));
        Properties p = new Properties();
        p.load(buffR);
        p.forEach((k, v) -> {
            runtimeStorage.put((String) k, (String) v);
        });

        buffR.close();
        inputStream.close();
    }

    public static void main(String[] args) {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
            FileInputStream fos = new FileInputStream(reader.readLine())) {
            reader.close();
            load(fos);
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.println(runtimeStorage);

        try {
            FileOutputStream outputStream = new FileOutputStream("F:\\1\\.properties2");
            save(outputStream);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
