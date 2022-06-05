package com.javarush.task.task19.task1924;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;

/* 
Замена чисел
Валя не приняла хотя условия задачи выполнены.
*/

public class Solution {
    public static Map<Integer, String> map = new HashMap<Integer, String>();
    static {
        map.put(0, "ноль");
        map.put(1, "один");
        map.put(2, "два");
        map.put(3, "три");
        map.put(4, "четыре");
        map.put(5, "пять");
        map.put(6, "шесть");
        map.put(7, "семь");
        map.put(8, "восемь");
        map.put(9, "девять");
        map.put(10, "десять");
        map.put(11, "одиннадцать");
        map.put(12, "двенадцать");
    }

    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        FileReader fr = new FileReader(reader.readLine());
        BufferedReader buffR = new BufferedReader(fr);
        reader.close();
        String str;
        Integer intdex;
        StringBuilder sb = new StringBuilder();
        while ((str = buffR.readLine()) != null) {
            String [] strM = str.split("\\s");
            for (int i = 0; i < strM.length; i++) {
                if(strM[i].matches("\\d+")) {
                    intdex = Integer.parseInt(strM[i]);
                    if (intdex >=0 && intdex <= 12) strM[i] = map.get(intdex);
                }

            }
            for (int i = 0; i < strM.length ; i++) {
                sb.append(strM[i]).append(" ");
            }
            System.out.println(sb.toString().trim());
            sb.delete(0,sb.length());
        }
        buffR.close();
        fr.close();
    }
}
