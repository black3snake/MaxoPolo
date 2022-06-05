package com.javarush.task.task18.task1822;

/* 
Поиск данных внутри файла
моя вариация решения Валя её не приняла! Хотя результат соответствует заданию.
*/

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Solution {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        FileInputStream in = new FileInputStream(reader.readLine());
        StringBuffer sb = new StringBuffer();
        int i;
        int y = Integer.parseInt(args[0]);
        while ((i = in.read()) != -1 ) {
                if((char)i != 13 && (char)i != 10 ) {
                    sb.append((char)i);
                }
                if((char)i == 13) {
                    Pattern p = Pattern.compile("^\\d+");
                    Matcher m = p.matcher(sb);
                    while (m.find()) {
                        if(Integer.parseInt(m.group()) == y) {
                            //System.out.println(m.group());
                            System.out.println(sb);
                        }
                    }
                    //System.out.println(sb);
                    sb.delete(0, sb.length());
                }
        }
        /*if(args.length > 0) {
            int y = Integer.parseInt(args[0]);
        } else {
            System.out.println("Введите цифровое заначене ID ");
        }*/

        /*for(Map.Entry entry : map.entrySet()) {
            System.out.println("Key: " + entry.getKey() + " Значение: " + entry.getValue());
        }*/
    reader.close();
    in.close();
    }
}
