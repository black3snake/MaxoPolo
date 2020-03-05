package com.javarush.task.task19.task1920;

/* 
Самый богатый
Как я и говорил во более простая программа при сортировки по ключу
*/

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Map;
import java.util.TreeMap;

public class Solution {
    public static void main(String[] args) {
        Map<String, Double> sortedMap = new TreeMap<>(String::compareTo);
        if (args.length > 0) {
            FileReader fr;
            BufferedReader buffR;
            try {
                fr = new FileReader(args[0]);
                buffR = new BufferedReader(fr);
                String str;
                Double strChD;
                while ((str = buffR.readLine()) != null) {
                    String[] str2 = str.split("\\s");
                    strChD = sortedMap.get(str2[0]);   //получение значения по ключу.
                    sortedMap.put(str2[0], strChD == null ? Double.parseDouble(str2[1]) :
                           Double.parseDouble(str2[1]) + strChD );
                }
                buffR.close();
                fr.close();
            } catch (FileNotFoundException e) {
                System.out.println("Такого файла нет :(");
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            System.out.println("введите к качестве параметра имя файла и путь до него");
        }
        for(Map.Entry<String,Double> entry : sortedMap.entrySet()) {
            System.out.println(entry.getKey() + " " + entry.getValue());
        }

    }
}
