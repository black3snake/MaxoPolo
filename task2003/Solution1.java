package com.javarush.task.task20.task2003;

import java.io.*;
import java.util.HashMap;
import java.util.Map;

/* 
Знакомство с properties
Эх кто бы хоть объяснил что надо использовать java.util.Properties
в условиях задачи этого нет. Решена известными методами.
След. редакция будете решена через нужный класс
*/
public class Solution {

    public static Map<String, String> runtimeStorage = new HashMap<>();

    public static void save(OutputStream outputStream) throws Exception {
        //напишите тут ваш код
        StringBuilder sb = new StringBuilder();
        for(Map.Entry entry : runtimeStorage.entrySet()) {
            sb.append(entry.getKey()).append("=").append(entry.getValue()).append(System.lineSeparator());
            outputStream.write(sb.toString().getBytes());
            sb.delete(0,sb.length());
        }
        outputStream.flush();
    }

    public static void load(InputStream inputStream) throws IOException {
        //напишите тут ваш код
        BufferedReader buffR = new BufferedReader(new InputStreamReader(inputStream, "windows-1251"));
        String[] ARstroka;
        while (buffR.ready() ) {
            String stroka = buffR.readLine();
            stroka = stroka.replaceAll("^\\s+","");
            if (!stroka.startsWith("#")) {
                if (stroka.contains("=")) {
                    ARstroka = stroka.split("=");
                } else ARstroka = stroka.split(":");
                if (stroka.endsWith("\\") & ARstroka.length > 0) {
                    String DopStroka = buffR.readLine();
                    DopStroka = DopStroka.replaceAll("^\\s+", "").trim();
                    ARstroka[1] = ARstroka[1].substring(0, ARstroka[1].length() - 1);
                    ARstroka[1] = ARstroka[1].concat(DopStroka);
                }
                runtimeStorage.put(ARstroka[0], ARstroka[1]);
            }
        }
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
            FileOutputStream outputStream = new FileOutputStream("F:\\1\\.properties");
            save(outputStream);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
