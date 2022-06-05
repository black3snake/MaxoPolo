package com.javarush.task.task18.task1822;

/* 
Поиск данных внутри файла
моя вариация решения Валя её не приняла! Хотя результат соответствует заданию.
*/

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;

public class Solution {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        FileInputStream in = new FileInputStream(reader.readLine());
        Map<Integer,String> map = new HashMap<>();
        StringBuffer sb = new StringBuffer();
        int i;
        while ((i = in.read()) != -1 ) {
                if((char)i != 13 && (char)i != 10 ) {
                    sb.append((char)i);
                }
                if((char)i == 13) {
                    //System.out.println(sb);
                    String [] n = sb.toString().split("\\s+");
                    //System.out.println(sb.indexOf(" "));
                    sb.delete(0, sb.length());
                    for(int j = 1; j< n.length ; j++ ) {
                        sb.append(n[j]).append(" ");
                    }
                    map.put(Integer.parseInt(n[0]),sb.deleteCharAt(sb.length()-1).toString());
                    sb.delete(0, sb.length());
                    //System.out.println(Arrays.toString(n));
                }

        }
        if(args.length > 0) {
            int y = Integer.parseInt(args[0]);
            for(Map.Entry entry : map.entrySet()) {
                if(entry.getKey().equals(y)) {
                    System.out.println(entry.getValue());
                    //System.out.println(entry.getKey() + " " + entry.getValue());
                }
            }

        } else {
            System.out.println("Введите цифровое заначене ID ");
        }

        /*for(Map.Entry entry : map.entrySet()) {
            System.out.println("Key: " + entry.getKey() + " Значение: " + entry.getValue());
        }*/
    reader.close();
    in.close();
    }
}
