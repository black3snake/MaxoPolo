package com.javarush.task.task19.task1916;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

/* 
Отслеживаем изменения
Решение если во втором файлы есть пробелы
ео по условию задачи выяснилось что их нет.. по этому пишим другую программу
*/

public class Solution {
    public static List<LineItem> lines = new ArrayList<LineItem>();

    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        BufferedReader buffRF1 = new BufferedReader(new FileReader(reader.readLine()));
        BufferedReader buffRF2 = new BufferedReader(new FileReader(reader.readLine()));
        reader.close();
        String F1, F2;
        while (buffRF1.ready() || buffRF2.ready()) {
            try {
                F1 = buffRF1.readLine();
                if(F1.isEmpty()) F1 = "empty";
            } catch (NullPointerException e) {
                F1 = "empty";
            }
            try {
                F2 = buffRF2.readLine();
                if (F2.isEmpty()) F2 = "empty";
            } catch (NullPointerException e) {
                F2 = "empty";
            }
            if (F1.equals(F2)) {
                lines.add(new LineItem(Type.SAME, F1));
            } else if (!F1.equals("empty") & F2.equals("empty")) {
                lines.add(new LineItem(Type.REMOVED, F1));
            } else if (F1.equals("empty") & !F2.equals("empty")) {
                lines.add(new LineItem(Type.ADDED, F2));
            }
        }

        for (int i = 0; i < lines.size(); i++) {
            System.out.println(lines.get(i).type + " " + lines.get(i).line);

        }

        buffRF1.close();
        buffRF2.close();
    }


    public static enum Type {
        ADDED,        //добавлена новая строка
        REMOVED,      //удалена строка
        SAME          //без изменений
    }

    public static class LineItem {
        public Type type;
        public String line;

        public LineItem(Type type, String line) {
            this.type = type;
            this.line = line;
        }
    }
}
