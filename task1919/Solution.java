package com.javarush.task.task19.task1919;

/* 
Считаем зарплаты
Задача решена с сортировкой Мапы по значению ( потом быстро переделана под ключ)
Но иначально Есть гораздо более легкие споробы как например TreeMap которые по умолчанию сортируют по
ключу.
Почему решил по значению ( да потому что так никогда неделал.:-))
*/

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

public class Solution {
    public static void main(String[] args) {
        Map<String, Double> unsortedMap = new HashMap<>();
        if (args.length > 0) {
            FileReader fr;
            BufferedReader buffR;
            try {
                fr = new FileReader(args[0]);
                buffR = new BufferedReader(fr);

                String str;
                Double strChD;
                while ((str = buffR.readLine()) != null) {
                      String [] str2 = str.split("\\s");
                      strChD = unsortedMap.get(str2[0]);   //получение значения по ключу.
                      if(strChD != null) {
                          if (str2[1].matches("\\d+(\\.\\d+)?")){
                              unsortedMap.put(str2[0], Double.parseDouble(str2[1]) + strChD);
                          }
                      } else unsortedMap.put(str2[0], Double.parseDouble(str2[1]));
                }
                buffR.close();
                fr.close();
            } catch (FileNotFoundException e) {
                System.out.println("Такого файла нет :(");
            } catch (IOException e) {
                e.printStackTrace();
            }

           /* for(Map.Entry<String,Double> entry : unsortedMap.entrySet()) {
                System.out.println(entry.getKey() + " " + entry.getValue());
            }*/

        } else {
            System.out.println("введите к качестве параметра имя файла и путь до него");
        }
        Map<String, Double> sortedMap = sortByValue(unsortedMap);
        //System.out.println("*****************************");
        for(Map.Entry<String,Double> entry : sortedMap.entrySet()) {
            System.out.println(entry.getKey() + " " + entry.getValue());
        }

    }
    private static Map<String, Double> sortByValue(Map<String, Double> unsortedMap) {
        //1. Конверирую Map to List of Map (никогда такого не делал)
        List<Map.Entry<String, Double>> list = new LinkedList<>(unsortedMap.entrySet());
        //2. Сортируем лист с помощью Collections.sort() и орпередяем Comparator
        Collections.sort(list, new Comparator<Map.Entry<String, Double>>() {
            @Override
            public int compare(Map.Entry<String, Double> o1,
                               Map.Entry<String, Double> o2) {
                return (o1.getKey()).compareTo(o2.getKey());   //Сортировка по ключу
                /*return (o1.getKey()).compareTo(o2.getKey()); Сортировка по значению */
            }
        });
        //3. В цикле заполняю навую Мапу с помощь отсортированного листа
        Map<String, Double> sortedMap = new LinkedHashMap<>();
        for (Map.Entry<String, Double> entry : list) {
            sortedMap.put(entry.getKey(), entry.getValue());
        }
        return sortedMap;
    }
}
